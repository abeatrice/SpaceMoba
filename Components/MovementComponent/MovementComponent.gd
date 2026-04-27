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
	
	#var distance = ship.global_position.distance_to(ship.target_position)
	#var direction = ship.global_position.direction_to(ship.target_position)
	#
	#if distance > ship.stopping_distance:
		#var target_velocity = direction * ship.speed
		#ship.velocity = ship.velocity.lerp(target_velocity, 10.0 * delta)
	#else:
		#ship.velocity = Vector2.ZERO
		#transitioned.emit("idlestate")
	#
	#if distance > ship.rotation_stopping_distance:
		#ship.rotation = rotate_toward(ship.rotation, direction.angle(), ship.turn_speed * delta)
#
	#ship.move_and_slide()
#
