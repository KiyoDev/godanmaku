# TODO: use PhysicsServer2D to draw and move bullets rather than using a Sprite2D
@tool
class_name Bullet extends Resource


signal expired


## Bullet properties
@export_group("Properties")
@export_subgroup("Movement Settings")
## Bullet speed
@export var velocity : int = 100
## Max bullet speed
@export var max_velocity : int = 1000
## Bullet acceleration
@export var acceleration : int = 0
@export_subgroup("Collision Settings")
## Damage
@export var damage : int = 1
## If bullet can be grazed
@export var grazeable : bool = true
## If bullet should be directed
@export var directed : bool = false
## How many times the bullet should bounce
@export var bounces : int = 0
## How many frames the bullet should live for
@export var duration : int = 0
@export var hide_on_hit : bool = true
## The layers that the bullet should interact with
@export_flags_2d_physics var hitbox_layer := 0b0000_0000_0000_0001
## The layer of the player's graze area
@export_flags_2d_physics var graze_layer := 0b0000_0000_0000_0010

@export_group("Sprite Texture")
## Bullet texture
@export var texture : Texture2D
@export_subgroup("Animation")
@export var animated : bool = false
@export var start_frame : int = 0
@export var end_frame : int = 0
@export var ani_rate : int = 10
## Texture animation horizontal frame count
@export_range(1, 128) var hframes : int = 0:
	set(value):
		hframes = value
		frame_coords = Vector2i(clampi(frame_coords.x, 0, hframes), frame_coords.y)
		if hframes * vframes <= frame:
			frame = hframes * vframes
		notify_property_list_changed()
## Texture animation vertical frame count
@export_range(1, 128) var vframes : int = 0:
	set(value):
		vframes = value
		frame_coords.y = clampi(frame_coords.y, 0, vframes)
		if hframes * vframes <= frame:
			frame = hframes * vframes
		notify_property_list_changed()
## Texture animation frame
@export_range(0, 16383) var frame : int = 0:
	set(value):
		if frame == value: return
		updating_frame = true
		frame = value
		if !updating_coords:
			frame_coords.x = clampi(value % hframes, 0, hframes)
			frame_coords.y = clampi(value / vframes, 0, vframes) if hframes > 1 else value
		notify_property_list_changed()
		updating_frame = false
## Texture animation frame coords
@export var frame_coords : Vector2i:
	set(value):
		if frame_coords == value: return
		updating_coords = true
		frame_coords.x = clampi(value.x, 0, hframes - 1)
		frame_coords.y = clampi(value.y, 0, vframes - 1)
		if !updating_frame and value.y < vframes and value.x < hframes:
			frame = (hframes * value.y) + value.x
		notify_property_list_changed()
		updating_coords = false
## Sprite offset
@export var offset : Vector2

## Size and shape properties
@export_subgroup("Size and Shape")
## Shape for the bullet physics queryi
@export var shape : Shape2D
@export var size : Vector2i = Vector2(1, 1)

var updating_coords : bool = false
var updating_frame : bool = false

#var direct_space_state : PhysicsDirectSpaceState2D = get_world_2d().direct_space_state
var query : PhysicsShapeQueryParameters2D = PhysicsShapeQueryParameters2D.new()

# Physics properties
## Reference to the bullet's transform
var transform : Transform2D
## Bullet's position in global space
var position : Vector2
## Angle of travel
var angle : float = 0:
	set(value):
		angle = value
		update_rotation()
## Bullet's virtual position along a straight path. Used for calculating motion offsets
var virtual_position : Vector2
## Offset to virtual position
var position_offset : Vector2 = Vector2.ZERO

## If the bullet should fade after a certain time
#var fade : bool = false
var can_graze : bool = false

var camera : Camera2D
var screen_extents : Vector2

# internal properties

## How long the bullet has been alive for
var up_time : int = 0
var max_bounces : int = 0
## Current bounce count
var current_bounces : int = 0
## Current animation frame
var ani_time : int = 0


func update_rotation() -> void:
	# TODO: need to rotate bullet to face the direction its traveling in
	#if directed:
		#look_at(global_position + Vector2.RIGHT.rotated(angle))
	pass


func _disable() -> void:
	pass


func _move_update(delta : float, bullet : Bullet, props : Dictionary) -> void:
	if !camera: 
		_disable()
		return
	
	# frame up time
	up_time += 1
	
	#print("v=%s,a=%s" % [velocity, acceleration])
	velocity = max(min(velocity + acceleration, max_velocity), 0)
	
	# Take into consideration angle to arc
	virtual_position = Vector2(virtual_position.x + (velocity * delta) * cos(angle), virtual_position.y + (velocity * delta) * sin(angle))
	# update rotation of texture and transform if bullet is directed
	# FIXME
	#if directed:
		#look_at(virtual_position)
	
	query.transform = transform
	position = virtual_position + position_offset
	
	if position.y <= -(camera.global_position + screen_extents).y or position.y >= (camera.global_position + screen_extents).y or position.x <= -(camera.global_position + screen_extents).x or position.x >= (camera.global_position + screen_extents).x:
		# FIXME: need to properly handle bouncing boundary
		# when reaching edge of screen, disable bullet or bounce if applicable
		if max_bounces > 0 and current_bounces < max_bounces:
			if position.y <= -(camera.global_position + screen_extents).y or position.y >= (camera.global_position + screen_extents).y:
				angle = -angle
			elif position.x <= -(camera.global_position + screen_extents).x or position.x >= (camera.global_position + screen_extents).x:
				angle = -PI - angle
			current_bounces += 1
		else:
			_disable()
		return


func _animation_update(delta : float, bullet : Bullet, props : Dictionary) -> void:
	ani_time += 1
	if ani_time == ani_rate:
		ani_time = 0
		frame = wrapi(frame + 1, start_frame, end_frame + 1)
