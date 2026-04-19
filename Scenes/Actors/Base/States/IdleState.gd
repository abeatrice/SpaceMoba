extends BaseState

func physics_process(_delta: float) -> void:
	if not base: return
	
	if base.targeting.is_target_valid():
		transitioned.emit("attackstate")
		return

	var target_angle = Vector2.RIGHT.angle()
	if base.team_component.team == TeamComponent.Team.B:
		target_angle = Vector2.LEFT.angle()
	base.rotation = lerp_angle(base.rotation, target_angle, 0.1)
