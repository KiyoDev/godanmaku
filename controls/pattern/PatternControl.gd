@icon("res://addons/godanmaku/icons/pattern_control.svg")
class_name PatternControl extends Node


signal finished


enum {
	RUNNING,
	SUCCESS,
	FINISHED
}


@export var sub_control : PatternControl


func _before_set(pattern : DanmakuPattern, bulletin_board : BulletinBoard) -> void:
	pass


func _set_custom_update(pattern : DanmakuPattern, bulletin_board : BulletinBoard) -> void:
	pattern.custom_update = _custom_update


func _set_custom_repeat(pattern : DanmakuPattern, bulletin_board : BulletinBoard) -> void:
	pattern.custom_repeat = _custom_repeat


func _custom_update(delta : float, pattern : DanmakuPattern, bulletin_board : BulletinBoard) -> int:
	return SUCCESS


func _custom_repeat(delta : float, pattern : DanmakuPattern, bulletin_board : BulletinBoard) -> int:
	return SUCCESS


func _interupt(pattern : DanmakuPattern, bulletin_board : BulletinBoard) -> void:
	pass
