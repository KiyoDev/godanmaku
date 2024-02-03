@tool
extends EditorPlugin

var frames: RefCounted

func _init():
	name = "GodanmakuPlugin"
	add_autoload_singleton("BulletPool", "bullets/BulletPool.gd")
	print("Godanmaku initialized")


func _enter_tree() -> void:
	pass


func _exit_tree() -> void:
	pass
