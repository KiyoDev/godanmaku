class_name OriginChase extends PatternControl


@onready var repeat_key = "origin_chase_repeats_%s" % self.get_instance_id()

## How many repeats to spin the pattern. 0 = indefinitely
@export var repeats : int = 0


func _before_set(pattern : DanmakuPattern, bulletin_board : BulletinBoard) -> void:
	bulletin_board.set_value(repeat_key, 0)


func _set_custom_update(pattern : DanmakuPattern, bulletin_board : BulletinBoard) -> void:
	_before_set(pattern, bulletin_board)
	pattern.custom_update = _custom_update


func _set_custom_repeat(pattern : DanmakuPattern, bulletin_board : BulletinBoard) -> void:
	_before_set(pattern, bulletin_board)
	pattern.custom_repeat = _custom_repeat


func _custom_repeat(delta : float, pattern : DanmakuPattern, bulletin_board : BulletinBoard) -> int:
	if repeats > 0 and bulletin_board.get_value(repeat_key) >= repeats:
		return SUCCESS
	
	pattern.origin_offset = pattern.global_position.distance_to(pattern.player_position())
	print("d=%s" % [pattern.global_position.distance_to(pattern.player_position())])
	
	bulletin_board.set_value(repeat_key, bulletin_board.get_value(repeat_key) + 1)
	return RUNNING
