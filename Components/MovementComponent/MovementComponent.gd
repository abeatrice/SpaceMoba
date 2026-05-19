class_name MovementComponent
extends Node

@export var speed: float = 400.0
@export var acceleration: float = 10.0
@export var rotation_speed: float = 8.0
@export var stopping_distance: float = 10.0

var target_position: Vector2
var is_moving: bool = false
var parent: CharacterBody2D

signal destination_reached

func _ready():
	parent = get_parent() as CharacterBody2D
	target_position = parent.global_position

func move_to(pos: Vector2):
	target_position = pos
	is_moving = true

func stop():
	is_moving = false
	if parent:
		target_position = parent.global_position
		parent.velocity = Vector2.ZERO

func _physics_process(delta):
	if not is_moving or not parent: return

	var direction = (target_position - parent.global_position)	
	
	if direction.length() < stopping_distance:
		stop()
		destination_reached.emit()
		return
	
	var target_angle = direction.angle()
	parent.rotation = lerp_angle(parent.rotation, target_angle, rotation_speed * delta)
	
	var desired_velocity = direction.normalized() * speed
	parent.velocity = parent.velocity.lerp(desired_velocity, acceleration * delta)
	
	parent.move_and_slide()
