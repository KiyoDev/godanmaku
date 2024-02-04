
class_name DelayLaserPattern extends DanmakuPattern


@export_group("Laser Settings")
@export var spawn_count : int = 1
@export var origin_offset : int = 1
@export var warning_time : int = 60

@export_group("Stack Settings")
@export var stacks : int = 1
@export var stack_velocity : int = 0.0

@export_group("Spread Settings")
@export var spread : int = 1
@export var spread_degrees : float = 0.0

var pattern_origin : Vector2

func _handle_pattern(delta : float) -> int:
	var fire_direction : Vector2
	var angle : float
	var fire_origin : Vector2
	var v : int
	var pos = global_position
	# calculate origin offset
	pattern_origin = Vector2(pos.x + (origin_offset * cos(360.0/spawn_count)), pos.y + (origin_offset * sin(360.0/spawn_count)))
	var spread_rad : float = spread_degrees * PI / 180 # angle to shoot spread
	var start_angle = angle_to_player() if chase else (fire_angle * PI / 180) # angle of main bullet to fire
	start_angle = start_angle if spread % 2 != 0 else start_angle + (spread_rad / 2)
	var radians : float = 2 * PI / spawn_count # convert to radians for function params
	# spawn stacks of rings
	for stack in range(1, stacks + 1):
		v = velocity + (stack_velocity * stack)
		# fire additional ring if should spread from a given line
		for i in range(ceil(-spread / 2.0), ceil(spread / 2.0)):
			# spawn all bullets in ring
			for line in range(1, spawn_count + 1):
				# calculate fire angle, taking spread, and angle offset modifiers
				angle = start_angle + (radians * line) + angle_offset + (i * spread_rad)
				fire_origin = pos + (pattern_origin.from_angle(angle) * origin_offset)
				
				var laser = BulletPool.get_next_bullet(get_bullet_data.call(), angle, v, acceleration, fire_origin, bullet_ctrl) as BulletBase
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
	elif laser.up_time == warning_time + 42:
		laser.frame = 4
		laser.enable_collision()
	elif laser.up_time == warning_time + 48:
		laser.frame = 5
	elif laser.up_time == warning_time + 54:
		laser.frame = 6
	elif laser.up_time == warning_time + 60:
		laser.frame = 7
		laser.disable_collision()
	elif laser.up_time == warning_time + 64:
		laser.frame = 8
	elif laser.up_time == warning_time + 68:
		laser.frame = 9
	elif laser.up_time == warning_time + 72:
		laser._disable()
