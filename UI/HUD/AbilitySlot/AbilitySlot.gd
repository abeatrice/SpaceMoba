class_name AbilitySlot
extends Control

@onready var progress_bar = $TextureProgressBar
@onready var timer_label = $TimerLabel
@onready var key_label = $KeyLabel

var ability_slot: String = "q"
var hero_ref: CharacterBody2D = null

func setup(slot: String, hero: CharacterBody2D):
	ability_slot = slot
	hero_ref = hero
	key_label.text = slot

func _process(_delta):
	if not is_instance_valid(hero_ref): return
	
	var cooldown_comp = hero_ref.cooldowns as CooldownComponent
	var time_left = cooldown_comp.get_remaining(ability_slot)
	
	if time_left > 0:
		timer_label.text = "%0.1f" % time_left
		var total_time = cooldown_comp.cooldowns[ability_slot].wait_time
		progress_bar.value = (time_left / total_time) * 100
		timer_label.show()
	else:
		progress_bar.value = 0
		timer_label.hide()
