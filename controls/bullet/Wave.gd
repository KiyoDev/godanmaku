@icon("res://addons/godanmaku/icons/wave.svg")
class_name Wave extends ControlNode


@onready var instance_key = "wave_%s" % self.get_instance_id()


## Wave amplitude
@export var amplitude : int = 30
## Wave frequency
@export var frequency : float = 0
## How many frames should move for
@export var duration : int = 0


func _before_update(bullet : BulletBase, bulletin_board : BulletinBoard) -> void:
	super._before_update(bullet, bulletin_board)
	bulletin_board.set_value(instance_key, 0)


func _set_custom_update(bullet : BulletBase, bulletin_board : BulletinBoard) -> void:
	_before_update(bullet, bulletin_board)
	bullet.custom_update = _custom_update


func _custom_update(delta : float, bullet : BulletBase, bulletin_board : BulletinBoard) -> int:
	# stop
	if duration > 0 and bulletin_board.get_value(instance_key) >= duration:
		return SUCCESS
	
	bullet.position_offset = Vector2(cos(bullet.angle), sin(bullet.angle)).orthogonal() * sin(bulletin_board.get_value(instance_key) * delta * frequency) * amplitude
	
	if duration > 0:
		bulletin_board.set_value(instance_key, bulletin_board.get_value(instance_key) + 1)
	return RUNNING
