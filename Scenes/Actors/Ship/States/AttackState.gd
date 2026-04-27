extends ShipState

func enter(_msg := {}) -> void:
	if ship.targeting.current_target:
		ship.targeting.set_targets_outline(true)

func physics_process(delta: float) -> void:
	if not ship.targeting.is_target_valid():
		transitioned.emit("idlestate")
		return

	var target = ship.targeting.current_target
	var distance = ship.targeting.get_dist_to_target_edge()
	var direction = ship.targeting.get_dir_to_target()

	if distance > ship.attack_range:
		ship.movement.move_to(target.global_position)
	else:
		ship.movement.stop()
		ship.rotation = rotate_toward(
			ship.rotation, 
			direction.angle(), 
			ship.movement.rotation_speed * delta
		)
		if ship.targeting.is_aligned(0.9) and ship.attack_timer.is_stopped():
			ship._fire_projectile()
			ship.attack_timer.start()

func exit() -> void:
	ship.movement.stop()
	if is_instance_valid(ship.targeting.current_target):
		ship.targeting.set_targets_outline(false)
