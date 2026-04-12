class_name Ship
extends CharacterBody2D

enum Action { IDLE, MOVING, ATTACKING }

const click_marker_scene: PackedScene = preload("uid://dk1maojo402u8")

@export var speed: float = 400.0
@export var turn_speed: float = PI * 3
@export var stopping_distance: float = 5.0
@export var rotation_stopping_distance: float = 10.0
@export	var attack_range: float = 128.0
@export var projectile_scene: PackedScene
@export var team_from_inspector: TeamComponent.Team = TeamComponent.Team.NONE:
	set(value):
		team_from_inspector = value
		if is_inside_tree() and team_component:
			team_component.team = value
			update_team_visuals()

@onready var team_component: TeamComponent = $TeamComponent
@onready var health_bar: HealthBarComponent = $HealthBarComponent
@onready var health_component: HealthComponent = $HealthComponent
@onready var targeting: TargetingComponent = $TargetingComponent
@onready var attack_timer: Timer = $AttackTimer
@onready var muzzle_marker = $MuzzleMarker

var target_position: Vector2 = Vector2.ZERO
var has_target_position := false
var wingman_target_position: Vector2
var current_action = Action.IDLE
var marker: ClickMarker = null

func _draw():
	var draw_scale := 1.0
	var primary_color = team_component.get_colors()["primary"]
	var secondary_color = primary_color.darkened(0.5)
	
	var points = PackedVector2Array([
		Vector2(32, 0) * draw_scale,
		Vector2(-32, 20) * draw_scale,
		Vector2(-32, -20) * draw_scale,
		Vector2(32, 0) * draw_scale,
	])

	draw_polygon(points, [secondary_color])
	draw_polyline(points, primary_color, 2 * draw_scale, true)
	#draw_circle(to_local(wingman_target_position), 5, Color.RED)

func _ready():
	if team_from_inspector != TeamComponent.Team.NONE:
		team_component.team = team_from_inspector
	update_team_visuals()
	wingman_target_position = global_position + (Vector2.LEFT * 200 + Vector2.DOWN * 100)
	
	health_component.died.connect(_on_died)
	health_component.health_changed.connect(_on_health_changed)
	
	health_bar.team = team_component.team
	health_bar.update_health(health_component.current_health, health_component.max_health)

func get_wingman_target_position() -> Vector2:
	return wingman_target_position

func update_team_visuals():
	team_component.sync_team_data(self)

func _handle_input():
	if Input.is_action_pressed("move_attack"):
		target_position = get_global_mouse_position()
		
		var circle = CircleShape2D.new()
		circle.radius = 64.0

		var query = PhysicsShapeQueryParameters2D.new()
		query.shape = circle
		query.transform = Transform2D(0, target_position)
		query.collision_mask = TeamComponent.LAYER_TEAM_B_HURTBOX
		query.collide_with_areas = true
		
		var space_state = get_world_2d().direct_space_state
		var results = space_state.intersect_shape(query)

		var is_attack: bool = false
		var outline: HoverOutlineComponent
		if results.size() > 0:
			var new_target = _get_best_target(results, target_position)
			if targeting.current_target and targeting.current_target != new_target:
				outline = targeting.current_target.find_child("HoverOutlineComponent") as HoverOutlineComponent
				if outline:
					outline.is_targeted = false
					outline.queue_redraw()

			targeting.current_target = new_target
			outline = targeting.current_target.find_child("HoverOutlineComponent") as HoverOutlineComponent
			if outline:
				outline.is_targeted = true
				outline.queue_redraw()

			current_action = Action.ATTACKING
			is_attack = true
		else:
			targeting.current_target = null
			current_action = Action.MOVING
			is_attack = false

		if Input.is_action_just_pressed("move_attack"):
			_spawn_click_marker(target_position, is_attack)

func _spawn_click_marker(pos: Vector2, is_attack: bool):
	if is_instance_valid(marker):
		marker.queue_free()

	marker = click_marker_scene.instantiate()
	get_tree().current_scene.add_child(marker)
	marker.global_position = pos
	marker.setup(is_attack)

func _physics_process(delta):
	_handle_input()
	match current_action:
		Action.ATTACKING:
			_handle_attack_logic(delta)
		Action.MOVING:
			_handle_movement_logic(delta)
			
	var offset = (Vector2.LEFT * 200 + Vector2.DOWN * 100).rotated(global_rotation)
	var new_wingman_target_position = global_position + offset

	wingman_target_position = wingman_target_position.move_toward(
		new_wingman_target_position,
		speed * delta
	)

func _get_best_target(results: Array, click_pos: Vector2) -> Node2D:
	var closest_target = null
	var min_dist = INF
	
	for res in results:
		var target = res.collider.get_parent()
		var dist = click_pos.distance_to(target.global_position)
		if dist < min_dist:
			min_dist = dist
			closest_target = target
	
	return closest_target

func _handle_attack_logic(delta):
	if not targeting.is_target_valid():
		current_action = Action.IDLE
		return

	var distance = targeting.get_dist_to_target_edge()

	var direction = targeting.get_dir_to_target()
	if distance > attack_range:
		var target_velocity = direction * speed
		velocity = velocity.lerp(target_velocity, 10.0 * delta)
		if distance > rotation_stopping_distance:
			rotation = rotate_toward(rotation, direction.angle(), turn_speed * delta)
		move_and_slide()
	else:
		velocity = Vector2.ZERO
		rotation = rotate_toward(rotation, direction.angle(), turn_speed * delta)
		if targeting.is_aligned(0.9) and attack_timer.is_stopped():
			_fire_projectile()
			attack_timer.start()

func _handle_movement_logic(delta):
	var distance = global_position.distance_to(target_position)
	var direction = global_position.direction_to(target_position)
	
	if distance > stopping_distance:
		var target_velocity = direction * speed
		velocity = velocity.lerp(target_velocity, 10.0 * delta)
	else:
		velocity = Vector2.ZERO
		current_action = Action.IDLE
	
	if distance > rotation_stopping_distance:
		rotation = rotate_toward(rotation, direction.angle(), turn_speed * delta)

	move_and_slide()

func _fire_projectile():
	var p = projectile_scene.instantiate()
	get_tree().current_scene.add_child(p)
	p.init(muzzle_marker.global_position, targeting.current_target)

func _on_died():
	queue_free()

func _on_health_changed(new_health: float):
	health_bar.update_health(new_health, health_component.max_health)
