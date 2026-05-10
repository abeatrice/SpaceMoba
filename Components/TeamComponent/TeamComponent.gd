class_name TeamComponent
extends Node

enum Team { NONE, A, B, NEUTRAL }

const LAYER_TEAM_A_HURTBOX = 2
const LAYER_TEAM_B_HURTBOX = 4

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

func _manage_groups(parent: Node2D):
	parent.remove_from_group("team_a")
	parent.remove_from_group("team_b")
	
	if team == Team.A:
		parent.add_to_group("team_a")
	elif team == Team.B:
		parent.add_to_group("team_b")
		
func sync_team_data(parent: Node2D, detector: DetectorComponent = null):
	_manage_groups(parent)

	var hurtbox: HurtboxComponent = parent.get_node_or_null("HurtboxComponent")
	
	if team == Team.A:
		if hurtbox:
			hurtbox.collision_layer = LAYER_TEAM_A_HURTBOX
			hurtbox.collision_mask = 0
		if detector:
			detector.collision_mask = LAYER_TEAM_B_HURTBOX
	elif team == Team.B:
		if hurtbox:
			hurtbox.collision_layer = LAYER_TEAM_B_HURTBOX
			hurtbox.collision_mask = 0
		if detector:
			detector.collision_mask = LAYER_TEAM_A_HURTBOX
	
	parent.queue_redraw()

func is_enemy(other_team: Team) -> bool:
	if team == Team.A: return other_team == Team.B
	if team == Team.B: return other_team == Team.A
	return false

func get_team_hurtbox_layer():
	return LAYER_TEAM_A_HURTBOX if team == Team.A else LAYER_TEAM_B_HURTBOX

func get_enemy_hurtbox_layer():
	return LAYER_TEAM_B_HURTBOX if team == Team.A else LAYER_TEAM_A_HURTBOX

func get_team_group() -> String:
	return "team_a" if team == Team.A else "team_b"

func get_enemy_group() -> String:
	return "team_b" if team == Team.A else "team_a"

func get_colors() -> Dictionary:
	var color_key = "A" if team == Team.A else "B"
	return colors[color_key]
