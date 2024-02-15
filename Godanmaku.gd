extends Node

## Emitted when need to disable all active bullets
signal disable_active_bullets


var player : Node2D:
	get = get_player


func get_player() -> Node2D:
	if !player:
		push_error("Player not found. Please make sure the player has been properly registered")
	return player


func register_player(new_player : Node2D) -> void:
	if !new_player: return
	
	player = new_player
