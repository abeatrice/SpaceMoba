extends FortState

func physics_process(_delta: float) -> void:
	if not fort: return
	
	if fort.targeting.is_target_valid():
		transitioned.emit("attackstate")
		return

	var target_angle = Vector2.RIGHT.angle()
	if fort.team_component.team == TeamComponent.Team.B:
		target_angle = Vector2.LEFT.angle()
	fort.rotation = lerp_angle(fort.rotation, target_angle, 0.1)
