extends Camera2D

@export var hero: Node2D
@export var follow_speed: float = 15.0
@export var pan_speed: float = 1200.0
@export var drag_sensitivity: float = 1.0
@export var return_delay: float = 20.0
@export var edge_threshold: float = 30.0
@export var max_offset: float = 400.0
@export var return_speed: float = 2.0

var camera_offset: Vector2 = Vector2.ZERO
var is_free_mode: bool = false
var return_timer: float = 0.0

func _ready():
	if hero: global_position = hero.global_position

func _physics_process(delta):
	if not hero: return

	_handle_inputs(delta)
	
	if is_free_mode:
		return_timer -= delta
		if return_timer <= 0:
			_return_to_hero()
	else:
		_handle_edge_panning(delta)
		camera_offset = camera_offset.limit_length(max_offset)
		var target_pos = hero.global_position + camera_offset
		global_position = global_position.lerp(target_pos, follow_speed * delta)

func _handle_edge_panning(delta):
	var mouse_pos = get_viewport().get_mouse_position()
	var screen_size = get_viewport().get_visible_rect().size
	var move_vec = Vector2.ZERO
	
	if mouse_pos.x < edge_threshold: move_vec.x = -1
	elif mouse_pos.x > screen_size.x - edge_threshold: move_vec.x = 1
	if mouse_pos.y < edge_threshold: move_vec.y = -1
	elif mouse_pos.y > screen_size.y - edge_threshold: move_vec.y = 1
	
	camera_offset += move_vec.normalized() * pan_speed * delta
	
func _handle_inputs(_delta):
	if Input.is_action_pressed("middle_click"):
		is_free_mode = true
		return_timer = return_delay
	
	if Input.is_action_pressed("camera_snap"):
		_return_to_hero()

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_MIDDLE:
		if event.pressed:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			
	if event is InputEventMouseMotion and Input.is_action_pressed("middle_click"):
		global_position -= event.relative * drag_sensitivity * (1.0 / zoom.x)

func _return_to_hero():
	is_free_mode = false
	camera_offset = Vector2.ZERO
