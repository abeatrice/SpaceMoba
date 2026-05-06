class_name HealthComponent
extends Node

signal died
signal health_changed(new_health)

@export var max_health: float = 50.0

@onready var current_health: float = max_health

var is_dying: bool = false

func damage(amount: float):
	if is_dying: return
	
	current_health -= amount
	health_changed.emit(current_health)
	if current_health <= 0:
		is_dying = true
		died.emit()

func get_health_percent() -> float:
	return (current_health / max_health) * 100
