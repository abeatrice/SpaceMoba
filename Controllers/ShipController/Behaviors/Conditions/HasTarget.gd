@tool
extends ConditionLeaf

func tick(actor, _blackboard: Blackboard):
	var ship_controller = actor as ShipController
	if not ship_controller.ship: return FAILURE
	
	var targeting = ship_controller.ship.targeting
	if targeting.is_target_valid(): 
		return SUCCESS
	
	return FAILURE
