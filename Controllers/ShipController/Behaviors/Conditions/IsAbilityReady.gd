@tool
extends ConditionLeaf

@export var slot: String = "q"

func tick(actor, _blackboard: Blackboard):
	var ship_controller = actor as ShipController
	if not ship_controller.ship: return FAILURE

	var ship = ship_controller.ship as Ship
	if ship.state.is_current_state("caststate"): return FAILURE
	
	if ship_controller.ship.cooldowns.is_ready(slot):
		return SUCCESS
		
	return FAILURE
