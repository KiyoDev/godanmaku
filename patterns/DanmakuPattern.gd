class_name DanmakuPattern extends Node2D


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

## If bullet should chase the player's position
@export var angle_type : Angle = Angle.FIXED
@export var target : Node2D
@export var origin_offset : int = 1
## Direction to spawn and aim pattern (in degrees)
@export var fire_angle : int = 180
## Velocity to set for bullets being fired
@export var velocity : int = 100
## Acceleration to set for bullets being fired
@export var acceleration : int = 0
## Bullet data to use when firing bullets
@export var bullet_data : BulletData

@export_group("Pattern Controls")
@export var pattern_ctrl : PatternControl

@export_group("Bullet Controls")
@export var bullet_ctrl : ControlNode

@export_group("Repeat Settings")
## How many times the pattern repeats. 0 means no repeats, -1 means infinite
@export_range(-1, 1000) var max_repeats : int = 0
## How many seconds until the pattern repeats
@export var repeat_time : float = 1.0

@export_group("Sub Patterns")
@export var sub_patterns : Array[DanmakuPattern]

#@export_group("Modifiers")
### How far to rotate the pattern for the next time it fires
#@export var spin_rate : float = 0.0

var bulletin_board : BulletinBoard

var custom_update : Callable
var custom_repeat : Callable
var get_bullet_data : Callable

var total_time : float = 0.0
var repeat_count : int = 0
var can_update : bool = false
var angle_offset : float = 0

var player : Player


func _ready() -> void:
	custom_update = _custom_update
	custom_repeat = _custom_repeat
	get_bullet_data = _get_bullet_data
	player = get_tree().get_first_node_in_group("player")
	can_update = false
	bulletin_board = BulletinBoard.new()
	set_physics_process(false)


func _physics_process(delta: float) -> void:
	update(delta)


func fire() -> void:
	if !can_update:
		can_update = true
		set_physics_process(true)
		_sub_fire()
		if pattern_ctrl:
			pattern_ctrl._set_custom_repeat(self, bulletin_board)


func _sub_fire() -> void:
	if !sub_patterns.is_empty():
		for sp in sub_patterns:
			if !sp: continue
			sp.fire()


func stop() -> void:
	total_time = 0
	repeat_count = 0
	angle_offset = 0
	can_update = false
	set_physics_process(false)
	finished.emit()


func angle_to_player(pattern_origin : Vector2) -> float:
	return pattern_origin.angle_to_point(player.global_position if player else global_position + Vector2.LEFT)


func angle_to_target(pattern_origin : Vector2, target : Node2D) -> float:
	#print_debug("a=%s, %s --- %s, %s" % [pattern_origin, pattern_origin.normalized(), target.global_position, pattern_origin.angle_to_point(target.global_position if target else Vector2(-69.69, -69.69))])
	return pattern_origin.angle_to_point(target.global_position if target else global_position + Vector2.LEFT)


func player_position() -> Vector2:
	return player.global_position if player else global_position


func update(delta : float) -> int:
	if !can_update: return FINISHED
	var status : int = _base_update.call(delta)
	custom_update.call(delta, self, bulletin_board)
	
	return status


func _base_update(delta : float) -> int:
	if !can_update: return FINISHED
	if max_repeats == 0:
		_handle_pattern(delta)
		stop()
		return SUCCESS
	else:
		if repeat_count == 0 and total_time == 0:
			_handle_pattern(delta)
			custom_repeat.call(delta, self, bulletin_board)
		elif max_repeats > 0 and max_repeats <= repeat_count: 
			stop()
			return SUCCESS
		
		if total_time < repeat_time:
			total_time += 1
		else:
			total_time = 0
			repeat_count += 1
			_handle_pattern(delta)
			# Fire sub patterns
			custom_repeat.call(delta, self, bulletin_board)
	return RUNNING


func _custom_update(delta : float, pattern : DanmakuPattern, bulletin_board : BulletinBoard) -> int:
	return RUNNING


func _custom_repeat(delta : float, pattern : DanmakuPattern, bulletin_board : BulletinBoard) -> int:
	return RUNNING


func _get_bullet_data() -> BulletData:
	return bullet_data


func _handle_pattern(delta : float) -> int:
	return RUNNING
