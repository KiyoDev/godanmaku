class_name ControlNode extends Node


signal finished


enum {
	RUNNING,
	SUCCESS,
	FINISHED
}


func _before_update(bullet : BulletBase, bulletin_board : BulletinBoard) -> void:
	pass


func _set_custom_update(bullet : BulletBase, bulletin_board : BulletinBoard) -> void:
	bullet.custom_update = _custom_update


func _custom_update(delta : float, bullet : BulletBase, bulletin_board : BulletinBoard) -> int:
	return SUCCESS
