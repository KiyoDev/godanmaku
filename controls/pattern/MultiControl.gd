class_name MultiControl extends PatternControl



func _before_set(pattern : DanmakuPattern, bulletin_board : BulletinBoard) -> void:
	for c in get_children().filter(func(c): return c is PatternControl):
		c._before_set(pattern, bulletin_board)


func _set_custom_repeat(pattern : DanmakuPattern, bulletin_board : BulletinBoard) -> void:
	_before_set(pattern, bulletin_board)
	pattern.custom_repeat = _custom_repeat


func _custom_repeat(delta : float, pattern : DanmakuPattern, bulletin_board : BulletinBoard) -> int:
	for c in get_children().filter(func(c): return c is PatternControl):
		c._custom_repeat(delta, pattern, bulletin_board)
	return RUNNING
