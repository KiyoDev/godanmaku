class_name BulletBase extends Sprite2D


signal expired


@onready var query : PhysicsShapeQueryParameters2D = PhysicsShapeQueryParameters2D.new()

## Dictionary wrapper that can be used by updates for additional parameters and properties
var bulletin_board : BulletinBoard
var pattern : DanmakuPattern
var camera : Camera2D
var screen_extents : Vector2

var virtual_position : Vector2

## Bullet speed
@export var velocity : int = 100
## Max bullet speed
var max_velocity : int = 1000
## Bullet acceleration
@export var acceleration : int = 0
## Direction to travel
@export var direction : Vector2 = Vector2.LEFT
## 
@export var angle : float = 0
## If true, bullet rotates to look at the direction it's traveling
@export var directed : bool = false
## How many times bullet should bounce off the edges of the screen
@export var max_bounces : int = 0
## Current bounce count
var current_bounces : int = 0
## Bullet duration in frames. 0 = doesn't expire until off screen
# 60 frames per second
@export var duration : int = 0:
	set(value):
		duration = maxi(0, value) # never let duration go lower than 0
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


func _swap(new_texture : Texture2D, new_shape : Shape2D) -> void:
	bulletin_board.clear()
	query.shape = new_shape
	texture = new_texture


func before_spawn(shape : Shape2D, hit_layer : int) -> void:
	query.shape = shape
	query.collision_mask = hit_layer
	query.collide_with_areas = true
	bulletin_board.clear()


func spawn() -> void:
	show()
	set_physics_process(true)


func timeout(bullet : BulletBase) -> void:
	_disable()


func _disable():
	expired.emit(self)
	hide()
	set_physics_process(false)
	#active = false


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
	
	up_time += 1
	
	# if been alive for duration, expire bullet
	if duration > 0 and up_time >= duration:
		timeout.call(bullet)
		return
	
	velocity = min(velocity + acceleration, max_velocity)
	var distance := velocity * delta
	var motion := direction * distance
	# TODO: offset for waving
	var offset := Vector2.ZERO
	#var offset : Vector2 = direction.orthogonal() * sin(w_t * frequency) * amplitude
	
	#print_debug("testing=%s" % [Vector2(virtual_position.x + distance * cos(angle), virtual_position.y + distance * sin(angle))])
	
	virtual_position = Vector2(virtual_position.x + distance * cos(angle), virtual_position.y + distance * sin(angle))
	#virtual_position += motion
	if directed: look_at(virtual_position)
	
	global_position = virtual_position + offset
	
	if global_position.y <= -(camera.global_position + screen_extents).y or global_position.y >= (camera.global_position + screen_extents).y or global_position.x <= -(camera.global_position + screen_extents).x or global_position.x >= (camera.global_position + screen_extents).x:
		#print("g%s vs c%s, %s" % [global_position, camera.global_position, screen_extents])
		if max_bounces > 0 and current_bounces < max_bounces:
			if global_position.y <= -(camera.global_position + screen_extents).y or global_position.y >= (camera.global_position + screen_extents).y:
				direction = Vector2(direction.x, -direction.y)
			elif global_position.x <= -(camera.global_position + screen_extents).x or global_position.x >= (camera.global_position + screen_extents).x:
				direction = Vector2(-direction.x, direction.y)
			current_bounces += 1
		else:
			_disable()
		return


## set custom behavior for the bullet
# instead of having tick controller calls or whatever, when bullet it spawned, it is assigned this behavior
func _custom_update(delta : float, bullet : BulletBase, bulletin_board) -> int: 
	return 0


