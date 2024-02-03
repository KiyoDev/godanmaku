class_name BulletBase extends Sprite2D


signal expired


@onready var query : PhysicsShapeQueryParameters2D = PhysicsShapeQueryParameters2D.new()

## Dictionary wrapper that can be used by updates for additional parameters and properties
var bulletin_board : BulletinBoard
var pattern : DanmakuPattern
var camera : Camera2D
var screen_extents : Vector2

## Damage
var damage : int = 10
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
var angle : float = 0
## If true, bullet rotates to look at the direction it's traveling
var directed : bool = false
## How many times bullet should bounce off the edges of the screen
var max_bounces : int = 0
## Bullet duration in frames. 0 = doesn't expire until off screen
# 60 frames per second
var duration : int = 1200:
	set(value):
		duration = maxi(0, value) # never let duration go lower than 0
var hide_on_hit : bool = true
var grazeable : bool = true
var can_graze : bool = false

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



var tmp_velocity : int = 0
var tmp_acceleration : int = 0

#/--------------------------------------------------/
#/---------------- CUSTOM FUNCTIONS ----------------/
#/--------------------------------------------------/
var move_update : Callable = _move_update
var custom_update : Callable = _custom_update


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group("bullets")
	hide()
	z_index = 10
	set_physics_process(false)
	set_as_top_level(true)
	camera = get_tree().get_first_node_in_group("camera")
	screen_extents = get_viewport_rect().size / (2 * camera.zoom)
	bulletin_board = BulletinBoard.new()


# update_function(bullet, ...) # <- other args via .bind(...)
func _physics_process(delta: float) -> void:
	update(delta, self, bulletin_board) # asks the controler how it should behave each tick


func _swap_data(data : BulletData) -> void:
	data.set_texture(self)
	hitbox_layer = data.hitbox_layer
	graze_layer = data.graze_layer
	query.shape = data.shape
	grazeable = data.grazeable
	if grazeable:
		can_graze = true
	directed = data.directed
	duration = data.duration
	hide_on_hit = data.hide_on_hit
	max_bounces = data.bounces
	ani_time = 0
	animated = data.animated
	start_frame = data.start_frame
	end_frame = data.end_frame
	ani_rate = data.ani_rate


func _swap(data : BulletData, v : int, a : int) -> void:
	_swap_data(data)
	velocity = v
	acceleration = a


func reset(position : Vector2) -> void:
	bulletin_board.clear()
	virtual_position = position
	global_position = position
	query.transform = global_transform
	query.collide_with_areas = true
	custom_update = _custom_update
	up_time = 0
	current_bounces = 0
	position_offset = Vector2.ZERO


func before_spawn(data : BulletData, angle : float, v : int, a : int, position : Vector2) -> void:
	reset(position)
	_swap(data, a, v)
	self.angle = angle
	if directed:
		query.transform.looking_at(global_position)
		look_at(global_position)


func fire() -> void:
	show()
	set_physics_process(true)


func timeout(bullet : BulletBase) -> void:
	_disable()


func resume() -> void:
	if tmp_velocity != 0:
		velocity = tmp_velocity
		tmp_velocity = 0
	
	if tmp_acceleration != 0:
		acceleration = tmp_acceleration
		tmp_acceleration = 0


func stop() -> void:
	if tmp_velocity == 0:
		tmp_velocity = velocity
		velocity = 0
	
	if tmp_acceleration == 0:
		tmp_acceleration = acceleration
		acceleration = 0
	


func _disable() -> void:
	expired.emit(self)
	reset(Vector2.ZERO)
	query.collide_with_areas = false
	hide()
	set_physics_process(false)


func update(delta : float, bullet : BulletBase, bulletin_board : BulletinBoard) -> void:
	move_update.call(delta, bullet, bulletin_board)
	var status : int = custom_update.call(delta, bullet, bulletin_board) # called for any additional processing
	if status == 1 and custom_update != _custom_update:
		custom_update = _custom_update
	_animation_update(delta, bullet, bulletin_board)
	_handle_collision(delta)
	
	# if been alive for duration, expire bullet
	if duration > 0 and up_time >= duration:
		timeout.call(bullet)
		return


func _handle_collision(delta : float) -> void:
	query.collision_mask = hitbox_layer
	#query.transform = global_transform
	
	var hit : Array[Dictionary] = BulletPool.intersect_shape(query, 1)
	if hit:
		var coll : Node2D = hit[0]["collider"]
		
		#print("rest_info=%s" % [BulletUtil.direct_space_state.get_rest_info(query)])
		if coll.has_method("_on_hit"):
			coll._on_hit(self)
		
		if hide_on_hit:
			_disable()
	else:
		if !grazeable: return
		query.collision_mask = graze_layer
		hit = BulletPool.intersect_shape(query, 1)
		if hit and can_graze:
			can_graze = false
			var coll = hit[0]["collider"]
			if coll.has_method("_on_grazed"):
				coll._on_grazed()


func _animation_update(delta : float, bullet : BulletBase, bulletin_board : BulletinBoard) -> void:
	if animated:
		ani_time += 1
		if ani_time == ani_rate:
			ani_time = 0
			frame = wrapi(frame + 1, start_frame, end_frame + 1)

# Default functionality for custom updates

func _move_update(delta : float, bullet : BulletBase, bulletin_board : BulletinBoard) -> void:
	if !camera: 
		_disable()
		return
	
	# frame up time
	up_time += 1
	
	#print("v=%s,a=%s" % [velocity, acceleration])
	velocity = max(min(velocity + acceleration, max_velocity), 0)
	
	# Take into consideration angle to arc
	virtual_position = Vector2(virtual_position.x + (velocity * delta) * cos(angle), virtual_position.y + (velocity * delta) * sin(angle))
	# update rotation of texture and transform if bullet is directed
	if directed:
		look_at(virtual_position)
		query.transform.looking_at(virtual_position)
	
	query.transform = global_transform
	global_position = virtual_position + position_offset
	
	if global_position.y <= -(camera.global_position + screen_extents).y or global_position.y >= (camera.global_position + screen_extents).y or global_position.x <= -(camera.global_position + screen_extents).x or global_position.x >= (camera.global_position + screen_extents).x:
		# when reaching edge of screen, disable bullet or bounce if applicable
		if max_bounces > 0 and current_bounces < max_bounces:
			if global_position.y <= -(camera.global_position + screen_extents).y or global_position.y >= (camera.global_position + screen_extents).y:
				angle = -angle
			elif global_position.x <= -(camera.global_position + screen_extents).x or global_position.x >= (camera.global_position + screen_extents).x:
				angle = -PI - angle
			current_bounces += 1
		else:
			_disable()
		return


## set custom behavior for the bullet
# instead of having tick controller calls or whatever, when bullet it spawned, it is assigned this behavior
func _custom_update(delta : float, bullet : BulletBase, bulletin_board) -> int: 
	return 0


