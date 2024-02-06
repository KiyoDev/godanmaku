## Shoots lasers that have a delay and show a warning before actually firing
class_name DelayLaserPattern extends DanmakuPattern


@export_group("Laser Settings")
@export var spawn_count : int = 1
@export var warning_time : int = 60
@export var variable_angle : bool = true

var pattern_origin : Vector2


func _handle_pattern(delta : float) -> int:
	var fire_direction : Vector2
	var angle : float
	var v : int
	pattern_origin = (player_position() if angle_type == Angle.CHASE_PLAYER else global_position)
	pattern_origin = Vector2(pattern_origin.x + randi_range(-origin_offset, origin_offset), pattern_origin.y + randi_range(-origin_offset, origin_offset))
	
	var start_angle : float
	if variable_angle:
		start_angle = randf_range(0, 359) * PI / 180
	else:
		start_angle = angle_to_player(pattern_origin) if angle_type == Angle.CHASE_PLAYER else angle_to_target(pattern_origin, target) if angle_type == Angle.TARGET else (fire_angle * PI / 180) # angle of main bullet to fire
	for line in range(1, spawn_count + 1):
		angle = start_angle + angle_offset
		var laser = BulletPool.get_next_bullet(get_bullet_data.call(), angle, v, acceleration, pattern_origin, bullet_ctrl, instance_key) as BulletBase
		laser.disable_collision()
		laser.animation_update = custom_animation_update
		laser.fire()
	return SUCCESS


func custom_animation_update(delta : float, laser : BulletBase, bulletin_board : BulletinBoard) -> void:
	#laser.ani_time += 1
	if laser.up_time == warning_time:
		laser.frame = 2
	elif laser.up_time == warning_time + 4:
		laser.frame = 3
	elif laser.up_time == warning_time + 12:
		laser.frame = 2
	elif laser.up_time == warning_time + 18:
		laser.frame = 1
	elif laser.up_time == warning_time + 40: # Actual laser hit frame
		laser.frame = 4
	elif laser.up_time == warning_time + 46:
		laser.frame = 5
		laser.enable_collision()
	elif laser.up_time == warning_time + 52:
		laser.frame = 6
		laser.disable_collision()
	elif laser.up_time == warning_time + 58: # end hit collision
		laser.frame = 7
	elif laser.up_time == warning_time + 60:
		laser.frame = 8
	elif laser.up_time == warning_time + 62:
		laser.frame = 9
	elif laser.up_time == warning_time + 66:
		laser._disable()
