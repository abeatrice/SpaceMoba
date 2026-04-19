extends ShipState

func enter() -> void:
	if ship.targeting.current_target:
		ship.targeting.set_targets_outline(true)

func physics_process(delta: float) -> void:
	if not ship.targeting.is_target_valid():
		transitioned.emit("idlestate")
		return

	var distance = ship.targeting.get_dist_to_target_edge()

	var direction = ship.targeting.get_dir_to_target()
	if distance > ship.attack_range:
		var target_velocity = direction * ship.speed
		ship.velocity = ship.velocity.lerp(target_velocity, 10.0 * delta)
		if distance > ship.rotation_stopping_distance:
			ship.rotation = rotate_toward(ship.rotation, direction.angle(), ship.turn_speed * delta)
		ship.move_and_slide()
	else:
		ship.velocity = Vector2.ZERO
		ship.rotation = rotate_toward(ship.rotation, direction.angle(), ship.turn_speed * delta)
		if ship.targeting.is_aligned(0.9) and ship.attack_timer.is_stopped():
			ship._fire_projectile()
			ship.attack_timer.start()

func exit() -> void:
	ship.targeting.set_targets_outline(false)
