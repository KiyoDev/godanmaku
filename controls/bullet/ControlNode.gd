@icon("res://addons/godanmaku/icons/control.svg")
class_name ControlNode extends Node


signal finished


enum {
	RUNNING,
	SUCCESS,
	FINISHED
}


@export var alt_bullet_data : BulletData


var reverse : bool = false


func _before_update(bullet : BulletBase, bulletin_board : BulletinBoard) -> void:
	if alt_bullet_data:
		#bullet.update_rotation()
		bullet._swap_data(alt_bullet_data)


func _set_custom_update(bullet : BulletBase, bulletin_board : BulletinBoard) -> void:
	bullet.custom_update = _custom_update


func _custom_update(delta : float, bullet : BulletBase, bulletin_board : BulletinBoard) -> int:
	return SUCCESS


func _interupt(bullet : BulletBase, bulletin_board : BulletinBoard) -> void:
	pass
