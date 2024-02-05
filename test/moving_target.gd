extends Sprite2D

@export var origin_offset := 112
#@export var target_offset := 32
@export var velocity := 120
@export var angle := 90

@export var pattern : DanmakuPattern
@export var count := 3

var t := 0
var angle_offset := 0.0

func _ready() -> void:
	for i in count:
		add_child(pattern.duplicate(0b0111))
		
	var child_count := get_child_count()
	var pattern_origin = Vector2(global_position.x + (origin_offset * cos(360.0/child_count)), global_position.y + (origin_offset * sin(360.0/child_count)))

	var radians : float = 2 * PI / child_count # convert to radians for function params
	for p in range(0, child_count):
		# calculate fire angle, taking spread, and angle offset modifiers
		var child : Node2D = get_child(p)
		child.show()
		var angle = child.global_position.angle_to_point(global_position) + (radians * p)
		var fire_origin = global_position + (pattern_origin.from_angle(angle) * origin_offset)
		
		#print("[%s]=%s" % [p, fire_origin])
		child.global_position = fire_origin
		#pattern.pattern_ctrl = P


func _physics_process(delta: float) -> void:
	global_position.x += cos(delta * t / 2) / 2
	var radians : float = 2 * PI / get_child_count() # convert to radians for function params
	angle_offset += (angle * PI / 180) * delta * velocity * delta
	for p in get_children():
		var i := p.get_index()
		#if p.get_index() > 0: continue
		var pos = p.global_position
		#angle_offset += (angle * PI / 180)  * delta + p.global_position.angle_to_point(global_position) + (radians * p.get_index()) * delta
		var virtual_position = Vector2(cos(angle_offset + (radians * i)), sin(angle_offset + (radians * i))) * origin_offset + global_position
		#var virtual_position = Vector2((global_position.x + pos.x) + (velocity * delta) * cos(angle_offset), (global_position.y + pos.y) + (velocity * delta) * sin(angle_offset))
		#print("%s - virtual_position=%s" % [t, Vector2(cos(angle_offset), sin(angle_offset)) * origin_offset])
		p.global_position = virtual_position
	
	t += 1
