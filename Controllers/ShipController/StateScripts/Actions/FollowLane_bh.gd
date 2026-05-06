@tool
extends ActionLeaf

@export var look_ahead_distance: float = 200.0

func tick(actor, _blackboard: Blackboard):
	var ship_controller = actor as ShipController
	var ship = ship_controller.ship as Ship
	
	var path: Path2D = ship_controller.assigned_lane
	if not path: return FAILURE

	var curve = path.curve
	var current_offset = curve.get_closest_offset(ship.global_position)
	
	var target_offset = 0.0
	if ship.team_component.team == TeamComponent.Team.A:
		target_offset = current_offset + look_ahead_distance
	else: 
		target_offset = current_offset - look_ahead_distance
		
	var target_pos = curve.sample_baked(target_offset)
	
	ship_controller.move_to_pos(target_pos)
	
	return SUCCESS
