@tool
extends ActionLeaf

@export var slot: String = "q"

func tick(actor, _blackboard: Blackboard):
	var ship_controller = actor as ShipController
	if not ship_controller.ship: return FAILURE

	var targeting = ship_controller.ship.targeting
	if not targeting.is_target_valid(): return FAILURE
	
	ship_controller.ship.use_ability(
		slot, 
		targeting.current_target.global_position, 
		targeting.current_target
	)

	return SUCCESS
