extends ShipState

func physics_process(delta: float) -> void:
	var distance = ship.global_position.distance_to(ship.target_position)
	var direction = ship.global_position.direction_to(ship.target_position)
	
	if distance > ship.stopping_distance:
		var target_velocity = direction * ship.speed
		ship.velocity = ship.velocity.lerp(target_velocity, 10.0 * delta)
	else:
		ship.velocity = Vector2.ZERO
		transitioned.emit("idlestate")
	
	if distance > ship.rotation_stopping_distance:
		ship.rotation = rotate_toward(ship.rotation, direction.angle(), ship.turn_speed * delta)

	ship.move_and_slide()
