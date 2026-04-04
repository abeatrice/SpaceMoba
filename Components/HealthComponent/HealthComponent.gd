class_name HealthComponent
extends Node

signal died
signal health_changed(new_health)

@export var max_health: float = 50.0

@onready var current_health: float = max_health

func damage(amount: float):
	current_health -= amount
	health_changed.emit(current_health)
	if current_health <= 0:
		died.emit()
