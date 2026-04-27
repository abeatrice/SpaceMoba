extends ShipState

func enter(_msg := {}) -> void:
	if not ship.movement.destination_reached.is_connected(_on_arrived):
		ship.movement.destination_reached.connect(_on_arrived, CONNECT_ONE_SHOT)

func physics_process(_delta: float) -> void:
	if not ship.movement.is_moving:
		ship.state.transition("idlestate")

func _on_arrived():
	ship.state.transition("idlestate")

func exit():
	if ship.movement.destination_reached.is_connected(_on_arrived):
		ship.movement.destination_reached.disconnect(_on_arrived)
