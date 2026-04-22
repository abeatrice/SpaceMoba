extends CameraState

func physics_process(delta: float) -> void:
	if not camera: return

	if Input.is_action_pressed("camera_snap"):
		transitioned.emit("lockedstate")
		return

	var pan_move = camera._get_edge_panning_vector()
	camera.global_position += pan_move * camera.pan_speed * delta
