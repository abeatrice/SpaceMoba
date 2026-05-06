extends CanvasLayer

@onready var slot_q: AbilitySlot = %SlotQ
@onready var slot_w: AbilitySlot = %SlotW
@onready var slot_e: AbilitySlot = %SlotE
@onready var slot_r: AbilitySlot = %SlotR

func _ready():
	var controller = get_tree().current_scene.find_child("PlayerController")
	if controller and controller.hero:
		slot_q.setup("q", controller.hero)
		slot_w.setup("w", controller.hero)
		slot_e.setup("e", controller.hero)
		slot_r.setup("r", controller.hero)
