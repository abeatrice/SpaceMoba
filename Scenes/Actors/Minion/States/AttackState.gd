extends MinionState

func physics_process(_delta: float) -> void:
	if not minion: return

	if not minion.targeting.is_target_valid():
		transitioned.emit("movestate")
		return
	
	var dir = minion.targeting.get_dir_to_target()
	minion.rotation = lerp_angle(minion.rotation, dir.angle(), 0.1)
	
	minion.velocity = minion.get_avoidance_velocity()
	minion.move_and_slide()
	
	if minion.attack_timer.is_stopped():
		minion._fire_projectile()
		minion.attack_timer.start()
