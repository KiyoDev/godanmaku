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
	if bulletin_board.get_value(instance_key) >= duration:
		return SUCCESS
	
	#bullet.position_offset = Vector2(cos(bullet.angle), sin(bullet.angle)).orthogonal() * sin(bulletin_board.get_value(instance_key) * delta * frequency) * amplitude
	
	bulletin_board.set_value(instance_key, bulletin_board.get_value(instance_key) + 1)
	return RUNNING