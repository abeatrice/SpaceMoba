@tool
extends ConditionLeaf

@export var safe_distance: float = 256.0

func tick(actor, _blackboard: Blackboard):
	if not actor.ship: return FAILURE

	var ship = actor.ship as Ship
	var nearby_forts = get_tree().get_nodes_in_group("forts") as Array[Fort]
	
	for fort in nearby_forts:
		if fort.team_component.is_enemy(ship.team_component.team):
			var dist = ship.global_position.distance_to(fort.global_position)
			if dist < safe_distance:
				if fort.detector.has_any_minions():
					return SUCCESS
				else:
					return FAILURE
		
	return FAILURE
