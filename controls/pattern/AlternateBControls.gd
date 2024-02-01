class_name AlternateBControls extends PatternControl


@onready var time_key = "alternate_bullet_control_time_%s" % self.get_instance_id()
@onready var index_key = "alternate_bullet_control_index_%s" % self.get_instance_id()


## How many repeats to alternate reverse
@export var repeats : int = 30
## How many frames should alternate
@export var duration : int = 0


func _before_set(pattern : DanmakuPattern, bulletin_board : BulletinBoard) -> void:
	bulletin_board.set_value(time_key, 0)
	bulletin_board.set_value(index_key, clampi(1, 0, get_child_count()))
	pattern.bullet_ctrl = get_child(0)


func _set_custom_update(pattern : DanmakuPattern, bulletin_board : BulletinBoard) -> void:
	_before_set(pattern, bulletin_board)
	pattern.custom_update = _custom_update


func _set_custom_repeat(pattern : DanmakuPattern, bulletin_board : BulletinBoard) -> void:
	_before_set(pattern, bulletin_board)
	pattern.custom_repeat = _custom_repeat


func _custom_repeat(delta : float, pattern : DanmakuPattern, bulletin_board : BulletinBoard) -> int:
	if duration > 0 and bulletin_board.get_value(time_key) >= duration:
		return SUCCESS
	
	if (bulletin_board.get_value(time_key) % repeats) == 0:
		var i : int = wrapi(bulletin_board.get_value(index_key), 0, get_child_count())
		pattern.bullet_ctrl = get_child(i)
		bulletin_board.set_value(index_key, i + 1)
		
	#if bulletin_board.get_value(time_key) % (2 * frames) == frames:
		#reverse = false
		#bulletin_board.set_value(index_key, wrapi())
	
	bulletin_board.set_value(time_key, bulletin_board.get_value(time_key) + 1)
	return RUNNING
