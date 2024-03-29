class_name BulletPool2D extends Node2D


enum {
	BULLET,
	LASER
}


const MAX_BULLETS := 5000

#@onready var direct_space_state : PhysicsDirectSpaceState2D = get_world_2d().direct_space_state

var bullet_index := 0

var debug_label : Label

func _ready() -> void:
	debug_label = Label.new()
	Godanmaku.add_child(debug_label)
	debug_label.position = Vector2(-32, -170)
	debug_label.z_index = 2000
	#for i in MAX_BULLETS:
		#var b = BulletBase.new()
		#add_child(b)


func _exit_tree() -> void:
	kill_bullets()


func _process(delta: float) -> void:
	debug_label.text = "bullets:%s fps:%s" % [get_child_count(), Engine.get_frames_per_second()]


func get_next_bullet(data : BulletData, angle : float, v : int, a : int, position : Vector2, bullet_ctrl : ControlNode, pattern : DanmakuPattern = null) -> BulletBase:
	var bullet : BulletBase
	if get_child_count() >= MAX_BULLETS:
		bullet_index = (bullet_index + 1) % get_child_count()
		bullet = get_child(bullet_index)
		bullet.before_spawn(pattern, data, angle, v, a, position)
		#active_enemy_bullets.append(bullet)
	else:
		# if not enough bullets, add more
		#while bullet_index >= get_child_count():
			#var b = BulletBase.new()
			#add_child(b)
			#b.before_spawn(pattern, data, angle, v, a, position)
		#while bullet_index >= get_child_count():
		bullet = BulletBase.new()
		add_child(bullet)
		bullet.before_spawn(pattern, data, angle, v, a, position)
		#bullet = get_child(bullet_index)
		#bullet_index += 1
		#active_enemy_bullets.append(b)
	if bullet_ctrl:
		bullet_ctrl._set_custom_update(bullet, bullet.bulletin_board)
	return bullet


#func intersect_shape(query : PhysicsShapeQueryParameters2D, max_results := 1) -> Array[Dictionary]:
	#return direct_space_state.intersect_shape(query, max_results)


func kill_bullets() -> void:
	for child in get_children():
		child.queue_free()
	bullet_index = 0
