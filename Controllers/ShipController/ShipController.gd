class_name ShipController
extends Node2D

@export var ship: Ship
@export var assigned_lane: Path2D

func move_to_pos(pos: Vector2 = Vector2.ZERO):
	ship.targeting.current_target = null
	ship.movement.move_to(pos)
	if ship.state.get_current_state_name() != "movestate":
		ship.state.transition("movestate")
