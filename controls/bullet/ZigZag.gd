@icon("res://addons/godonmaku/icons/zigzag.svg")
class_name ZigZag extends ControlNode


@onready var uptime_key = "zig_zag_%s" % self.get_instance_id()
@onready var pause_key = "zig_zag_pause_%s" % self.get_instance_id()
@onready var pause_time_key = "zig_zag_pause_time_%s" % self.get_instance_id()
@onready var radians_key = "zig_zag_radians_%s" % self.get_instance_id()


## How many frames to alternate zig zag
@export_range(1, 16383) var frames : int = 30
## Bullet angle modifier in degrees
@export var angle : float = 0
## How many frames should zig zag for
@export var duration : int = 0

## Used to delay bullet movement upon trying to change angles
@export_group("Delay Settings")
## Delay upon reaching the point to switch
@export_range(0, 16383) var delay : int = 0
@export var velocity : int = 0



func _before_update(bullet : BulletBase, bulletin_board : BulletinBoard) -> void:
	super._before_update(bullet, bulletin_board)
	bulletin_board.set_value(uptime_key, 0)
	if delay > 0:
		bulletin_board.set_value(pause_key, false)
		bulletin_board.set_value(pause_time_key, 0)
		bulletin_board.set_value(radians_key, (angle * PI / 180))


func _set_custom_update(bullet : BulletBase, bulletin_board : BulletinBoard) -> void:
	_before_update(bullet, bulletin_board)
	bullet.custom_update = _custom_update


func _custom_update(delta : float, bullet : BulletBase, bulletin_board : BulletinBoard) -> int:
	# stop zig zag
	if duration > 0 and bulletin_board.get_value(uptime_key) >= duration:
		return SUCCESS
	
	if delay > 0:
		if !bulletin_board.get_value(pause_key):
			if bulletin_board.get_value(uptime_key) > 0 and (bulletin_board.get_value(uptime_key) % (2 * frames) == frames or bulletin_board.get_value(uptime_key) % (2 * frames) == 0):
				bullet.angle += bulletin_board.get_value(radians_key)
				bulletin_board.set_value(radians_key, -bulletin_board.get_value(radians_key))
				bulletin_board.set_value(pause_key, true)
				bullet.stop()
			
			bulletin_board.set_value(uptime_key, bulletin_board.get_value(uptime_key) + 1)
		else:
			bulletin_board.set_value(pause_time_key, bulletin_board.get_value(pause_time_key) + 1)
			
		if bulletin_board.get_value(pause_time_key) > 0 and bulletin_board.get_value(pause_time_key) % delay == 0:
			bulletin_board.set_value(pause_key, false)
			bulletin_board.set_value(pause_time_key, 0)
			bullet.resume()
			if velocity != 0:
				bullet.velocity = velocity
	else:
		if bulletin_board.get_value(uptime_key) % (2 * frames) == frames:
			bullet.angle -= (angle * PI / 180)
			
		if bulletin_board.get_value(uptime_key) % (2 * frames) == 0:
			bullet.angle += (angle * PI / 180)
			
		bulletin_board.set_value(uptime_key, bulletin_board.get_value(uptime_key) + 1)
	return RUNNING
