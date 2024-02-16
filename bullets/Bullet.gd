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

var properties : Dictionary = {}

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

#var camera : Camera2D
#var screen_extents : Vector2

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


func bounce(boundary : Rect2) -> bool:
	if max_bounces > 0 and current_bounces < max_bounces:
		if position.y <= -(boundary.position + (boundary.size / 2)).y or position.y >= (boundary.position + (boundary.size / 2)).y:
			angle = -angle
		elif position.x <= -(boundary.position + (boundary.size / 2)).x or position.x >= (boundary.position + (boundary.size / 2)).x:
			angle = -PI - angle
		current_bounces += 1
		return true
	return false


func _move_update(delta : float, bullet : Bullet, props : Dictionary) -> void:
	#if !camera: 
		#_disable()
		#return
	
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
	
	position = virtual_position + position_offset
	#print("bullet[%s] - pos=%s" % [get_instance_id(), position])
	transform.origin = bullet.position
