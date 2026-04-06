class_name Wingman
extends CharacterBody2D

@export var speed = 400.0
@export var stopping_distance: float = 5.0
@export var rotation_stopping_distance: float = 10.0
@export var turn_speed = PI * 3
@export var leader: Ship
@export var team_from_inspector: TeamComponent.Team = TeamComponent.Team.NONE:
	set(value):
		team_from_inspector = value
		if is_inside_tree() and team_component:
			team_component.team = value
			update_team_visuals()

@onready var team_component: TeamComponent = $TeamComponent

var detector: DetectorComponent

func _draw():
	var draw_scale := 1.0
	var primary_color = team_component.get_colors()["primary"]
	var secondary_color = primary_color.darkened(0.5)

	var points = PackedVector2Array([
		Vector2(80, 0) * draw_scale,
		Vector2(0, 25) * draw_scale,
		Vector2(0, -25) * draw_scale,
		Vector2(80, 0) * draw_scale,
	])

	draw_polygon(points, [secondary_color])
	draw_polyline(points, primary_color, 2 * draw_scale, true)

func update_team_visuals():
	_ensure_references()
	team_component.sync_team_data(self, detector)

func _ensure_references():
	if not detector: detector = get_node("EnemiesDetectorComponent")

func _ready():
	if team_from_inspector != TeamComponent.Team.NONE:
		team_component.team = team_from_inspector
	update_team_visuals()
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
