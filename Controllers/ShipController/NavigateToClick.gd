@tool
extends ActionLeaf

func tick(actor, blackboard: Blackboard):
	var ship_controller = actor as ShipController
	if not ship_controller.ship: return FAILURE
	
	var click_pos = blackboard.get_value("movement_click_target", Vector2.ZERO)
	if click_pos == Vector2.ZERO: return FAILURE
	
	var dist = ship_controller.ship.global_position.distance_to(click_pos)
	if dist < 20.0:
		blackboard.set_value("movement_click_target", Vector2.ZERO)

	ship_controller.move_to_pos(click_pos)
	
	if OS.is_debug_build():
		DebugDraw.draw_debug_circle(click_pos, 6.0, Color.GREEN)
	
	return RUNNING
