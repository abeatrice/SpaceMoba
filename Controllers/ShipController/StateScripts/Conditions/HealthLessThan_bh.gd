@tool
extends ConditionLeaf

@export_range(0, 100, 1, "suffix:%") var health_percentage: int = 0

func tick(actor, _blackboard: Blackboard):
	if not actor.ship: return FAILURE
	var ship: Ship = actor.ship as Ship
	var ship_health_percent = ship.health.get_health_percent()
	if ship_health_percent <= health_percentage:
		return SUCCESS
	else:
		return FAILURE
