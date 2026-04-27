extends ShipState

var ability_data: Dictionary

func enter(msg := {}) -> void:
	ability_data = msg
	ship.movement.stop()

	if ability_data.has("target_pos"):
		var target_pos = ability_data.get("target_pos", Vector2.ZERO)
		var dir = (target_pos - ship.global_position).normalized()
		ship.rotation = dir.angle()
		_start_cast_timer()

func _start_cast_timer():
	var cast_time = ability_data.get("cast_time", 0.0)
	get_tree().create_timer(cast_time).timeout.connect(_execute_ability)
	
func _execute_ability():
	if ship.state.current_state != self: return
	
	var slot = ability_data.get("slot", "")
	var target_pos = ability_data.get("target_pos", Vector2.ZERO)

	if slot == "q":
		ship._fire_plasma_bolt(target_pos)
	
	transitioned.emit("idlestate")
