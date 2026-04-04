extends CharacterBody2D

@export var speed = 400.0
@export var stopping_distance: float = 5.0
@export var rotation_stopping_distance: float = 10.0
@export var turn_speed = PI * 3

@export var leader: Ship

func _draw():
	draw_polygon([
		Vector2(80, 0),
		Vector2(0, 20),
		Vector2(0, -20)
	], [Color.CRIMSON])

func _ready():
	global_position = leader.get_wingman_target_position()
	rotation = leader.get_rotation()

func _physics_process(delta):
	var target_position = leader.get_wingman_target_position()
	var distance = global_position.distance_to(target_position)
	var direction = global_position.direction_to(target_position)
	var target_angle = direction.angle()
	
	if distance > stopping_distance:
		velocity = velocity.lerp(direction * speed, 10.0 * delta)
	else:
		target_position = null
		velocity = Vector2.ZERO
		
	if distance <= rotation_stopping_distance:
		target_angle = leader.get_rotation()

	rotation = rotate_toward(rotation, target_angle, turn_speed * delta)

	move_and_slide()
