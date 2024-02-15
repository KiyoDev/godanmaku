class_name BulletinBoard extends Resource


var board : Dictionary = {}:
	set(b):
		board = b


func keys() -> Array[String]:
	var keys : Array[String]
	keys.assign(board.keys().duplicate())
	return keys


func set_value(key : Variant, value : Variant) -> void:
	board[key] = value


func get_value(key : Variant, default_value : Variant = null) -> Variant:
	return board.get(key, default_value) if board.has(key) and board[key] != null else default_value


func has_value(key : Variant) -> bool:
	return board.has(key) and board[key] != null


func erase_value(key : Variant) -> void:
	board[key] = null


func clear() -> void:
	board.clear()
