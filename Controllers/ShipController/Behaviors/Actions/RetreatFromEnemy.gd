@tool
extends ActionLeaf

func tick(actor, _blackboard: Blackboard):
	var ship_controller: ShipController = actor as ShipController
	var target_pos = Vector2(11000, 3300)

	ship_controller.move_to_pos(target_pos)
	
	var distance = actor.ship.global_position.distance_to(target_pos)
	if distance < 100.0:
		return SUCCESS

	return RUNNING
