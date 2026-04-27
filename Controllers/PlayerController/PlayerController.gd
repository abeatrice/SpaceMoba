class_name PlayerController
extends Node2D

@export var hero: CharacterBody2D

var is_dragging: bool = false

func _input(event):
	if not is_instance_valid(hero): return

	if event.is_action_pressed("move_attack"):
		var click_pos = get_global_mouse_position()
		var target = _query_target_at_pos(click_pos)
		
		if target:
			is_dragging = false
			hero.targeting.current_target = target
			hero.state.transition("attackstate")
			hero._spawn_click_marker(click_pos, true)
		else:
			is_dragging = true
			_move_to_mouse()
			hero._spawn_click_marker(click_pos, false)
	elif event.is_action_released("move_attack"):
		is_dragging = false
	elif event.is_action_pressed("ability_q"):
		_execute_quick_cast("q")
	elif event.is_action_pressed("ability_w"):
		_execute_quick_cast("w")
	elif event.is_action_pressed("ability_e"):
		_execute_quick_cast("e")
	elif event.is_action_pressed("ability_r"):
		_execute_quick_cast("r")
	elif event.is_action_pressed("ability_r"):
		_execute_quick_cast("d")
	elif event.is_action_pressed("ability_1"):
		_execute_quick_cast("1")
	elif event.is_action_pressed("ability_2"):
		_execute_quick_cast("2")
	elif event.is_action_pressed("ability_3"):
		_execute_quick_cast("3")
	elif event.is_action_pressed("ability_4"):
		_execute_quick_cast("4")

func _process(_delta):
	if is_dragging and is_instance_valid(hero):
		_move_to_mouse()

func _move_to_mouse():
	var mouse_pos = get_global_mouse_position()
	hero.targeting.current_target = null
	hero.movement.move_to(mouse_pos)
	hero.state.transition("movestate")

func _query_target_at_pos(pos: Vector2) -> Node2D:
	var circle = CircleShape2D.new()
	circle.radius = 32.0
	
	var query = PhysicsShapeQueryParameters2D.new()
	query.shape = circle
	query.transform = Transform2D(0, pos)
	query.collision_mask = TeamComponent.LAYER_TEAM_B_HURTBOX
	query.collide_with_areas = true
	
	var space_state = hero.get_world_2d().direct_space_state
	var results = space_state.intersect_shape(query)
	
	if results.size() > 0:
		var closest_target = null
		var min_dist = INF
		for res in results:
			var target = res.collider.get_parent()
			var dist = pos.distance_to(target.global_position)
			if dist < min_dist:
				min_dist = dist
				closest_target = target
		return closest_target

	return null

func _execute_quick_cast(slot: String):
	var mouse_pos = get_global_mouse_position()
	var target = _query_target_at_pos(mouse_pos)
	
	if hero.has_method("use_ability"):
		hero.use_ability(slot, mouse_pos, target)
