# TODO: use PhysicsServer2D to draw and move bullets rather than using a Sprite2D
## @deprecated
class_name BulletRef extends RefCounted

signal expired

## BulletRef properties
var velocity : int = 100
## Max bullet speed
var max_velocity : int = 1000
## BulletRef acceleration
var acceleration : int = 0
## Damage
var damage : int = 1
## If bullet can be grazed
var grazeable : bool = true
## If bullet should be directed
var directed : bool = false
## How many times the bullet should bounce
var bounces : int = 0
## How many frames the bullet should live for
var duration : int = 0
var hide_on_hit : bool = true
## The layers that the bullet should interact with
var hitbox_layer := 0b0000_0000_0000_0001
## The layer of the player's graze area
var graze_layer := 0b0000_0000_0000_0010


## BulletRef texture
var texture : Texture2D
var animated : bool = false
var start_frame : int = 0
var end_frame : int = 0
var ani_rate : int = 10
## Texture animation horizontal frame count
var hframes : int = 0
## Texture animation vertical frame count
var vframes : int = 0
## Texture animation frame
var frame : int = 0
## Texture animation frame coords
var frame_coords : Vector2i
## Sprite offset
var offset : Vector2

## Shape for the bullet physics queryi
var shape : Shape2D
var size : Vector2i = Vector2(1, 1)

var updating_coords : bool = false
var updating_frame : bool = false

var properties : Dictionary = {}

# Physics properties
## Reference to the bullet's transform
var transform : Transform2D
## BulletRef's position in global space
var position : Vector2
## Angle of travel
var angle : float = 0:
	set(value):
		angle = value
		update_rotation()
## BulletRef's virtual position along a straight path. Used for calculating motion offsets
var virtual_position : Vector2
## Offset to virtual position
var position_offset : Vector2 = Vector2.ZERO

var can_graze : bool = false

# internal properties
## How long the bullet has been alive for
var up_time : int = 0
var max_bounces : int = 0
## Current bounce count
var current_bounces : int = 0
## Current animation frame
var ani_time : int = 0


func set_data(bullet_data : BulletData) -> void:
	animated = bullet_data.animated
	start_frame = bullet_data.start_frame
	end_frame = bullet_data.end_frame
	texture = bullet_data.texture
	hframes = bullet_data.hframes
	vframes = bullet_data.vframes
	frame = bullet_data.frame
	frame_coords = bullet_data.frame_coords
	damage = bullet_data.damage
	directed = bullet_data.directed
	shape = bullet_data.shape.duplicate(0b0111)
	hitbox_layer = bullet_data.hitbox_layer
	graze_layer = bullet_data.graze_layer
	duration = bullet_data.duration


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


func _move_update(delta : float, bullet : BulletRef, props : Dictionary) -> void:
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
