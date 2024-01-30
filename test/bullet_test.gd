extends Camera2D


@export var t_1 : Texture2D
@export var seq_1 : Sequence


var c : Callable = func(): pass
var duration := 0
var t := 0

var running := false




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
		b.texture = t_1
		b.hframes = 16
		b.vframes = 16
		b.angle = PI
		
		var shape := CircleShape2D.new()
		shape.radius = 4
		
		b.before_spawn(shape, 0b0100_0000_0000)
		b.spawn()
	elif Input.is_key_pressed(KEY_2) and just_pressed:
		running = !running
		duration = 5
		c = func():
			t += 1
			if t >= duration:
				t = 0
				var b = BulletBase.new()
				add_child(b)
				b.texture = t_1
				b.hframes = 16
				b.vframes = 16
				b.angle = PI
				
				var shape := CircleShape2D.new()
				shape.radius = 4
				
				b.before_spawn(shape, 0b0100_0000_0000)
				
				var z = ZigZag.new()
				add_child(z)
				z.angle = 60
				z.frames = 30
				
				z._set_custom_update(b, b.bulletin_board)
				
				b.spawn()
	elif Input.is_key_pressed(KEY_3) and just_pressed:
		var b = BulletBase.new()
		add_child(b)
		b.texture = t_1
		b.hframes = 16
		b.vframes = 16
		b.angle = PI
		b.velocity = 60
		
		var shape := CircleShape2D.new()
		shape.radius = 4
		
		b.before_spawn(shape, 0b0100_0000_0000)
		
		#seq_1 = Sequence.new()
		#
		#var z = ZigZag.new()
		#z.angle = 60
		#z.frames = 30
		#z.duration = 120
		#
		#var r = ResetMove.new()
		#r.duration = 30
		#
		#seq_1.add_child(z.duplicate(0b0111))
		#seq_1.add_child(r.duplicate(0b0111))
		#seq_1.add_child(z.duplicate(0b0111))
		#
		#add_child(seq_1)
		
		seq_1._set_custom_update(b, b.bulletin_board)
		
		b.spawn()
