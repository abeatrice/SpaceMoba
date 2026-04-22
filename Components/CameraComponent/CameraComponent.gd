class_name CameraComponent
extends Camera2D

@export var hero: Node2D
@export var follow_speed: float = 15.0
@export var pan_speed: float = 1200.0
@export var drag_sensitivity: float = 1.0
@export var edge_threshold: float = 5.0
@export var max_offset: float = 400.0

@onready var state_machine = $StateMachineComponent

var camera_offset: Vector2 = Vector2.ZERO

func _ready():
	if hero: 
		global_position = hero.global_position

func _get_edge_panning_vector() -> Vector2:
	var mouse_pos = get_viewport().get_mouse_position()
	var screen_size = get_viewport().get_visible_rect().size
	var move_vec = Vector2.ZERO
	
	if mouse_pos.x < edge_threshold: move_vec.x = -1
	elif mouse_pos.x > screen_size.x - edge_threshold: move_vec.x = 1
	if mouse_pos.y < edge_threshold: move_vec.y = -1
	elif mouse_pos.y > screen_size.y - edge_threshold: move_vec.y = 1
	
	return move_vec.normalized()

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_MIDDLE:
		if event.pressed:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	if event is InputEventMouseMotion and Input.is_action_pressed("middle_click"):
		state_machine.transition("unlockedstate")
		var position_change = event.relative * drag_sensitivity * (1.0 / zoom.x)
		global_position += position_change
