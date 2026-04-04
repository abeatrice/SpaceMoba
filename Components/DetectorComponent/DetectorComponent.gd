class_name DetectorComponent
extends Area2D

signal target_found(target: Node2D)
signal target_lost(target: Node2D)

@export var target_group: String

var current_target: Node2D = null

func _ready():
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)

func _on_area_entered(area: Node2D):
	var potential_target = area.get_parent()
	var other_team = potential_target.get_node_or_null("TeamComponent")
	if other_team and get_parent().team_component.is_enemy(other_team.team):
		_lock_target(potential_target)

func _on_area_exited(area: Node2D):
	if area.get_parent() == current_target:
		_unlock_target()
		_scan_for_next_target()

func _lock_target(target: Node2D):
	current_target = target
	target_found.emit(current_target)

func _unlock_target():
	target_lost.emit(current_target)
	current_target = null

func _scan_for_next_target():
	var areas = get_overlapping_areas()
	for a in areas:
		if a is HurtboxComponent:
			var body = a.get_parent()
			if body.is_in_group(target_group):
				_lock_target(body)
				return

func has_target() -> bool:
	return is_instance_valid(current_target)
