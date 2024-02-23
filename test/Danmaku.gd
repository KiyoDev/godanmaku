class_name Danmaku extends Node2D


signal finished


enum {
	RUNNING,
	SUCCESS,
	FINISHED
}

enum Angle {
	FIXED,
	CHASE_PLAYER,
	TARGET
}


@export var angle_type : Angle = Angle.FIXED
@export var target : Node2D
@export var origin_offset : int = 1
## Direction to spawn and aim pattern (in degrees)
@export var fire_angle : int = 180
### Velocity to set for bullets being fired
@export var velocity : int = 100
### Acceleration to set for bullets being fired
@export var acceleration : int = 0
## Bullet data to use when firing bullets
@export var bullet_data : BulletData

@export_group("Pattern Controls")
@export var pattern_ctrl : PatternControl

@export_group("Bullet Controls")
@export var bullet_ctrl : ControlNode

@export_group("Repeat Settings")
## How many times the pattern repeats. 0 means no repeats, -1 means infinite
@export_range(-1, 10000) var max_repeats : int = 0
## How many seconds until the pattern repeats
@export var repeat_time : float = 1.0

@export_group("Sub Patterns")
@export var sub_patterns : Array[DanmakuPattern]

@export_group("Ring Settings")
@export var spawn_count : int = 1

@export_group("Stack Settings")
@export var stacks : int = 1
@export var stack_velocity : int = 0.0

@export_group("Spread Settings")
@export var spread : int = 1
@export var spread_degrees : float = 0.0

var pattern_origin : Vector2

var player : Node2D

var up_time : int = 0
var total_time : int = 0
var repeat_count : int = 0
var can_fire : bool = false
var can_update : bool = false
var angle_offset : float = 0
var call_count : int = 0

var bullets : Array[BulletRef] = []
var boundary : Rect2:
	set = set_boundary

var debug_label : Label

func _ready() -> void:
	player = Godanmaku.get_player()
	set_physics_process(false)
	debug_label = Label.new()
	debug_label.text = "bullets[0]"
	Godanmaku.add_child(debug_label)
	debug_label.z_index = 2000
	debug_label.position = Vector2(0, -150)


func fire() -> void:
	#_handle_pattern()
	can_fire = true
	var coll : CollisionShape2D = Godanmaku.get_bullet_area().get_child(0) as CollisionShape2D
	set_boundary(coll.shape.get_rect())
	#set_boundary(Rect2i(coll.global_position, coll.shape.get_rect().size))
	#print_debug("boundary=%s" % [boundary])
	set_physics_process(true)


func stop() -> void:
	total_time = 0
	repeat_count = 0
	angle_offset = 0
	can_fire = false
	finished.emit()


func set_boundary(rect : Rect2) -> void:
	boundary = rect


func angle_to_player(pattern_origin : Vector2) -> float:
	return pattern_origin.angle_to_point(player.global_position if player else global_position + Vector2.LEFT)


func angle_to_target(pattern_origin : Vector2, target : Node2D) -> float:
	return pattern_origin.angle_to_point(target.global_position if target else global_position + Vector2.LEFT)


func player_position() -> Vector2:
	return player.global_position if player else global_position


func _physics_process(delta: float) -> void:
	var used_transform : Transform2D = Transform2D()
	var destroy_queue : Array[BulletRef] = []
	
	if can_fire:
		if max_repeats == 0:
			_handle_pattern()
			call_count += 1
			stop()
		else:
			if up_time == 0:
				_handle_pattern()
				#custom_repeat.call(delta, self, bulletin_board)
				call_count += 1
			elif max_repeats > 0 and max_repeats <= repeat_count: 
				stop()
				return
			
			if total_time < repeat_time:
				total_time += 1
			else:
				total_time = 0
				repeat_count += 1
				_handle_pattern()
				# Fire sub patterns
				#custom_repeat.call(delta, self, bulletin_board)
				call_count += 1
		
	for i in range(0, bullets.size()):
		var bullet : BulletRef = bullets[i]
		#print("b=%s, %s" % [bullet.position, boundary.has_point(bullet.position)])
		if !boundary.has_point(bullet.position) or (bullet.duration > 0 and bullet.up_time == bullet.duration):
			if !bullet.bounce(boundary):
				destroy_queue.append(bullet)
				continue
		
		bullet.up_time += 1
		bullet.velocity = max(min(bullet.velocity + bullet.acceleration, bullet.max_velocity), 0)
		# Take into consideration angle to arc
		bullet.virtual_position = Vector2(bullet.virtual_position.x + (bullet.velocity * delta) * cos(bullet.angle), bullet.virtual_position.y + (bullet.velocity * delta) * sin(bullet.angle))
		# update rotation of texture and transform if bullet is directed
		# FIXME
		#if directed:
			#look_at(virtual_position)
		
		bullet.position = bullet.virtual_position + bullet.position_offset
		used_transform.origin = bullet.position
		#print("bullet[%s] - pos=%s" % [get_instance_id(), position])
		PhysicsServer2D.area_set_shape_transform(Godanmaku.get_bullet_area().get_rid(), i, used_transform)
	
	for b in destroy_queue:
		#print("destroying - %s" % [b.shape.get_rid()])
		#PhysicsServer2D.free_rid(b.shape.get_rid())
		bullets.erase(b)
	
	up_time += 1
	#print("bullets=%s" % [bullets.size()])
	debug_label.text = "bullets[%s] fps:%s" % [bullets.size(), Engine.get_frames_per_second()]
	queue_redraw()
	#print("area shape count = %s" % PhysicsServer2D.area_get_shape_count(Godanmaku.get_bullet_area().get_rid()))


func _draw() -> void:
	for i in range(0, bullets.size()):
		var bullet : BulletRef = bullets[i]
		draw_texture(bullet.texture, bullet.position)
		#var region_rect : Rect2i = Rect2i(bullet.texture.get_size().x / bullet.hframes * (bullet.frame % bullet.hframes), bullet.texture.get_size().y / bullet.vframes * (bullet.frame / bullet.vframes), bullet.texture.get_size().x / bullet.hframes, bullet.texture.get_size().y / bullet.vframes)
		##var region_rect : Rect2i = texture_rect(bullet.texture, bullet.hframes, bullet.vframes, bullet.frame)
		#draw_texture_rect_region(bullet.texture, Rect2i(bullet.position, region_rect.size), region_rect)
		#if !bullet.animated: continue
		#bullet._animation_update()
		#bullet.ani_time += 1
		#if bullet.ani_time == bullet.ani_rate:
			#bullet.ani_time = 0
			#bullet.frame = wrapi(bullet.frame + 1, bullet.start_frame, bullet.end_frame + 1)


func texture_rect(texture : Texture2D, hframes : int, vframes : int, frame : int) -> Rect2i:
	#var texture_size : Vector2i = texture.get_size()
	#var frame_size : Vector2i = Vector2i(texture_size.x / hframes, texture_size.y / vframes)
	#var frame_pos : Vector2i = Vector2i(frame_size.x / 2 * frame_coords.x, frame_size.y / 2 * frame_coords.y)
	#return Rect2i(Vector2i(frame_size.x * (frame % hframes), frame_size.y * (frame / vframes)), frame_size)
	return Rect2i(texture.get_size().x / hframes * (frame % hframes), texture.get_size().y / vframes * (frame / vframes), texture.get_size().x / hframes, texture.get_size().y / vframes)


var angle : float
var fire_origin : Vector2
var start_angle : float
func _handle_pattern() -> int:
	#var fire_direction : Vector2x
	#var bullet : BulletRef
	#var v : int
	#var pos : Vector2 = global_position
	#var props : Dictionary = {}
	#props["bullet_count"] = 0
	# calculate origin offset
	pattern_origin = Vector2(global_position.x + (origin_offset * cos(360.0/spawn_count)), global_position.y + (origin_offset * sin(360.0/spawn_count)))
	#var spread_rad : float = spread_degrees * PI / 180 # angle to shoot spread
	start_angle = angle_to_player(global_position) if angle_type == Angle.CHASE_PLAYER else (fire_angle * PI / 180) # angle of main bullet to fire
	#var start_angle = angle_to_player(pattern_origin) if angle_type == Angle.CHASE_PLAYER else angle_to_target(pattern_origin, target) if angle_type == Angle.TARGET else (fire_angle * PI / 180) # angle of main bullet to fire
	#print("start_angle=%s" % [start_angle])
	start_angle = start_angle if spread % 2 != 0 else start_angle + (spread_degrees * PI / 180 / 2)
	#var radians : float = 2 * PI / spawn_count # convert to radians for function params
	# spawn stacks of rings
	for stack in range(1, stacks + 1):
		#v = bullet_data.velocity + (stack_velocity * stack)
		# fire additional ring if should spread from a given line
		for i in range(ceil(-spread / 2.0), ceil(spread / 2.0)):
			# spawn all bullets in ring
			for line in range(1, spawn_count + 1):
				#props["bullet_count"] += 1
				# calculate fire angle, taking spread, and angle offset modifiers
				angle = start_angle + (2 * PI / spawn_count * line) + angle_offset + (i * spread_degrees * PI / 180)
				fire_origin = global_position + (pattern_origin.from_angle(angle) * origin_offset)
				#print(fire_origin)
				#print(angle_to_target(fire_origin, target))
				#bullet = BulletPool.get_next_bullet(bullet_data, angle_to_target(fire_origin, target) if angle_type == Angle.TARGET else angle, v, acceleration, fire_origin, bullet_ctrl, self)
				#custom_modify_bullet.call(bullet, props, bulletin_board)
				#bullet.fire()
				#print("[%s][%s][%s]=%s" % [stack, i, line, angle])
				#spawn_bullet(bullet_data, angle_to_target(fire_origin, target) if angle_type == Angle.TARGET else angle, v, fire_origin)
				
				
				var b : BulletRef = BulletRef.new()
				b.set_data(bullet_data)
				#var b : BulletRef = bullet_data.duplicate(0b0111) as BulletRef
				b.angle = angle_to_target(fire_origin, target) if angle_type == Angle.TARGET else angle
				b.virtual_position = fire_origin
				b.position = fire_origin
				b.velocity = velocity + (stack_velocity * stack)
				b.acceleration = acceleration
				#configure_collision(b)
				var transform : Transform2D = Transform2D(0, fire_origin)
				transform.origin = b.position
				# Add the shape to the shared area
				#print("bullet shape rid=%s" % [b.shape.get_rid()])
				PhysicsServer2D.area_add_shape(Godanmaku.get_bullet_area().get_rid(), b.shape.get_rid(), transform)
				bullets.append(b)
	return SUCCESS


#func spawn_bullet(bullet : BulletRef, angle : float, velocity : int, fire_origin : Vector2) -> void:
	#var b : BulletRef = bullet.duplicate(0b0111) as BulletRef
	#b.angle = angle
	#b.virtual_position = fire_origin
	#b.position = fire_origin
	#b.velocity = velocity
	##configure_collision(b)
	#var transform : Transform2D = Transform2D(0, fire_origin)
	#transform.origin = bullet.position
	## Add the shape to the shared area
	##print("bullet shape rid=%s" % [b.shape.get_rid()])
	#PhysicsServer2D.area_add_shape(Godanmaku.get_bullet_area().get_rid(), b.shape.get_rid(), transform)
	#bullets.append(b)


#func configure_collision(bullet : BulletRef) -> void:
	#var transform : Transform2D = Transform2D(0, position)
	#transform.origin = bullet.position
	## Step 2
	##var _circle_shape = PhysicsServer2D.circle_shape_create()
	##PhysicsServer2D.shape_set_data(_circle_shape, 8)
	## Add the shape to the shared area
	#PhysicsServer2D.area_add_shape(Godanmaku.get_bullet_area().get_rid(), bullet.shape.get_rid(), transform)
	## Step 3
	##bullet.shape_id = bullet.shape
	##bullet.shape_id = _circle_shape


#func _on_bullet_expired(bullet : BulletRef) -> void:
	#PhysicsServer2D.free_rid(bullet.shape.get_rid())
	#bullets.erase(bullet)
