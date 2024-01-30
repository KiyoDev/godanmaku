class_name RingPattern extends DanmakuPattern


@export var spawn_count : int = 1
@export var fire_angle := 0.0
@export var spread := 1
@export var spread_degrees := 0.0
@export var origin_offset := 1

var pattern_origin : Vector2


func _handle_pattern(delta : float) -> void:
	var pos = global_position
	pattern_origin = Vector2(pos.x + (origin_offset * cos(360.0/spawn_count)), pos.y + (origin_offset * sin(360.0/spawn_count)))
	#print("%s vs %s" % [pattern_origin, origin])
	# get spread angle
	var spread_rad : float = spread_degrees * PI / 180
	#var dir_to_target : Vector2 = pos.direction_to(target)
	## odd aims at target, even aims at the sides
	##var direction = dir_to_target.from_angle(dir_to_target.angle() + fire_angle) if spread % 2 != 0 else dir_to_target.from_angle(dir_to_target.angle() + fire_angle + (spread_rad / 2))
	#var direction = dir_to_target if spread % 2 != 0 else dir_to_target.from_angle(dir_to_target.angle() + fire_angle + (spread_rad / 2))
	#var radians : float = 2 * PI / spawn_count # convert to radians for function params
	## stacks
	#for stack in range(1, stacks + 1):
		#var v = velocity + (velocity * velocity_modifier * stack)
		## fire additional ring if should spread from a given line
		##print("%s - %s = %s" % [ceil(spread / 2.0), ceil(-spread / 2.0), ceil(spread / 2.0) - ceil(-spread / 2.0)])
		#for i in range(ceil(-spread / 2.0), ceil(spread / 2.0)):
			#var fire_direction : Vector2
			#var angle : float
			#var fire_origin : Vector2
			#var bullet : Bullet
			##print("i=%s, %s, %s, %s" % [i, 1 + (i * spread_rad), direction, dir])
			#print("spawn_count=", spawn_count)
			#for line in range(1, spawn_count + 1):
				#bullet = BulletUtil.get_next_bullet(bullet_type)
				#bullet.hitbox_layer = hitbox_layer
				#per_bullet_f.call(bullet)
				#bullet.move_type = move_type
				##print("firing[%s] - %s" % [line, dir.from_angle(dir.angle() + pattern_rot + (radians * line))])
				#angle = (direction.angle() + pattern_rot + radians) + (radians * line)
				#fire_origin = pos + (pattern_origin.from_angle(angle) * origin_offset)
				#fire_direction = pos.from_angle(angle + (i * spread_rad) + ((fire_angle + fire_angle_modifier) * PI / 180))
				##print("%s, %s,%s" % [pattern_origin, origin, pattern_origin + origin.from_angle(angle) * origin_offset])
				#if max_bounces > 0: 
					#bullet.max_bounces = max_bounces
				#if move_type == Bullet.MoveType.CURVE:
					#bullet.curve_angle = curve_angle
				#elif move_type == Bullet.MoveType.WAVE:
					#bullet.frequency = wave_frequency
					#bullet.amplitude = wave_amplitude
				#bullet._fire(fire_origin, fire_direction, v, acceleration, max_velocity)
