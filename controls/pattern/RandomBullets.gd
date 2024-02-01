## Modifies a DanmakuPattern's get_bullet_data method to provide a random BulletData from the given array. If repeats are enabled, then it resets the method upon completion.
class_name RandomBullets extends PatternControl


@onready var repeat_key = "random_bullets_repeats_%s" % self.get_instance_id()

## Bullets that should spawn
@export var bullets : Array[BulletData]:
	set(value):
		bullets = value
		while weights.size() < bullets.size():
			weights.append(1)
		notify_property_list_changed()
@export var weights : Array[int]
## How many repeats to spin the pattern. 0 = indefinitely
@export var repeats : int = 0


func _before_set(pattern : DanmakuPattern, bulletin_board : BulletinBoard) -> void:
	bulletin_board.set_value(repeat_key, 0)
	if bullets.is_empty(): return
	var total : int = 0
	var running : Array[int] = []
	for i in weights.size():
		total += weights[i]
		running.append(weights[i] + (running[i - 1] if i > 0 else 0))
		
	pattern.get_bullet_data = func():
		var rand = randi_range(1, total)
		var index : int = 0
		# find first index where rand is <= to the weight
		for i in running.size():
			if rand <= running[i]:
				index = i
				break
		return bullets[index]
		#return bullets[randi_range(0, bullets.size() - 1)]


func _set_custom_update(pattern : DanmakuPattern, bulletin_board : BulletinBoard) -> void:
	_before_set(pattern, bulletin_board)
	pattern.custom_update = _custom_update


func _set_custom_repeat(pattern : DanmakuPattern, bulletin_board : BulletinBoard) -> void:
	_before_set(pattern, bulletin_board)
	pattern.custom_repeat = _custom_repeat


func _custom_repeat(delta : float, pattern : DanmakuPattern, bulletin_board : BulletinBoard) -> int:
	if bullets.is_empty() or (repeats > 0 and bulletin_board.get_value(repeat_key) >= repeats):
		pattern.get_bullet_data = pattern._get_bullet_data
		return SUCCESS
	
	bulletin_board.set_value(repeat_key, bulletin_board.get_value(repeat_key) + 1)
	return RUNNING
