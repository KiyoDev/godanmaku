class_name RingPattern extends DanmakuPattern


@export var spawn_count : int = 1
## Angle offset of fire origin
#@export var angle_offset := PI
@export var origin_offset : int = 1

@export var ctrl : ControlNode

@export_group("Stack Settings")
@export var stacks : int = 1
@export var stack_velocity : float = 0.0

@export_group("Spread Settings")
@export var spread : int = 1
@export var spread_degrees : float = 0.0

var pattern_origin : Vector2


func _handle_pattern(delta : float) -> void:
	var pos = global_position
	pattern_origin = Vector2(pos.x + (origin_offset * cos(360.0/spawn_count)), pos.y + (origin_offset * sin(360.0/spawn_count)))
	var spread_rad : float = spread_degrees * PI / 180
	var start_angle = angle_to_player() if chase else fire_angle
	start_angle = start_angle if spread % 2 != 0 else start_angle + (spread_rad / 2)
	var radians : float = 2 * PI / spawn_count # convert to radians for function params
	# stacks
	for stack in range(1, stacks + 1):
		var v = velocity + (velocity * stack_velocity * stack)
		# fire additional ring if should spread from a given line
		for i in range(ceil(-spread / 2.0), ceil(spread / 2.0)):
			var fire_direction : Vector2
			var angle : float
			var fire_origin : Vector2
			var bullet : BulletBase
			#print("i=%s, %s, %s, %s" % [i, 1 + (i * spread_rad), direction, dir])
			print("spawn_count=", spawn_count)
			for line in range(1, spawn_count + 1):
				angle = start_angle + (radians * line) + angle_offset + (i * spread_rad)
				fire_origin = pos + (pattern_origin.from_angle(angle) * origin_offset)
				
				bullet = BulletPool.get_next_bullet(bullet_data, angle, v, acceleration, fire_origin) as BulletBase
				if ctrl:
					ctrl._set_custom_update(bullet, bullet.bulletin_board)
				bullet.fire()
