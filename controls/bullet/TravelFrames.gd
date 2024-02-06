class_name TravelFrames extends ControlNode

@onready var instance_key = "travel_distance_%s" % self.get_instance_id()

## Frames of movement
@export var frames : int = 60



func _before_update(bullet : BulletBase, bulletin_board : BulletinBoard) -> void:
	super._before_update(bullet, bulletin_board)
	bulletin_board.set_value(instance_key, 0)


func _set_custom_update(bullet : BulletBase, bulletin_board : BulletinBoard) -> void:
	_before_update(bullet, bulletin_board)
	bullet.custom_update = _custom_update


func _custom_update(delta : float, bullet : BulletBase, bulletin_board : BulletinBoard) -> int:
	# resume
	if bulletin_board.get_value(instance_key) >= frames:
		#bullet.resume()
		return SUCCESS
	
	#bullet.stop()
	
	bulletin_board.set_value(instance_key, bulletin_board.get_value(instance_key) + 1)
	return RUNNING
