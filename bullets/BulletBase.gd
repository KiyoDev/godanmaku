class_name BulletBase extends Sprite2D


signal expired


@onready var query : PhysicsShapeQueryParameters2D = PhysicsShapeQueryParameters2D.new()

## Dictionary wrapper that can be used by updates for additional parameters and properties
var bulletin_board : BulletinBoard
var pattern : DanmakuPattern
var camera : Camera2D
var screen_extents : Vector2

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
var duration : int = 0:
	set(value):
		duration = maxi(0, value) # never let duration go lower than 0

## Virtual position of the bullet. Use with position_offset to adjust bullets position along its projected path
var virtual_position : Vector2
## Offset to virtual position
var position_offset : Vector2 = Vector2.ZERO
## Current bounce count
var current_bounces : int = 0
## How long the bullet has been alive for
var up_time : int = 0

#/--------------------------------------------------/
#/---------------- CUSTOM FUNCTIONS ----------------/
#/--------------------------------------------------/
var move_update : Callable = _move_update
var custom_update : Callable = _custom_update


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group("bullets")
	hide()
	set_physics_process(false)
	set_as_top_level(true)
	camera = get_tree().get_first_node_in_group("camera")
	screen_extents = get_viewport_rect().size / (2 * camera.zoom)
	bulletin_board = BulletinBoard.new()


# update_function(bullet, ...) # <- other args via .bind(...)
func _physics_process(delta: float) -> void:
	update(delta, self, bulletin_board) # asks the controler how it should behave each tick


func _swap(data : BulletData, v : int, a : int) -> void:
	if texture != data.texture:
		data.set_texture(self)
	query.shape = data.shape
	query.collision_mask = data.hitbox_layer
	directed = data.directed
	velocity = v
	acceleration = a
	duration = data.duration
	max_bounces = data.bounces


func reset(position : Vector2) -> void:
	bulletin_board.clear()
	virtual_position = position
	global_position = position
	query.collide_with_areas = true
	custom_update = _custom_update
	up_time = 0
	current_bounces = 0
	position_offset = Vector2.ZERO


func before_spawn(data : BulletData, angle : float, v : int, a : int, position : Vector2) -> void:
	reset(position)
	_swap(data, a, v)
	self.angle = angle


func fire() -> void:
	show()
	set_physics_process(true)


func timeout(bullet : BulletBase) -> void:
	_disable()


func _disable():
	print("d")
	expired.emit(self)
	set_physics_process(false)
	reset(Vector2.ZERO)
	query.collide_with_areas = false
	hide()


func update(delta : float, bullet : BulletBase, bulletin_board : BulletinBoard) -> void:
	move_update.call(delta, bullet, bulletin_board)
	var status : int = custom_update.call(delta, bullet, bulletin_board) # called for any additional processing
	if status == 1 and custom_update != _custom_update:
		custom_update = _custom_update

# Default functionality for custom updates

func _move_update(delta : float, bullet : BulletBase, bulletin_board : BulletinBoard) -> void:
	if !camera: 
		_disable()
		return
	
	# frame up time
	up_time += 1
	
	# if been alive for duration, expire bullet
	if duration > 0 and up_time >= duration:
		timeout.call(bullet)
		return
	
	velocity = min(velocity + acceleration, max_velocity)
	
	# Take into consideration angle to arc
	virtual_position = Vector2(virtual_position.x + (velocity * delta) * cos(angle), virtual_position.y + (velocity * delta) * sin(angle))
	if directed: look_at(virtual_position)
	
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


