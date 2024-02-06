class_name PatternSequence extends PatternControl


@onready var instance_key = "pattern_sequence_%s" % self.get_instance_id()

## Angle in degrees
@export var angle : int = 0
## How many repeats to spin the pattern. 0 = indefinitely
@export var repeats : int = 0


func _before_set(pattern : DanmakuPattern, bulletin_board : BulletinBoard) -> void:
	bulletin_board.set_value(instance_key, 0)


func _set_custom_update(pattern : DanmakuPattern, bulletin_board : BulletinBoard) -> void:
	_before_set(pattern, bulletin_board)
	pattern.custom_update = _custom_update


func _set_custom_repeat(pattern : DanmakuPattern, bulletin_board : BulletinBoard) -> void:
	_before_set(pattern, bulletin_board)
	pattern.custom_repeat = _custom_repeat


func _custom_repeat(delta : float, pattern : DanmakuPattern, bulletin_board : BulletinBoard) -> int:
	var child : PatternControl = get_child(bulletin_board.get_value(instance_key, 0))
	var status : int = child._custom_update.call(delta, pattern, bulletin_board)
	
	if status == SUCCESS:
		bulletin_board.set_value(instance_key, wrapi(bulletin_board.get_value(instance_key, 0) + 1, 0, get_child_count()))
	
		if bulletin_board.get_value(instance_key, 0) == get_child_count():
			bulletin_board.set_value(instance_key, 0)
			return SUCCESS
		
		get_child(bulletin_board.get_value(instance_key, 0))._before_set(pattern, bulletin_board)
	return RUNNING
