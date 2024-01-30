class_name BulletData extends Resource

@export_group("Sprite Texture")
@export var texture : Texture2D
@export_subgroup("Animation")
@export var hframes : int = 0
@export var vframes : int = 0
@export var frame : int = 0
@export var frame_coords : Vector2 = Vector2.ZERO
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
