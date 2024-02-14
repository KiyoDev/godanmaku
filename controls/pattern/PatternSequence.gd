class_name PatternSequence extends PatternControl


@onready var instance_key = "pattern_sequence_index_%s" % self.get_instance_id()
@onready var count_key = "pattern_sequence_repeats_%s" % self.get_instance_id()


## How many repeats to spin the pattern. 0 = indefinitely
@export var repeats : int = 0


func _before_set(pattern : DanmakuPattern, bulletin_board : BulletinBoard) -> void:
	bulletin_board.set_value(instance_key, 0)
	bulletin_board.set_value(count_key, 0)
	get_child(bulletin_board.get_value(instance_key))._before_set(pattern, bulletin_board)


func _set_custom_update(pattern : DanmakuPattern, bulletin_board : BulletinBoard) -> void:
	_before_set(pattern, bulletin_board)
	pattern.custom_update = _custom_update


func _set_custom_repeat(pattern : DanmakuPattern, bulletin_board : BulletinBoard) -> void:
	_before_set(pattern, bulletin_board)
	pattern.custom_repeat = _custom_repeat


func _custom_repeat(delta : float, pattern : DanmakuPattern, bulletin_board : BulletinBoard) -> int:
	var child : PatternControl = get_child(bulletin_board.get_value(instance_key))
	var status : int = child._custom_repeat.call(delta, pattern, bulletin_board)
	if status == SUCCESS:
		if bulletin_board.get_value(count_key) == repeats:
			bulletin_board.set_value(count_key, 0)
			bulletin_board.set_value(instance_key, wrapi(bulletin_board.get_value(instance_key) + 1, 0, get_child_count()))
			
			if bulletin_board.get_value(instance_key) == get_child_count():
				bulletin_board.set_value(instance_key, 0)
				return SUCCESS
			
			get_child(bulletin_board.get_value(instance_key))._before_set(pattern, bulletin_board)
		bulletin_board.set_value(count_key, bulletin_board.get_value(count_key) + 1)
	return RUNNING
