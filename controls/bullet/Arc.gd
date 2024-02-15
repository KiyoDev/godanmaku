@icon("res://addons/godanmaku/icons/arc.svg")
class_name Arc extends ControlNode


@onready var instance_key = "arc_%s" % self.get_instance_id()


## Bullet angle modifier in degrees
@export var angle : float = 0
## New velocity
@export var velocity : int = 0
## New acceleration
@export var acceleration : int = 0
## How many frames should zig zag for
@export var duration : int = 0


func _before_update(bullet : BulletBase, bulletin_board : BulletinBoard) -> void:
	super._before_update(bullet, bulletin_board)
	bulletin_board.set_value(instance_key, 0)
	if velocity != 0:
		bullet.velocity = velocity
	bullet.acceleration = acceleration


func _set_custom_update(bullet : BulletBase, bulletin_board : BulletinBoard) -> void:
	_before_update(bullet, bulletin_board)
	bullet.custom_update = _custom_update


func _custom_update(delta : float, bullet : BulletBase, bulletin_board : BulletinBoard) -> int:
	var f = bulletin_board.get_value(instance_key)
	if duration > 0 and f >= duration:
		return SUCCESS
	
	bullet.angle += (angle * PI / 180)  * delta
	
	if duration > 0:
		bulletin_board.set_value(instance_key, f + 1)
	return RUNNING
