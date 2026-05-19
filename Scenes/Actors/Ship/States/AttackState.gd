extends ShipState

func enter(_msg := {}) -> void:
	ship.movement.stop()

func physics_process(delta: float) -> void:
	if not ship.targeting.is_target_valid():
		transitioned.emit("idlestate")
		return
		
	if not ship.in_attack_range():
		ship.movement.move_to(ship.targeting.current_target.global_position)
		ship.state.transition("movestate", {"next_state": "attackstate"})
		return

	var direction = ship.targeting.get_dir_to_target()
	ship.rotation = rotate_toward(
		ship.rotation, 
		direction.angle(), 
		ship.movement.rotation_speed * delta
	)

	if ship.targeting.is_aligned(0.9) and ship.attack_timer.is_stopped():
		ship.movement.stop()
		ship._fire_projectile()
		ship.attack_timer.start()

func exit() -> void:
	ship.movement.stop()
