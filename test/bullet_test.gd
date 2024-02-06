extends Camera2D

@export var texture : CurveTexture

@export var count_2 := 20
@export var t_1 : Texture2D
@export var z : ZigZag
@export var seq_1 : Sequence
@export var data_1 : BulletData

#@export var ring_1 : RingPattern

@export var rings : Array[DanmakuPattern]
@export var lasers : Array[DanmakuPattern]

#var c : Callable = func(): pass
var duration := 0
var t := 0

var running := false

var c_t := 0

func _physics_process(delta: float) -> void:
	if !running: return


func _input(event: InputEvent) -> void:
	if not event is InputEventKey and not event is InputEventAction and not event is InputEventJoypadButton and not event is InputEventJoypadMotion: return
	
	# debugging
	var just_pressed = event.is_pressed() and not event.is_echo()
	if Input.is_key_pressed(KEY_1) and just_pressed:
		var b = BulletPool.get_next_bullet(data_1, PI, 60, 0, Vector2.ZERO, z, "test_key")
		
		b.fire()
	elif Input.is_key_pressed(KEY_2) and just_pressed:
		pass
	elif Input.is_key_pressed(KEY_3) and just_pressed:
		var b = BulletPool.get_next_bullet(data_1, PI, 60, 0, Vector2.ZERO, seq_1, "test_key")
		
		b.fire()
	#elif Input.is_key_pressed(KEY_4) and just_pressed:
		#ring_1.bulletin_board.set_value("test", 0)
		#ring_1.custom_update = func(delta, pattern, board):
			#board.set_value("test", board.get_value("test") + 1)
			#if board.get_value("test") == 15:
				#board.set_value("test", 0)
				#pattern.angle_offset += (PI / 6)
		#ring_1.angle_offset = 0
		#ring_1.custom_repeat = func(delta, pattern, board):
			#pattern.angle_offset += (PI / 24)
		#rings[0].fire()
	elif Input.is_key_pressed(KEY_5) and just_pressed:
		rings[1].fire()
	elif Input.is_key_pressed(KEY_6) and just_pressed:
		rings[2].fire()
	elif Input.is_key_pressed(KEY_7) and just_pressed:
		rings[3].fire()
	elif Input.is_key_pressed(KEY_8) and just_pressed:
		rings[4].fire()
	elif Input.is_key_pressed(KEY_9) and just_pressed:
		rings[5].fire()
	elif Input.is_key_pressed(KEY_0) and just_pressed:
		rings[6].fire()
	elif Input.is_key_pressed(KEY_MINUS) and just_pressed:
		rings[7].fire()
	elif Input.is_key_pressed(KEY_Q) and just_pressed:
		lasers[0].fire()
	elif Input.is_key_pressed(KEY_W) and just_pressed:
		for p in $moving_target.get_children():
			if p is DanmakuPattern:
				p.fire()
