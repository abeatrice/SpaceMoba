class_name CooldownComponent
extends Node

var cooldowns: Dictionary = {}

func setup_ability(slot: String, duration: float):
	if cooldowns.has(slot): return
	
	var timer = Timer.new()
	timer.one_shot = true
	timer.wait_time = duration
	add_child(timer)
	cooldowns[slot] = timer
	
func start(slot: String):
	if cooldowns.has(slot):
		cooldowns[slot].start()
		
func is_ready(slot: String) -> bool:
	if not cooldowns.has(slot): return true
	return cooldowns[slot].is_stopped()
	
func get_remaining(slot: String) -> float:
	if not cooldowns.has(slot): return 0.0
	return cooldowns[slot].time_left
