extends Camera2D

@export var count_2 := 20
@export var t_1 : Texture2D
@export var z : ZigZag
@export var seq_1 : Sequence
@export var data_1 : BulletData

var c : Callable = func(): pass
var duration := 0
var t := 0

var running := false

var c_t := 0

func _physics_process(delta: float) -> void:
	if !running: return
	c.call()


func _input(event: InputEvent) -> void:
	if not event is InputEventKey and not event is InputEventAction and not event is InputEventJoypadButton and not event is InputEventJoypadMotion: return
	
	# debugging
	var just_pressed = event.is_pressed() and not event.is_echo()
	if Input.is_key_pressed(KEY_1) and just_pressed:
		var b = BulletBase.new()
		add_child(b)
		b.before_spawn(data_1)
		b.hframes = 16
		b.vframes = 16
		b.angle = PI
		
		b.spawn()
	elif Input.is_key_pressed(KEY_2) and just_pressed:
		running = !running
		if !running:
			t = 0
			c_t = 0
			return
		duration = 5
		c = func():
			t += 1
			if t >= duration:
				if c_t == count_2: 
					running = false
					t = 0
					c_t = 0
					return
				c_t += 1
				t = 0
				var b = BulletBase.new()
				add_child(b)
				b.before_spawn(data_1)
				b.hframes = 16
				b.vframes = 16
				b.angle = PI
				
				z._set_custom_update(b, b.bulletin_board)
				
				b.spawn()
	elif Input.is_key_pressed(KEY_3) and just_pressed:
		var b = BulletBase.new()
		add_child(b)
		b.before_spawn(data_1)
		b.hframes = 16
		b.vframes = 16
		#b.angle = 7 * PI / 6
		b.angle = PI
		#b.angle = 2 * PI
		b.velocity = 60
		
		seq_1._set_custom_update(b, b.bulletin_board)
		
		b.spawn()
