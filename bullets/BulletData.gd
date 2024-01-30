class_name BulletData extends Resource


@export var texture : Texture2D
@export var shape : Shape2D

@export_flags_2d_physics var hitbox_layer := 0b0100_0010_0000_0000
@export_flags_2d_physics var grazebox_layer := 0b0000_0001_0000_0000
