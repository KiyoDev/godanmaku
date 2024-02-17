class_name Delay extends ControlNode


@onready var instance_key = "delay_%s" % self.get_instance_id()


## How many frames should delay for
@export var duration : int = 60


func _before_update(bullet : BulletBase, bulletin_board : BulletinBoard) -> void:
	super._before_update(bullet, bulletin_board)
	bulletin_board.set_value(instance_key, 0)


func _set_custom_update(bullet : BulletBase, bulletin_board : BulletinBoard) -> void:
	_before_update(bullet, bulletin_board)
	bullet.custom_update = _custom_update


func _custom_update(delta : float, bullet : BulletBase, bulletin_board : BulletinBoard) -> int:
	var up_time : int = bulletin_board.get_value(instance_key)
	if duration > 0 and up_time >= duration:
		return SUCCESS
	
	if duration > 0:
		bulletin_board.set_value(instance_key, up_time + 1)
	return RUNNING
