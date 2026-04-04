class_name HitboxComponent
extends Area2D

@export var damage: float = 10.0

var target_group: String = ""

func _init():
	area_entered.connect(_on_area_entered)

func _on_area_entered(area: Area2D):
	if area is HurtboxComponent:
		var victim = area.get_parent()
		if target_group == "" or victim.is_in_group(target_group):
			area.receive_hit(damage)
