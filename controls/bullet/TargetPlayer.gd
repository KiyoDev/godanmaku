class_name TargetPlayer extends ControlNode


@onready var instance_key = "target_player_%s" % self.get_instance_id()


## New velocity
@export var velocity : int = 0
## New acceleration
@export var acceleration : int = 0
@export var bring_to_front : bool = false
## How many frames should move for. -1 goes forever
@export var duration : int = 60


func _before_update(bullet : BulletBase, bulletin_board : BulletinBoard) -> void:
	bulletin_board.set_value(instance_key, 0)
	bullet.angle = bullet.global_position.angle_to_point(Godanmaku.get_player().global_position)
	if velocity > 0:
		bullet.velocity = velocity
	bullet.acceleration = acceleration
	if alt_bullet_data:
		bullet.directed = alt_bullet_data.directed
	bullet.update_rotation()
	if alt_bullet_data:
		bullet._swap_data(alt_bullet_data)
	if alt_bullet_data:
		bullet.move_to_front()
	# TODO: fix updating the angle -> rotation -> swapping the texture
	#super._before_update(bullet, bulletin_board)


func _set_custom_update(bullet : BulletBase, bulletin_board : BulletinBoard) -> void:
	_before_update(bullet, bulletin_board)
	bullet.custom_update = _custom_update


func _custom_update(delta : float, bullet : BulletBase, bulletin_board : BulletinBoard) -> int:
	#if bulletin_board.get_value(instance_key) == 0:
		#bullet.angle += angle * PI / 180.0
		#bullet.velocity = velocity
		#bullet.acceleration = acceleration
		#bullet.update_rotation()
		
	if duration >= 0 and bulletin_board.get_value(instance_key) >= duration or bullet.velocity == 0:
		return SUCCESS
	
	#bullet.position_offset = Vector2(cos(bullet.angle), sin(bullet.angle)).orthogonal() * sin(bulletin_board.get_value(instance_key) * delta * frequency) * amplitude
	
	if duration > 0:
		bulletin_board.set_value(instance_key, bulletin_board.get_value(instance_key) + 1)
	return RUNNING
