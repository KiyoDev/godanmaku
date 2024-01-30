class_name DanmakuController extends Node


func _physics_process(delta: float) -> void:
	pass # TODO: tick pattern


# Called by bullet to know its actions
func control(bullet : BulletBase) -> void:
	#if self.get_child_count() == 1:
	# child[0] = pattern, child[1] = controls
	get_child(1).tick()
