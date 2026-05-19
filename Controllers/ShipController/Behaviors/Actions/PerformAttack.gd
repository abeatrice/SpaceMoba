@tool
extends ActionLeaf

func tick(actor, _blackboard: Blackboard):
	var ship_controller = actor as ShipController
	if not ship_controller.ship: return FAILURE
	
	var ship = ship_controller.ship
	
	var targeting = ship.targeting
	if not targeting.is_target_valid(): return FAILURE
	
	ship.command_attack(targeting.current_target)
		
	if not ship.attack_timer.is_stopped():
		return RUNNING
	
	return SUCCESS
