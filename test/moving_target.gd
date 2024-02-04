extends Sprite2D

@export var origin_offset := 64


func _ready() -> void:
	pass # Replace with function body.


func _physics_process(delta: float) -> void:
	var child_count := get_child_count()
	var pattern_origin = Vector2(global_position.x + (origin_offset * cos(360.0/child_count)), global_position.y + (origin_offset * sin(360.0/child_count)))

	var radians : float = 2 * PI / child_count # convert to radians for function params
	for p in range(0, child_count):
		# calculate fire angle, taking spread, and angle offset modifiers
		var angle = get_child(p).global_position.angle_to_point(global_position) + (radians * p)
		var fire_origin = global_position + (pattern_origin.from_angle(angle) * origin_offset)
		
		print("[%s]=%s" % [p, fire_origin])
