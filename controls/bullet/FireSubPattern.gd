class_name FireSubPattern extends ControlNode


@onready var instance_key = "fire_sub_pattern_%s" % self.get_instance_id()

@export var pattern : DanmakuPattern


#var _pattern : DanmakuPattern


func _before_update(bullet : BulletBase, bulletin_board : BulletinBoard) -> void:
	super._before_update(bullet, bulletin_board)
	
	var _pattern = pattern.duplicate(0b0111) as DanmakuPattern
	bullet.pattern.add_child(_pattern)
	bulletin_board.set_value(instance_key, _pattern)


func _set_custom_update(bullet : BulletBase, bulletin_board : BulletinBoard) -> void:
	_before_update(bullet, bulletin_board)
	bullet.custom_update = _custom_update


func _custom_update(delta : float, bullet : BulletBase, bulletin_board : BulletinBoard) -> int:
	#var p : DanmakuPattern = pattern.duplicate(0b0111) as DanmakuPattern
	var _pattern : DanmakuPattern = bulletin_board.get_value(instance_key) as DanmakuPattern
	_pattern.global_position = bullet.global_position
	_pattern.fire()
	_pattern.finished.connect(func(): _pattern.queue_free()) # delete pattern after finishing
	return SUCCESS
