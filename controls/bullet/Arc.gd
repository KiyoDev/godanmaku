@icon("res://addons/godanmaku/icons/arc.svg")
class_name Arc extends ControlNode


@onready var instance_key = "arc_%s" % self.get_instance_id()


## Bullet angle modifier in degrees
@export var angle : float = 0
## How many frames should zig zag for
@export var duration : int = 0


func _before_update(bullet : BulletBase, bulletin_board : BulletinBoard) -> void:
	super._before_update(bullet, bulletin_board)
	bulletin_board.set_value(instance_key, 0)


func _set_custom_update(bullet : BulletBase, bulletin_board : BulletinBoard) -> void:
	_before_update(bullet, bulletin_board)
	bullet.custom_update = _custom_update


func _custom_update(delta : float, bullet : BulletBase, bulletin_board : BulletinBoard) -> int:
	if duration > 0 and bulletin_board.get_value(instance_key) >= duration:
		return SUCCESS
	
	bullet.angle += (angle * PI / 180)  * delta
	
	bulletin_board.set_value(instance_key, bulletin_board.get_value(instance_key) + 1)
	return RUNNING
