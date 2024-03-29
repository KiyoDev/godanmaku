@icon("res://addons/godanmaku/icons/ring.svg")
class_name RingPattern extends DanmakuPattern


@export_group("Ring Settings")
@export var spawn_count : int = 1

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
	var bullet : BulletBase
	var v : int
	var pos : Vector2 = global_position
	var props : Dictionary = {}
	props["bullet_count"] = 0
	# calculate origin offset
	pattern_origin = Vector2(pos.x + (origin_offset * cos(360.0/spawn_count)), pos.y + (origin_offset * sin(360.0/spawn_count)))
	var spread_rad : float = spread_degrees * PI / 180 # angle to shoot spread
	var start_angle = angle_to_player(pos) if angle_type == Angle.CHASE_PLAYER else (fire_angle * PI / 180) # angle of main bullet to fire
	#var start_angle = angle_to_player(pattern_origin) if angle_type == Angle.CHASE_PLAYER else angle_to_target(pattern_origin, target) if angle_type == Angle.TARGET else (fire_angle * PI / 180) # angle of main bullet to fire
	start_angle = start_angle if spread % 2 != 0 else start_angle + (spread_rad / 2)
	var radians : float = 2 * PI / spawn_count # convert to radians for function params
	# spawn stacks of rings
	for stack in range(1, stacks + 1):
		v = velocity + (stack_velocity * stack)
		# fire additional ring if should spread from a given line
		for i in range(ceil(-spread / 2.0), ceil(spread / 2.0)):
			# spawn all bullets in ring
			for line in range(1, spawn_count + 1):
				props["bullet_count"] += 1
				# calculate fire angle, taking spread, and angle offset modifiers
				angle = start_angle + (radians * line) + angle_offset + (i * spread_rad)
				fire_origin = pos + (pattern_origin.from_angle(angle) * origin_offset)
				#print(fire_origin)
				#print(angle_to_target(fire_origin, target))
				bullet = BulletPool.get_next_bullet(bullet_data, angle_to_target(fire_origin, target) if angle_type == Angle.TARGET else angle, v, acceleration, fire_origin, bullet_ctrl, self)
				custom_modify_bullet.call(bullet, props, bulletin_board)
				bullet.fire()
	return SUCCESS
