class_name LaserBase extends BulletBase


func _ready() -> void:
	super._ready()
	duration = 300 # 5 seconds


func _move_update(delta : float, bullet : BulletBase, bulletin_board : BulletinBoard) -> void:
	if !camera: 
		_disable()
		return
	
	# frame up time
	up_time += 1
	
	# if been alive for duration, expire bullet
	if duration > 0 and up_time >= duration:
		timeout.call(bullet)
		return
	
	#print("v=%s,a=%s" % [velocity, acceleration])
	#velocity = min(velocity + acceleration, max_velocity)
	#velocity = max(min(velocity + acceleration, max_velocity), 0)
	#velocity = clamp(velocity + acceleration, 0, max_velocity)
	
	# Take into consideration angle to arc
	virtual_position = Vector2(virtual_position.x + (velocity * delta) * cos(angle), virtual_position.y + (velocity * delta) * sin(angle))
	# update rotation of texture and transform if bullet is directed
	if directed:
		look_at(virtual_position)
		query.transform.looking_at(virtual_position)
	
	query.transform = global_transform
	global_position = virtual_position + position_offset
	
	#if global_position.y <= -(camera.global_position + screen_extents).y or global_position.y >= (camera.global_position + screen_extents).y or global_position.x <= -(camera.global_position + screen_extents).x or global_position.x >= (camera.global_position + screen_extents).x:
		## when reaching edge of screen, disable bullet or bounce if applicable
		#if max_bounces > 0 and current_bounces < max_bounces:
			#if global_position.y <= -(camera.global_position + screen_extents).y or global_position.y >= (camera.global_position + screen_extents).y:
				#angle = -angle
			#elif global_position.x <= -(camera.global_position + screen_extents).x or global_position.x >= (camera.global_position + screen_extents).x:
				#angle = -PI - angle
			#current_bounces += 1
		#else:
			#_disable()
		#return
