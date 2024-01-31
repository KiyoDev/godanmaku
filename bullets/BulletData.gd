@tool
class_name BulletData extends Resource

@export_group("Sprite Texture")
@export var texture : Texture2D
@export_subgroup("Animation")
@export_range(1, 128) var hframes : int = 0:
	set(value):
		hframes = value
		frame_coords = Vector2i(clampi(frame_coords.x, 0, hframes), frame_coords.y)
		if hframes * vframes <= frame:
			frame = hframes * vframes
		notify_property_list_changed()
@export_range(1, 128) var vframes : int = 0:
	set(value):
		vframes = value
		frame_coords.y = clampi(frame_coords.y, 0, vframes)
		if hframes * vframes <= frame:
			frame = hframes * vframes
		notify_property_list_changed()
@export_range(0, 16383) var frame : int = 0:
	set(value):
		if frame == value: return
		frame = value
		#print
		frame_coords.x = clampi(value % hframes, 0, hframes)
		frame_coords.y = clampi(value / vframes, 0, vframes)
		notify_property_list_changed()
		
@export var frame_coords : Vector2i:
	set(value):
		if frame_coords == value: return
		frame_coords.x = clampi(value.x, 0, hframes)
		frame_coords.y = clampi(value.y, 0, vframes)
		frame = (hframes * value.y) + value.x
		notify_property_list_changed()
@export_subgroup("Shape")
@export var shape : Shape2D

@export_group("Properties")
@export var directed : bool = false
@export var bounces : int = 0
@export var duration : int = 0

@export_flags_2d_physics var hitbox_layer := 0b0100_0010_0000_0000
@export_flags_2d_physics var grazebox_layer := 0b0000_0001_0000_0000


func set_texture(sprite : Sprite2D) -> void:
	sprite.texture = texture
	sprite.hframes = hframes
	sprite.vframes = vframes
	sprite.frame = frame
	sprite.frame_coords = frame_coords
