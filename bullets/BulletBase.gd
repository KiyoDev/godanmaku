class_name BulletBase extends Sprite2D


signal expired


@onready var direct_space_state : PhysicsDirectSpaceState2D = get_world_2d().direct_space_state
@onready var query : PhysicsShapeQueryParameters2D = PhysicsShapeQueryParameters2D.new()

## Dictionary wrapper that can be used by updates for additional parameters and properties
var bulletin_board : BulletinBoard
## Reference to a pattern's BulletinBoard to read any shared data from the pattern firing this bullet
var pattern : DanmakuPattern

## Damage
var damage : int = 1
## Query collision layer
var hitbox_layer : int = 0
## Query graze collision layer
var graze_layer : int = 0
## Bullet speed
var velocity : int = 100
## Max bullet speed
var max_velocity : int = 1000
## Bullet acceleration
var acceleration : int = 0
## Angle of travel
var angle : float = 0:
	set(value):
		angle = value
		update_rotation()
var angle_offset : float = 0
## If true, bullet rotates to look at the direction it's traveling
var directed : bool = false
## How many times bullet should bounce off the edges of the screen
var max_bounces : int = 0
## Bullet duration in frames. 0 = doesn't expire until off screen
# 60 frames per second
var duration : int = 1200:
	set(value):
		duration = maxi(0, value) # never let duration go lower than 0

## If the bullet should fade after a certain time
var fade : bool = false
var disable_on_hit : bool = true
var grazeable : bool = true
var can_graze : bool = false

## Animation
var animated : bool = false
var start_frame : int = 0
var end_frame : int = 0
var ani_time : int = 0
var ani_rate : int = 10

## Virtual position of the bullet. Use with position_offset to adjust bullets position along its projected path
var virtual_position : Vector2
## Offset to virtual position
var position_offset : Vector2 = Vector2.ZERO
## Current bounce count
var current_bounces : int = 0
## How long the bullet has been alive for
var up_time : int = 0

## Used to modify final velicty without changing the base value
var velocity_modifier : int = 0
var tmp_velocity : int = 0
var tmp_acceleration : int = 0

var disabled : bool = false
var expiration_timer : int = 0

var boundary : Rect2:
	set = set_boundary

#/--------------------------------------------------/
#/---------------- CUSTOM FUNCTIONS ----------------/
#/--------------------------------------------------/
## Callable used handle bullet movement
#var move_update : Callable = _move_update
## Callable used handle custom bullet updates
var custom_update : Callable = _custom_update
## Callable used handle bullet animation updates
var animation_update : Callable = _animation_update
## Callable used handle bullet collisions
var handle_collision : Callable = _handle_collision

var on_hit_effects : Array[Callable] = []


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	disabled = true
	set_physics_process(false)
	add_to_group("bullets")
	hide()
	z_index = 10
	set_as_top_level(true)
	bulletin_board = BulletinBoard.new()
	var coll : CollisionShape2D = Godanmaku.get_bullet_area().get_child(0) as CollisionShape2D
	set_boundary(coll.shape.get_rect())
	#Godanmaku.disable_active_bullets.connect(_on_disable_active_bullets)


func _physics_process(delta: float) -> void:
	if disabled:
		if expiration_timer == 600:
			set_physics_process(false)
			queue_free()
			return
		expiration_timer += 1
		return
	#update(delta, self, bulletin_board) # asks the controler how it should behave each tick
	
	# frame up time
	up_time += 1
	
	#print("v=%s,a=%s" % [velocity, acceleration])
	velocity = max(min(velocity + acceleration, max_velocity), 0)
	
	# Take into consideration angle to arc
	virtual_position = Vector2(virtual_position.x + ((velocity + velocity_modifier) * delta) * cos(angle + angle_offset), virtual_position.y + ((velocity + velocity_modifier) * delta) * sin(angle + angle_offset))
	# update rotation of texture and transform if bullet is directed
	if directed:
		look_at(virtual_position)
	
	query.transform = global_transform
	global_position = virtual_position + position_offset
	
	
	if !boundary.has_point(global_position) or (duration > 0 and up_time == duration):
		if !bounce(boundary):
			queue_free()
			return
	#_move_update(delta, self, bulletin_board)
	#move_update.call(delta, self, bulletin_board)
	# FIXME: if referenced control node is destroyed, will cause error
	# try to call custom updates
	var status : int = custom_update.call(delta, self, bulletin_board) # called for any additional processing
	if status == 1 and custom_update != _custom_update:
		custom_update = _custom_update
	# call animation updates
	if animated:
		animation_update.call(delta, self, bulletin_board) # can be overwritten for custom animation updates
	# call collision updates
	handle_collision.call(delta)
	
	if fade and duration > 0 and up_time >= duration * 0.75:
		self_modulate.a8 -= 15
		if self_modulate.a8 == 0:
			timeout.call(self)
			return
	
	# if been alive for duration, expire bullet
	if duration > 0 and up_time >= duration:
		timeout.call(self)
		return


## Start firing the pattern
func fire(attack_multiplier : float = 1) -> void:
	show()
	Godanmaku.disable_active_bullets.connect(_on_disable_active_bullets)
	expiration_timer = 0
	disabled = false
	set_physics_process(true)
	damage *= attack_multiplier
	# view shape debug
	#var col = CollisionShape2D.new()
	#add_child(col)
	#col.shape = query.shape
	#col.global_transform = global_transform


## Swap data to the BulletData's properties
func _swap_data(data : BulletData) -> void:
	damage = data.damage
	# texture info
	if texture != data.texture:
		texture = data.texture
	hframes = data.hframes
	vframes = data.vframes
	frame = data.frame
	frame_coords = data.frame_coords
	
	hitbox_layer = data.hitbox_layer
	graze_layer = data.graze_layer
	query.shape = data.shape
	grazeable = data.grazeable
	if grazeable:
		can_graze = true
	directed = data.directed
	duration = data.duration
	disable_on_hit = data.disable_on_hit
	max_bounces = data.bounces
	offset = data.offset
	ani_time = 0
	animated = data.animated
	start_frame = data.start_frame
	end_frame = data.end_frame
	ani_rate = data.ani_rate
	scale = data.size


## Called to setup bullet data before firing
func before_spawn(_pattern : DanmakuPattern, data : BulletData, _angle : float, _velocity : int, _acceleration : int, _position : Vector2) -> void:
	if _pattern:
		pattern = _pattern
	reset(_position)
	angle = _angle
	#_swap(data, a, v)
	_swap_data(data)
	velocity = _velocity
	acceleration = _acceleration
	# global_position + angle to look at the direction properly
	if directed:
		look_at(global_position + Vector2.RIGHT.rotated(angle))

func set_boundary(rect : Rect2) -> void:
	boundary = rect


## Update the bullet's rotation to face the angle relative to its position
func update_rotation() -> void:
	if directed:
		look_at(global_position + Vector2.RIGHT.rotated(angle))


func timeout(bullet : BulletBase) -> void:
	_disable()


## Reset various bullet info tp defai;t va;ies
func reset(position : Vector2) -> void:
	bulletin_board.clear()
	virtual_position = position
	global_position = position
	query.transform = global_transform
	query.collide_with_areas = true
	custom_update = _custom_update
	animation_update = _animation_update
	up_time = 0
	current_bounces = 0
	velocity = 0
	acceleration = 0
	angle = 0
	position_offset = Vector2.ZERO
	animated = false
	ani_time = 0


## Resume bullet movement
func resume() -> void:
	if tmp_velocity != 0:
		velocity = tmp_velocity
		tmp_velocity = 0
	
	if tmp_acceleration != 0:
		acceleration = tmp_acceleration
		tmp_acceleration = 0


## Stop bullet movement
func stop() -> void:
	if tmp_velocity == 0:
		tmp_velocity = velocity
		velocity = 0
	
	if tmp_acceleration == 0:
		tmp_acceleration = acceleration
		acceleration = 0


## Disable the bullet.
func _disable() -> void:
	expired.emit(self)
	reset(Vector2.ZERO)
	query.collide_with_areas = false
	hide()
	Godanmaku.disable_active_bullets.disconnect(_on_disable_active_bullets)
	disabled = true
	queue_free()
	#set_physics_process(false)


func disable_collision() -> void:
	handle_collision = func(delta): pass


func enable_collision() -> void:
	handle_collision = _handle_collision


func bounce(boundary : Rect2) -> bool:
	if max_bounces > 0 and current_bounces < max_bounces:
		if position.y <= -(boundary.position + (boundary.size / 2)).y or position.y >= (boundary.position + (boundary.size / 2)).y:
			angle = -angle
		elif position.x <= -(boundary.position + (boundary.size / 2)).x or position.x >= (boundary.position + (boundary.size / 2)).x:
			angle = -PI - angle
		current_bounces += 1
		return true
	return false


## Calls all relevant update methods to handle movement, collision, animation, and other optional custom functionality
#func update(delta : float, bullet : BulletBase, bulletin_board : BulletinBoard) -> void:
	## call movement updates
	#move_update.call(delta, bullet, bulletin_board)
	## try to call custom updates
	#var status : int = custom_update.call(delta, bullet, bulletin_board) # called for any additional processing
	#if status == 1 and custom_update != _custom_update:
		#custom_update = _custom_update
	## call animation updates
	#if animated:
		#animation_update.call(delta, bullet, bulletin_board) # can be overwritten for custom animation updates
	## call collision updates
	#handle_collision.call(delta)
	#
	#if fade and duration > 0 and up_time >= duration * 0.75:
		#self_modulate.a8 -= 15
		#if self_modulate.a8 == 0:
			#timeout.call(bullet)
			#return
	#
	## if been alive for duration, expire bullet
	#if duration > 0 and up_time >= duration:
		#timeout.call(bullet)
		#return

# default update functions

func _handle_collision(delta : float) -> void:
	query.collision_mask = hitbox_layer
	
	var hit : Array[Dictionary] = direct_space_state.intersect_shape(query, 1)
	if hit:
		var coll : Node2D = hit[0]["collider"]
		
		#print("rest_info=%s" % [BulletUtil.direct_space_state.get_rest_info(query)])
		if coll.has_method("_on_hit"):
			_custom_on_hit.call(self)
			coll._on_hit(self)
		
		if disable_on_hit:
			_disable()
	else:
		if !grazeable: return
		query.collision_mask = graze_layer
		hit = direct_space_state.intersect_shape(query, 1)
		if hit and can_graze:
			can_graze = false
			var coll = hit[0]["collider"]
			if coll.has_method("_on_grazed"):
				coll._on_grazed(self)


func _animation_update(delta : float, bullet : BulletBase, bulletin_board : BulletinBoard) -> void:
	ani_time += 1
	if ani_time == ani_rate:
		ani_time = 0
		frame = wrapi(frame + 1, start_frame, end_frame + 1)
	

# Default functionality for custom updates

#func _move_update(delta : float, bullet : BulletBase, bulletin_board : BulletinBoard) -> void:
	## frame up time
	#up_time += 1
	#
	##print("v=%s,a=%s" % [velocity, acceleration])
	#velocity = max(min(velocity + acceleration, max_velocity), 0)
	#
	## Take into consideration angle to arc
	#virtual_position = Vector2(virtual_position.x + (velocity * delta) * cos(angle), virtual_position.y + (velocity * delta) * sin(angle))
	## update rotation of texture and transform if bullet is directed
	#if directed:
		#look_at(virtual_position)
	#
	#query.transform = global_transform
	#global_position = virtual_position + position_offset


## set custom behavior for the bullet
# instead of having tick controller calls or whatever, when bullet it spawned, it is assigned this behavior
func _custom_update(delta : float, bullet : BulletBase, bulletin_board) -> int: 
	return 0


func _custom_on_hit(bullet : BulletBase) -> void:
	for call in on_hit_effects:
		call.call(bullet)


func _on_disable_active_bullets() -> void:
	pass

