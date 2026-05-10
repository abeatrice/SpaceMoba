class_name DetectorComponent
extends Area2D

signal targets_updated

var targets: Array[Node2D] = []

func _ready():
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)

func _on_area_entered(area: Node2D):
	var potential = area.get_parent()
	var other_team = potential.get_node_or_null("TeamComponent")
	if other_team and get_parent().team_component.is_enemy(other_team.team):
		if not targets.has(potential):
			targets.append(potential)
			targets_updated.emit()

func _on_area_exited(area: Node2D):
	var potential = area.get_parent()
	if targets.has(potential):
		targets.erase(potential)
		targets_updated.emit()

func get_targets() -> Array[Node2D]:
	targets = targets.filter(func(t): return is_instance_valid(t))
	return targets
	
func has_any_minions() -> bool:
	for t in get_targets():
		if t.is_in_group("minions"): return true
	return false
