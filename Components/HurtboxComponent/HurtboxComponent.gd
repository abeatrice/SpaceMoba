class_name HurtboxComponent
extends Area2D

@export var health_component: HealthComponent

func receive_hit(damage_amount: float):
	if health_component:
		health_component.damage(damage_amount)
