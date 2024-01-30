class_name DanmakuPattern extends Node2D


@export var bullet_data : BulletData

@export_group("Repeat Settings")
## How many times the pattern repeats. 0 means no repeats, -1 means infinite
@export_range(-1, 1000) var max_repeats : int = 0
## How many seconds until the pattern repeats
@export var repeat_time : float = 1.0

#@export_group("Modifiers")
### How far to rotate the pattern for the next time it fires
#@export var spin_rate : float = 0.0

var total_time : float = 0.0
var repeat_count : int = 0
var can_tick : bool = true


func _ready() -> void:
	pass


func tick(delta : float) -> void:
	# tick only if has 1 child
	if self.get_child_count() == 1 and can_tick:
		fire(delta)


func fire(delta : float) -> void:
	_repeat(delta)


func _repeat(delta : float) -> void:
	if !can_tick: return
	if max_repeats == 0:
		_handle_pattern(delta)
		can_tick = false
		return
	else:
		if max_repeats > 0 and max_repeats <= repeat_count: 
			can_tick = false
			return
		
		if total_time < repeat_time:
			total_time += delta
		else:
			total_time = 0
			repeat_count += 1
			get_child(0)._modify(delta)
			_handle_pattern(delta)


func _handle_pattern(delta : float) -> void:
	pass