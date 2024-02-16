extends Node2D


@export var patterns : Array[Danmaku] = []


func _input(event: InputEvent) -> void:
	if not event is InputEventKey and not event is InputEventAction and not event is InputEventJoypadButton and not event is InputEventJoypadMotion: return
	
	# debugging
	var just_pressed : bool = event.is_pressed() and not event.is_echo()
	if Input.is_key_pressed(KEY_1) and just_pressed:
		patterns[0].fire()
