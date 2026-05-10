@tool
extends ActionLeaf

@export_group("Laning Settings")
@export var look_ahead_distance: float = 200
@export var safety_buffer: float = 150.0

@export_group("Wobble Settings")
@export var max_lateral_offset: float = 60.0
@export var wobble_speed: float = 2.0
@export var wobble_strength: float = 15.0

@export var lerp_speed: float = 5.0

var _time: float = 0.0
var _random_lane_side: float = 1.0

func _ready():
	_random_lane_side = 1.0 if randf() > 0.5 else -1.0
	_time = randf() * 10.0

func tick(actor, blackboard: Blackboard):
	_time += get_process_delta_time()
	var ship_controller = actor as ShipController
	if not ship_controller or not ship_controller.ship: return FAILURE

	var ship = ship_controller.ship as Ship
	var path: Path2D = ship_controller.assigned_lane
	if not path: return FAILURE

	var curve = path.curve
	var current_offset = curve.get_closest_offset(ship.global_position)
	var is_team_a = ship.team_component.team == TeamComponent.Team.A
	
	# Find Frontline
	var ally_minions = get_tree().get_nodes_in_group("minions").filter(
		func(m): return m.team_component.team == ship.team_component.team
	)
	
	var max_safe_offset = 0.0
	var path_length := curve.get_baked_length()
	var leading_offset: float = path_length * 0.4 if is_team_a else path_length * 0.6
	if ally_minions.is_empty():
		max_safe_offset = leading_offset
	else:
		var minion_offets: Array[float] = [leading_offset]
		for m in ally_minions:
			var m_off := curve.get_closest_offset(m.global_position)
			minion_offets.append(m_off)
	
		leading_offset = minion_offets.max if is_team_a else minion_offets.min()

	max_safe_offset = leading_offset - (safety_buffer if is_team_a else -safety_buffer)
	
	# Calculate target offset, clamed to frontline
	var raw_target_offset: float
	if is_team_a:
		raw_target_offset = current_offset + look_ahead_distance
		raw_target_offset = min(raw_target_offset, max_safe_offset)
	else:
		raw_target_offset = current_offset - look_ahead_distance
		raw_target_offset = max(raw_target_offset, max_safe_offset)
		
	# Wobble & Position
	var target_pos = curve.sample_baked(raw_target_offset)
	
	var next_point = curve.sample_baked(current_offset + (1.0 if is_team_a else -1.0))
	var	lane_direction = (next_point - curve.sample_baked(current_offset)).normalized()
	
	var perpendicular = Vector2(-lane_direction.y, lane_direction.x)
	
	var lateral_shift = (max_lateral_offset * _random_lane_side)
	lateral_shift += sin(_time * wobble_speed) * wobble_strength
	
	target_pos += perpendicular * lateral_shift
	var calculated_pos = target_pos
	
	var last_pos = blackboard.get_value("last_target_pos", ship.global_position)
	var smoothed_target = last_pos.lerp(calculated_pos, lerp_speed * get_process_delta_time())
	
	blackboard.set_value("last_target_pos", smoothed_target)
	
	if OS.is_debug_build():
		DebugDraw.draw_debug_circle(calculated_pos, 3.0, Color.BLUE)
		DebugDraw.draw_debug_circle(smoothed_target, 6.0, Color.GREEN)
		DebugDraw.draw_debug_line(calculated_pos, smoothed_target, Color.GRAY, 1.0)
	
	# Execution
	var dist_to_target = ship.global_position.distance_to(smoothed_target)
	if dist_to_target < 100.0:
		ship_controller.ship.movement.stop()
		return SUCCESS
	
	ship_controller.move_to_pos(smoothed_target)
	return RUNNING
