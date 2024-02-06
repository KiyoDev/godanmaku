class_name Sequence extends ControlNode


@onready var instance_key = "sequence_%s" % self.get_instance_id()


func _before_update(bullet : BulletBase, bulletin_board : BulletinBoard) -> void:
	bulletin_board.set_value(instance_key, 0)
	get_child(0)._before_update(bullet, bulletin_board)


func _set_custom_update(bullet : BulletBase, bulletin_board : BulletinBoard) -> void:
	_before_update(bullet, bulletin_board)
	#for child in get_children().filter(func(c): return c is ControlNode):
		#child._before_update(bullet, bulletin_board)
	bullet.custom_update = _custom_update


func _custom_update(delta : float, bullet : BulletBase, bulletin_board : BulletinBoard) -> int:
	var child : ControlNode = get_child(bulletin_board.get_value(instance_key, 0))
	var status : int = child._custom_update.call(delta, bullet, bulletin_board)
	
	if status == SUCCESS:
		bulletin_board.set_value(instance_key, wrapi(bulletin_board.get_value(instance_key, 0) + 1, 0, get_child_count()))
	
		if bulletin_board.get_value(instance_key, 0) == get_child_count():
			bulletin_board.set_value(instance_key, 0)
			return SUCCESS
		
		get_child(bulletin_board.get_value(instance_key, 0))._before_update(bullet, bulletin_board)
	
	return RUNNING


