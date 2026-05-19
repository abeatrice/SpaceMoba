extends ShipState

var next_state_on_arrival: String = "idlestate"
var last_tracked_target_pos: Vector2 = Vector2.INF

func enter(msg := {}) -> void:
	next_state_on_arrival = msg.get("next_state", "idlestate")
	last_tracked_target_pos = Vector2.INF

	if next_state_on_arrival == "attackstate" and ship.targeting.is_target_valid():
		var target = ship.targeting.current_target
		last_tracked_target_pos = target.global_position
		ship.movement.move_to(last_tracked_target_pos)
	else:
		if not ship.movement.destination_reached.is_connected(_on_arrived):
			ship.movement.destination_reached.connect(_on_arrived, CONNECT_ONE_SHOT)

func physics_process(_delta: float) -> void:
	if next_state_on_arrival == "attackstate":
		if not ship.targeting.is_target_valid():
			ship.state.transition("idlestate")
			return
			
		if ship.in_attack_range():
			ship.state.transition("attackstate")
			return
			
		var target = ship.targeting.current_target
		if target.global_position.distance_to(last_tracked_target_pos) > 10.0:
			last_tracked_target_pos = target.global_position
			ship.movement.move_to(last_tracked_target_pos)

	else:
		if not ship.movement.is_moving:
			ship.state.transition("idlestate")

func _on_arrived():
	ship.state.transition(next_state_on_arrival)

func exit():
	if ship.movement.destination_reached.is_connected(_on_arrived):
		ship.movement.destination_reached.disconnect(_on_arrived)
