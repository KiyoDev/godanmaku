extends Node


## Emitted when need to disable all active bullets
signal disable_active_bullets


var player : Node2D:
	get = get_player,
	set = register_player
var bullet_area : Area2D:
	get = get_bullet_area


func get_player() -> Node2D:
	if !player:
		push_error("Player not found. Please make sure the player has been properly registered")
	return player


func register_player(new_player : Node2D) -> void:
	if !new_player: return
	player = new_player


func get_bullet_area() -> Area2D:
	return bullet_area


## Used to set the game's playable area. This area determines the border for when bullets should be despawned
func set_bullet_area(path : String) -> void:
	var area_scn : PackedScene = load(path)
	bullet_area = area_scn.instantiate()
	bullet_area.name = "BulletArea"
	get_tree().root.add_child.call_deferred(bullet_area)
