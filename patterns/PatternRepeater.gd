## Parent pattern used to repeat its child pattern after a certain number of frames
class_name PatternRepeater extends DanmakuPattern

var repeat : bool = false


func _ready() -> void:
	super._ready()
	max_repeats = max(max_repeats, 1)


func fire() -> void:
	if !can_update:
		can_update = true
		set_physics_process(true)
		get_child(0).can_update = true # allow child to call its update() method


func _base_update(delta : float) -> int:
	if !can_update: return FINISHED
	if max_repeats == 0:
		_handle_pattern(delta)
		stop()
		return SUCCESS
	else:
		if max_repeats > 0 and max_repeats <= repeat_count: 
			stop()
			return SUCCESS
		
		if repeat and total_time < repeat_time:
			total_time += 1
		elif !repeat and total_time < repeat_time:
			var status : int = _handle_pattern(delta)
			custom_repeat.call(delta, self, bulletin_board)
			
			if status == SUCCESS:
				repeat = true
				return RUNNING
				
			if status == FINISHED:
				return FINISHED
		else: # repeat and total_time >= repeat_time
			total_time = 0
			repeat_count += 1
			repeat = false
	return RUNNING


func _handle_pattern(delta : float) -> int:
	if get_child_count() == 1:
		var status : int = get_child(0).update(delta)
		
		if status == SUCCESS:
			return status
		
		return RUNNING
	# when child is not RUNNING, start ticking until next repeat
	return FINISHED
