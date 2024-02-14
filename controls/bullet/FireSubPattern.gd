class_name FireSubPattern extends ControlNode


@onready var instance_key = "fire_sub_pattern_%s" % self.get_instance_id()

@export var pattern : DanmakuPattern
##
#@export var frames : int = 60



func _before_update(bullet : BulletBase, bulletin_board : BulletinBoard) -> void:
	super._before_update(bullet, bulletin_board)
	#bulletin_board.set_value(instance_key, 0)


func _set_custom_update(bullet : BulletBase, bulletin_board : BulletinBoard) -> void:
	_before_update(bullet, bulletin_board)
	bullet.custom_update = _custom_update


func _custom_update(delta : float, bullet : BulletBase, bulletin_board : BulletinBoard) -> int:
	# resume
	#if bulletin_board.get_value(instance_key) >= frames:
		##bullet.resume()
		#return SUCCESS
	
	#bullet.stop()
	
	#bulletin_board.set_value(instance_key, bulletin_board.get_value(instance_key) + 1)
	var p = pattern.duplicate(0b0111)
	bullet.add_child(p)
	#p.global_position = bullet.global_position
	p.fire()
	p.finished.connect(func(): p.queue_free()) # delete pattern after finishing
	return SUCCESS
