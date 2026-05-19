@tool
extends ActionLeaf

@export var kite_range: float = 50.0
@export var jitter: float = 50.0

func tick(actor, blackboard: Blackboard):
	var ship_controller = actor as ShipController
	if not ship_controller.ship: return FAILURE
	
	var target = ship_controller.ship.targeting.current_target
	if not target: return FAILURE
	
	var angle = randf_range(0, TAU)
	var offset = Vector2.from_angle(angle) * (kite_range + randf_range(-jitter, jitter))
	var click_pos = target.global_position + offset
	
	blackboard.set_value("movement_click_target", click_pos)
	
	return SUCCESS
