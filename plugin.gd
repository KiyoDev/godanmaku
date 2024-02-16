@tool
extends EditorPlugin

var frames: RefCounted

func _init():
	name = "GodanmakuPlugin"
	add_autoload_singleton("BulletPool", "bullets/BulletPool.gd")
	add_autoload_singleton("Godanmaku", "Godanmaku.gd")
	#add_autoload_singleton("BulletArea", "res://addons/godanmaku/bullets/shared_area.tscn")
	print("Godanmaku initialized")


func _enter_tree() -> void:
	pass


#func _exit_tree() -> void:
	#remove_autoload_singleton("BulletArea")
