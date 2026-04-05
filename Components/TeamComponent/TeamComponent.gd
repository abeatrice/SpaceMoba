class_name TeamComponent
extends Node

enum Team { NONE, A, B, NEUTRAL }

var colors = {
	"A": {
		"primary": Color.SKY_BLUE
	},
	"B": {
		"primary": Color.INDIAN_RED
	},
	"NONE": {
		"primary": Color.GRAY
	},
	"NEUTRAL": {
		"primary": Color.GRAY
	}
}

@export var team: Team = Team.NONE:
	set(value):
		team = value
		if is_inside_tree():
			var parent = get_parent()
			var detector = parent.get_node_or_null("EnemiesDetectorComponent")
			sync_team_data(parent, detector)

func sync_team_data(parent: Node2D, detector: DetectorComponent = null):
	parent.remove_from_group("team_a")
	parent.remove_from_group("team_b")
	
	if team == Team.A:
		parent.add_to_group("team_a")
	elif team == Team.B:
		parent.add_to_group("team_b")
		
	if detector:
		detector.target_group = get_enemy_group()
	
	parent.queue_redraw()

func is_enemy(other_team: Team) -> bool:
	if team == Team.A: return other_team == Team.B
	if team == Team.B: return other_team == Team.A
	return false

func get_enemy_group() -> String:
	return "team_b" if team == Team.A else "team_a"

func get_colors() -> Dictionary:
	var color_key = "A" if team == Team.A else "B"
	return colors[color_key]
