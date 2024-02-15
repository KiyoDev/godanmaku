class_name PauseMovement extends ControlNode


@onready var instance_key = "pause_movement_%s" % self.get_instance_id()

## How many frames to wait
@export var duration : int = 60



func _before_update(bullet : BulletBase, bulletin_board : BulletinBoard) -> void:
	super._before_update(bullet, bulletin_board)
	bulletin_board.set_value(instance_key, 0)


func _set_custom_update(bullet : BulletBase, bulletin_board : BulletinBoard) -> void:
	_before_update(bullet, bulletin_board)
	bullet.custom_update = _custom_update


func _custom_update(delta : float, bullet : BulletBase, bulletin_board : BulletinBoard) -> int:
	var up_time : int = bulletin_board.get_value(instance_key)
	# resume
	if duration > 0 and up_time >= duration:
		bullet.resume()
		return SUCCESS
	
	bullet.stop()
	
	if duration > 0:
		bulletin_board.set_value(instance_key, up_time + 1)
	return RUNNING
