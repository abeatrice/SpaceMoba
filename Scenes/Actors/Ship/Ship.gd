class_name Ship
extends CharacterBody2D

@export var speed: float = 400.0
@export var turn_speed: float = PI * 3
@export var stopping_distance: float = 5.0
@export var rotation_stopping_distance: float = 10.0

var target_position: Vector2 = Vector2.ZERO
var has_target := false
var wingman_position: Vector2

func _draw():
	draw_polygon([
		Vector2(80, 0),
		Vector2(0, 20),
		Vector2(0, -20)
	], [Color.SKY_BLUE])
	
	#draw_circle(to_local(wingman_position), 5, Color.RED)

func _ready():
	wingman_position = global_position + (Vector2.LEFT * 200 + Vector2.DOWN * 100)

func get_wingman_target_position() -> Vector2:
	return wingman_position
	
func _physics_process(delta):
	queue_redraw()
	if Input.is_action_pressed("click_to_move"):
		target_position = get_global_mouse_position()
		has_target = true

	var target_velocity = Vector2.ZERO
	if has_target:
		var distance = global_position.distance_to(target_position)
		var direction = global_position.direction_to(target_position)
		var target_angle = direction.angle()
		
		if distance > stopping_distance:
			target_velocity = direction * speed
			velocity = velocity.lerp(target_velocity, 10.0 * delta)
		else:
			has_target = false
			velocity = Vector2.ZERO
		
		if distance > rotation_stopping_distance:
			rotation = rotate_toward(rotation, target_angle, turn_speed * delta)

	var offset = (Vector2.LEFT * 200 + Vector2.DOWN * 100).rotated(global_rotation)
	var wingman_target_position = global_position + offset

	wingman_position = wingman_position.move_toward(
		wingman_target_position,
		speed * delta
	)

	move_and_slide()
