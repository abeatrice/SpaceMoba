extends BaseState

func physics_process(_delta: float) -> void:
	if not base: return
	
	if not base.targeting.is_target_valid():
		transitioned.emit("idlestate")
		return

	base.rotation = lerp_angle(base.rotation, base.targeting.get_dir_to_target().angle(), 0.1)
	
	if base.targeting.is_aligned(0.9) and base.attack_timer.is_stopped():
		base._fire_projectiles()
		base.attack_timer.start()
