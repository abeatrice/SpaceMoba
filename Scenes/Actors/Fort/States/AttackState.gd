extends FortState

func physics_process(_delta: float) -> void:
	if not fort: return
	
	if not fort.targeting.is_target_valid():
		transitioned.emit("idlestate")
		return

	fort.rotation = lerp_angle(fort.rotation, fort.targeting.get_dir_to_target().angle(), 0.1)
	
	if fort.targeting.is_aligned(0.9) and fort.attack_timer.is_stopped():
		fort._fire_projectiles()
		fort.attack_timer.start()
