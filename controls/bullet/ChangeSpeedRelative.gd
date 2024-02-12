class_name ChangeSpeedRelative extends ControlNode


@onready var instance_key = "change_speed_%s" % self.get_instance_id()


## New velocity
@export var velocity_multiplier : float = 1.0
## New acceleration
@export var acceleration_multiplier : float = 0
## How many frames should zig zag for
@export var duration : int = 0


func _before_update(bullet : BulletBase, bulletin_board : BulletinBoard) -> void:
	super._before_update(bullet, bulletin_board)
	bulletin_board.set_value(instance_key, 0)
	if velocity_multiplier != 0:
		bullet.velocity *= velocity_multiplier
	bullet.acceleration *= acceleration_multiplier


func _set_custom_update(bullet : BulletBase, bulletin_board : BulletinBoard) -> void:
	_before_update(bullet, bulletin_board)
	bullet.custom_update = _custom_update


func _custom_update(delta : float, bullet : BulletBase, bulletin_board : BulletinBoard) -> int:
	if duration > 0 and bulletin_board.get_value(instance_key) >= duration:
		return SUCCESS
	
	bulletin_board.set_value(instance_key, bulletin_board.get_value(instance_key) + 1)
	return RUNNING
