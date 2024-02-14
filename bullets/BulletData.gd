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

# checked to make sure to not recursively update property values
var updating_coords : bool = false
var updating_frame : bool = false

## If bullet should be animated
@export var animated : bool = false
## Animation start frame
@export var start_frame : int = 0
## Animation end frame
@export var end_frame : int = 0
## Animation rate
@export var ani_rate : int = 10

## Size and shape properties
@export_subgroup("Size and Shape")
## Shape for the bullet physics queryi
@export var shape : Shape2D
@export var size : Vector2i = Vector2(1, 1)

## Bullet properties
@export_group("Properties")
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

