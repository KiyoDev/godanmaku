class_name Sequence extends ControlNode


@onready var instance_key = "sequence_%s" % self.get_instance_id()
@onready var child_key = "sequence_child_%s" % self.get_instance_id()


func _before_update(bullet : BulletBase, bulletin_board : BulletinBoard) -> void:
	bulletin_board.set_value(child_key, get_child(0))
	bulletin_board.set_value(instance_key, 0)
	get_child(0)._before_update(bullet, bulletin_board)


func _set_custom_update(bullet : BulletBase, bulletin_board : BulletinBoard) -> void:
	_before_update(bullet, bulletin_board)
	#for child in get_children().filter(func(c): return c is ControlNode):
		#child._before_update(bullet, bulletin_board)
	bullet.custom_update = _custom_update


func _custom_update(delta : float, bullet : BulletBase, bulletin_board : BulletinBoard) -> int:
	#var i : int = bulletin_board.get_value(instance_key)
	var child : ControlNode = bulletin_board.get_value(child_key)
	#var child : ControlNode = get_child(i)
	
	if child._custom_update(delta, bullet, bulletin_board) == SUCCESS:
		var i : int = wrapi(child.get_index() + 1, 0, get_child_count())
		var next : ControlNode = get_child(i)
		bulletin_board.set_value(child_key, next)
		if i == get_child_count():
			return SUCCESS
		next._before_update(bullet, bulletin_board)
		#var next : int = wrapi(child.get_index() + 1, 0, get_child_count())
		#bulletin_board.set_value(instance_key, next)
	#
		#if i == get_child_count() - 1:
			#bulletin_board.set_value(instance_key, 0)
			#return SUCCESS
		#
		#get_child(next)._before_update(bullet, bulletin_board)
	
	return RUNNING


