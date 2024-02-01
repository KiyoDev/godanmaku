@icon("res://addons/godonmaku/icons/zigzag.svg")
class_name ZigZag extends ControlNode


@onready var cache_key = "zig_zag_%s" % self.get_instance_id()


## How many frames to alternate zig zag
@export var frames : int = 30
## Bullet angle modifier in degrees
@export var angle : float = 0
## How many frames should zig zag for
@export var duration : int = 0


func _before_update(bullet : BulletBase, bulletin_board : BulletinBoard) -> void:
	super._before_update(bullet, bulletin_board)
	bulletin_board.set_value(cache_key, 0)


func _set_custom_update(bullet : BulletBase, bulletin_board : BulletinBoard) -> void:
	_before_update(bullet, bulletin_board)
	bullet.custom_update = _custom_update


func _custom_update(delta : float, bullet : BulletBase, bulletin_board : BulletinBoard) -> int:
	# stop zig zag
	if duration > 0 and bulletin_board.get_value(cache_key, 0) >= duration:
		return SUCCESS
	
	if bullet.up_time % (2 * frames) == 0:
		bullet.angle += (angle * PI / 180)
		
	if bullet.up_time % (2 * frames) == frames:
		bullet.angle -= (angle * PI / 180)
	
	bulletin_board.set_value(cache_key, bulletin_board.get_value(cache_key) + 1)
	return RUNNING
