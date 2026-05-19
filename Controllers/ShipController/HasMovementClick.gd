@tool
extends ConditionLeaf

func tick(actor, blackboard: Blackboard):
	var ship_controller = actor as ShipController
	if not ship_controller.ship: return FAILURE
	
	var click_pos = blackboard.get_value("movement_click_target", Vector2.ZERO)
	if click_pos == Vector2.ZERO: return FAILURE

	return SUCCESS
