class_name AlternateOnRepeat extends ControlNode


#@onready var instance_key = "alternate_on_repeat_%s" % self.get_instance_id()


func _before_update(bullet : BulletBase, bulletin_board : BulletinBoard) -> void:
	get_child(0)._before_update(bullet, bulletin_board)


func _set_custom_update(bullet : BulletBase, bulletin_board : BulletinBoard) -> void:
	_before_update(bullet, bulletin_board)
	#get_child(0)._before_update(bullet, bulletin_board)
	bullet.custom_update = _custom_update


func _custom_update(delta : float, bullet : BulletBase, bulletin_board : BulletinBoard) -> int:
	var index : int = (bullet.pattern.call_count - 1) % get_child_count()
	var control : ControlNode = get_child(index)
	
	control._before_update(bullet, bulletin_board)
	
	var status : int = control._custom_update.call(delta, bullet, bulletin_board)
	
	if status == SUCCESS:
		return SUCCESS
		#bulletin_board.set_value(instance_key, bulletin_board.get_value(instance_key, 0) + 1)
	#
		#if bulletin_board.get_value(instance_key, 0) == get_child_count():
			#bulletin_board.set_value(instance_key, 0)
			#return SUCCESS
		#
		#get_child(bulletin_board.get_value(instance_key, 0))._before_update(bullet, bulletin_board)
	
	return RUNNING


