class_name PatternSpin extends PatternControl


@onready var repeat_key = "pattern_spin_repeats_%s" % self.get_instance_id()
#@onready var count_key = "pattern_spin_repeats_%s" % self.get_instance_id()

## Angle in degrees
@export var angle : float = 0
## How many repeats to spin the pattern. 0 = indefinitely
@export var repeats : int = 0


func _before_set(pattern : DanmakuPattern, bulletin_board : BulletinBoard) -> void:
	bulletin_board.set_value(repeat_key, 0)
	if sub_control:
		sub_control._before_set(pattern, bulletin_board)


func _set_custom_update(pattern : DanmakuPattern, bulletin_board : BulletinBoard) -> void:
	_before_set(pattern, bulletin_board)
	pattern.custom_update = _custom_update


func _set_custom_repeat(pattern : DanmakuPattern, bulletin_board : BulletinBoard) -> void:
	_before_set(pattern, bulletin_board)
	pattern.custom_repeat = _custom_repeat


func _custom_repeat(delta : float, pattern : DanmakuPattern, bulletin_board : BulletinBoard) -> int:
	if repeats > 0 and bulletin_board.get_value(repeat_key) >= repeats:
		bulletin_board.set_value(repeat_key, 0)
		return SUCCESS
	
	pattern.angle_offset += (angle * PI / 180)
	
	bulletin_board.set_value(repeat_key, bulletin_board.get_value(repeat_key) + 1)
	
	if sub_control:
		sub_control._custom_repeat(delta, pattern, bulletin_board)
	return RUNNING
