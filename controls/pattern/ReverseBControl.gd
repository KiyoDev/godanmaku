class_name ReverseBControl extends PatternControl


@onready var reverse_key = "reverse_bullet_control_%s" % self.get_instance_id()
@onready var timer_key = "reverse_bullet_control_time_%s" % self.get_instance_id()


## How many frames to alternate reverse
@export var frames : int = 30
## How many frames should alternate
@export var duration : int = 0


var reverse : bool = true


func _before_set(pattern : DanmakuPattern, bulletin_board : BulletinBoard) -> void:
	bulletin_board.set_value(reverse_key, true)
	bulletin_board.set_value(timer_key, 0)


func _set_custom_update(pattern : DanmakuPattern, bulletin_board : BulletinBoard) -> void:
	_before_set(pattern, bulletin_board)
	pattern.custom_update = _custom_update


func _set_custom_repeat(pattern : DanmakuPattern, bulletin_board : BulletinBoard) -> void:
	_before_set(pattern, bulletin_board)
	pattern.custom_repeat = _custom_repeat


func _custom_repeat(delta : float, pattern : DanmakuPattern, bulletin_board : BulletinBoard) -> int:
	if duration > 0 and bulletin_board.get_value(reverse_key) >= duration:
		return SUCCESS
	
	if bulletin_board.get_value(timer_key) % (2 * frames) == 0:
		reverse = true
		
	if bulletin_board.get_value(timer_key) % (2 * frames) == frames:
		reverse = false
	
	bulletin_board.set_value(reverse_key, reverse)
	bulletin_board.set_value(timer_key, bulletin_board.get_value(reverse_key) + 1)
	return RUNNING
