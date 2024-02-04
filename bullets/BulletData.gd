## Class that holds bullet texture, shape, and other universal bullet properties
@tool
class_name BulletData extends Resource

@export_group("Sprite Texture")
## Bullet texture
@export var texture : Texture2D
@export_subgroup("Animation")
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
		frame = value
		frame_coords.x = clampi(value % hframes, 0, hframes)
		frame_coords.y = clampi(value / vframes, 0, vframes) if hframes > 1 else value
		notify_property_list_changed()
## Texture animation frame coords
@export var frame_coords : Vector2i:
	set(value):
		if frame_coords == value: return
		frame_coords.x = clampi(value.x, 0, hframes)
		frame_coords.y = clampi(value.y, 0, vframes)
		frame = (hframes * value.y) + value.x
		notify_property_list_changed()
@export var animated : bool = false
@export var start_frame : int = 0
@export var end_frame : int = 0
@export var ani_rate : int = 10

@export_subgroup("Shape")
## Shape for the bullet physics query
@export var shape : Shape2D

@export_group("Properties")
## Damage
@export var damage : int = 10
@export var grazeable : bool = true
## If bullet should be directed
@export var directed : bool = false
## How many times the bullet should bounce
@export var bounces : int = 0
## How many frames the bullet should live for
@export var duration : int = 0
@export var hide_on_hit : bool = true

@export_flags_2d_physics var hitbox_layer := 0b0100_0010_0000_0000
@export_flags_2d_physics var graze_layer := 0b0000_0001_0000_0000

## Swap the sprite's texture information with the data's properties
func set_texture(sprite : Sprite2D) -> void:
	if sprite.texture != texture:
		sprite.texture = texture
	sprite.hframes = hframes
	sprite.vframes = vframes
	sprite.frame = frame
	sprite.frame_coords = frame_coords
