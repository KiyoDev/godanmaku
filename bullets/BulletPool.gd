class_name BulletPool2D extends Node2D


const MAX_BULLETS := 10000

@onready var direct_space_state : PhysicsDirectSpaceState2D = get_world_2d().direct_space_state

var bullet_index := 0


func get_next_bullet(data : BulletData, angle : float, v : int, a : int, position : Vector2) -> BulletBase:
	if get_child_count() >= MAX_BULLETS:
		bullet_index = (bullet_index + 1) % get_child_count()
		var bullet : BulletBase = get_child(bullet_index) as BulletBase
		if bullet.texture != data.texture:
			var b = BulletBase.new()
			add_child(b)
			b.before_spawn(data, angle, a, v, position)
			bullet.queue_free()
			bullet = b
		#active_enemy_bullets.append(bullet)
		return bullet
	else:
		# if not enough bullets, add more
		while bullet_index >= get_child_count():
			var b = BulletBase.new()
			add_child(b)
			b.before_spawn(data, angle, a, v, position)
		var b = get_child(bullet_index)
		bullet_index += 1
		#active_enemy_bullets.append(b)
		return b


func intersect_shape(query : PhysicsShapeQueryParameters2D, max_results := 32) -> Array[Dictionary]:
	return direct_space_state.intersect_shape(query, max_results)
