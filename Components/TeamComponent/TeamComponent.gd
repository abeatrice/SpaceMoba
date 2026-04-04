@tool
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
			if parent.has_method("update_team_visuals"):
				parent.update_team_visuals()

func is_enemy(other_team: Team) -> bool:
	if team == Team.A: return other_team == Team.B
	if team == Team.B: return other_team == Team.A
	return false

func get_enemy_group() -> String:
	return "team_b" if team == Team.A else "team_a"

func get_colors() -> Dictionary:
	var color_key = "A" if team == Team.A else "B"
	return colors[color_key]
