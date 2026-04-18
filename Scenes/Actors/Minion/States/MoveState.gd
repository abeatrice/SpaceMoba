extends MinionState

func physics_process(delta: float) -> void:
	if not minion: return

	if minion.targeting.is_target_valid():
		transitioned.emit("attackstate")
		return
		
	if minion.path_controller:
		var old_pos = minion.global_position
		var move_amount = minion.move_speed * delta
		if minion.is_reversed:
			minion.path_controller.progress -= move_amount
			if minion.path_controller.progress_ratio <= 0.0:
				minion.path_controller.queue_free()
		else:
			minion.path_controller.progress += move_amount
			if minion.path_controller.progress_ratio >= 1.0:
				minion.path_controller.queue_free()

		var distance_moved = old_pos.distance_to(minion.global_position)
		if distance_moved > 0.1:
			var move_dir = old_pos.direction_to(minion.global_position)
			minion.rotation = lerp_angle(minion.rotation, move_dir.angle(), 0.1)

		minion.velocity = minion.get_avoidance_velocity()
		minion.move_and_slide()
