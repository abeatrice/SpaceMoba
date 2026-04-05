class_name TargetingComponent
extends Node2D

@onready var detector: DetectorComponent = get_parent().get_node("EnemiesDetectorComponent")

var current_target: Node2D = null

func _ready():
	detector.target_found.connect(_on_target_found)
	detector.target_lost.connect(_on_target_lost)
	
func is_target_valid() -> bool:
	return is_instance_valid(current_target)
	
func get_dir_to_target() -> Vector2:
	if not is_target_valid(): return Vector2.ZERO
	return global_position.direction_to(current_target.global_position)
	
func is_aligned(threshold: float = 0.9) -> bool:
	if not is_target_valid(): return false
	var forward = Vector2.RIGHT.rotated(get_parent().rotation)
	return forward.dot(get_dir_to_target()) > threshold
	
func _on_target_found(target): current_target = target
func _on_target_lost(_target): current_target = null
