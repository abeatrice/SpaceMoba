extends CameraState

func enter(_msg := {}) -> void:
	camera.camera_offset = Vector2.ZERO

func physics_process(delta: float) -> void:
	if not camera: return

	if not is_instance_valid(camera.hero):
		transitioned.emit("unlockedstate")
		return
		
	if Input.is_action_pressed("camera_snap"):
		camera.camera_offset = Vector2.ZERO

	var pan_dir = camera._get_edge_panning_vector()
	camera.camera_offset += pan_dir * camera.pan_speed * delta
	camera.camera_offset = camera.camera_offset.limit_length(camera.max_offset)
	
	var target_pos = camera.hero.global_position + camera.camera_offset
	camera.global_position = camera.global_position.lerp(target_pos, camera.follow_speed * delta)
