class_name Sequence extends ControlNode


@onready var cache_key = "sequence_%s" % self.get_instance_id()


func _before_update(bullet : BulletBase, bulletin_board : BulletinBoard) -> void:
	bulletin_board.set_value(cache_key, 0)


func _set_custom_update(bullet : BulletBase, bulletin_board : BulletinBoard) -> void:
	_before_update(bullet, bulletin_board)
	for child in get_children().filter(func(c): return c is ControlNode):
		child._before_update(bullet, bulletin_board)
	bullet.custom_update = _custom_update


func _custom_update(delta : float, bullet : BulletBase, bulletin_board : BulletinBoard) -> int:
	var status : int = get_child(bulletin_board.get_value(cache_key))._custom_update.call(delta, bullet, bulletin_board)
	
	if status == SUCCESS:
		bulletin_board.set_value(cache_key, bulletin_board.get_value(cache_key) + 1)
	
		if bulletin_board.get_value(cache_key) == get_child_count():
			bulletin_board.set_value(cache_key, 0)
			return SUCCESS
		
		get_child(bulletin_board.get_value(cache_key))._before_update(bullet, bulletin_board)
	
	return RUNNING


