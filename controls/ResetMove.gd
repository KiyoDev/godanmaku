class_name ResetMove extends ControlNode

@onready var cache_key = "reset_move_%s" % self.get_instance_id()

## How many frames should move for
@export var duration : int = 0


func _before_update(bullet : BulletBase, bulletin_board : BulletinBoard) -> void:
	bulletin_board.set_value(cache_key, 0)
	

func _set_custom_update(bullet : BulletBase, bulletin_board : BulletinBoard) -> void:
	_before_update(bullet, bulletin_board)
	bullet.custom_update = _custom_update


func _custom_update(delta : float, bullet : BulletBase, bulletin_board : BulletinBoard) -> int:
	# stop zig zag
	if duration > 0 and bulletin_board.get_value(cache_key) >= duration:
		return SUCCESS
		
	bullet._custom_update(delta, bullet, bulletin_board)
	
	bulletin_board.set_value(cache_key, bulletin_board.get_value(cache_key) + 1)
	return RUNNING
