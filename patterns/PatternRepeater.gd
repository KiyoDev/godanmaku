class_name PatternRepeater extends DanmakuPattern


var time : int = 0


func _handle_pattern(delta : float) -> int:
	if get_child_count() == 1:
		get_child(0)
	return SUCCESS
