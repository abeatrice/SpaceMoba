class_name Ship
extends CharacterBody2D

@export var speed: float = 400.0
@export var turn_speed: float = PI * 3
@export var stopping_distance: float = 5.0
@export var rotation_stopping_distance: float = 10.0
@export var team_from_inspector: TeamComponent.Team = TeamComponent.Team.NONE:
	set(value):
		team_from_inspector = value
		if is_inside_tree() and team_component:
			team_component.team = value
			update_team_visuals()

@onready var team_component: TeamComponent = $TeamComponent
@onready var health_bar: HealthBarComponent = $HealthBarComponent
@onready var health_component = $HealthComponent

var target_position: Vector2 = Vector2.ZERO
var has_target := false
var wingman_position: Vector2

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
	#draw_circle(to_local(wingman_position), 5, Color.RED)

func _ready():
	if team_from_inspector != TeamComponent.Team.NONE:
		team_component.team = team_from_inspector
	update_team_visuals()
	wingman_position = global_position + (Vector2.LEFT * 200 + Vector2.DOWN * 100)
	
	health_component.died.connect(_on_died)
	health_component.health_changed.connect(_on_health_changed)
	
	health_bar.team = team_component.team
	health_bar.update_health(health_component.current_health, health_component.max_health)

func get_wingman_target_position() -> Vector2:
	return wingman_position

func update_team_visuals():
	team_component.sync_team_data(self)

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

func _on_died():
	queue_free()

func _on_health_changed(new_health: float):
	health_bar.update_health(new_health, health_component.max_health)
