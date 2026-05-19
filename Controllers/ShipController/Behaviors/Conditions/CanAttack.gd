@tool
extends ConditionLeaf

func tick(actor, _blackboard: Blackboard):
	var ship_controller = actor as ShipController
	if not ship_controller.ship: return FAILURE
	
	var ship = ship_controller.ship as Ship

	var targeting = ship_controller.ship.targeting
	if not targeting.is_target_valid(): return FAILURE

	if ship.attack_timer.is_stopped(): return SUCCESS

	return FAILURE
