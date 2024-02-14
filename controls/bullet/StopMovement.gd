class_name StopMovement extends ControlNode


@onready var instance_key = "stop_movement_%s" % self.get_instance_id()

## How many frames to wait
@export var duration : int = 60



func _before_update(bullet : BulletBase, bulletin_board : BulletinBoard) -> void:
	super._before_update(bullet, bulletin_board)
	bulletin_board.set_value(instance_key, 0)


func _set_custom_update(bullet : BulletBase, bulletin_board : BulletinBoard) -> void:
	_before_update(bullet, bulletin_board)
	bullet.custom_update = _custom_update


func _custom_update(delta : float, bullet : BulletBase, bulletin_board : BulletinBoard) -> int:
	if duration > 0 and bulletin_board.get_value(instance_key) >= duration:
		return SUCCESS
	
	bullet.stop()
	
	bulletin_board.set_value(instance_key, bulletin_board.get_value(instance_key) + 1)
	return RUNNING
