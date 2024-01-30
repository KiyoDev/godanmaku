class_name Sequence extends ControlNode


var sequence_index : int = 0


func _set_custom_update(bullet : BulletBase, bulletin_board : BulletinBoard) -> void:
	for child in get_children().filter(func(c): return c is ControlNode):
		child._before_update(bullet, bulletin_board)
	bullet.custom_update = _custom_update


func _custom_update(delta : float, bullet : BulletBase, bulletin_board : BulletinBoard) -> int:
	var status : int = get_child(sequence_index)._custom_update.call(delta, bullet, bulletin_board)
	
	if status == SUCCESS:
		sequence_index += 1
	
		if sequence_index == get_child_count():
			sequence_index = 0
			return SUCCESS
		
		get_child(sequence_index)._before_update(bullet, bulletin_board)
	
	return RUNNING


