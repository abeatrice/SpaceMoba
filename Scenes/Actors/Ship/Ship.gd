class_name Ship
extends CharacterBody2D

signal died(ship_ref)

const click_marker_scene: PackedScene = preload("uid://dk1maojo402u8")

@export var speed: float = 400.0
@export var turn_speed: float = PI * 3
@export var stopping_distance: float = 5.0
@export var rotation_stopping_distance: float = 10.0
@export	var attack_range: float = 128.0
@export var projectile_scene: PackedScene
@export var projectile_damage: float = 50.0
@export var team: TeamComponent.Team = TeamComponent.Team.NONE:
	set(value):
		team = value
		if is_inside_tree() and team_component:
			team_component.team = value
			update_team_visuals()

@onready var team_component: TeamComponent = $TeamComponent
@onready var health_bar: HealthBarComponent = $HealthBarComponent
@onready var health_component: HealthComponent = $HealthComponent
@onready var targeting: TargetingComponent = $TargetingComponent
@onready var attack_timer: Timer = $AttackTimer
@onready var muzzle_marker = $MuzzleMarker
@onready var state_machine = $StateMachineComponent

var target_position: Vector2 = Vector2.ZERO
var has_target_position := false
var wingman_target_position: Vector2
var marker: ClickMarker = null

func _ready():
	if team != TeamComponent.Team.NONE:
		team_component.team = team
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
		var target = _get_target_or_null()
		
		if target:
			targeting.current_target = target
			state_machine._on_child_transition("attackstate")
		else:
			state_machine._on_child_transition("movestate")
			targeting.current_target = null

		if Input.is_action_just_pressed("move_attack"):
			_spawn_click_marker(target_position, targeting.is_target_valid())

func _spawn_click_marker(pos: Vector2, is_attack: bool):
	if is_instance_valid(marker):
		marker.queue_free()

	marker = click_marker_scene.instantiate()
	get_tree().current_scene.add_child(marker)
	marker.global_position = pos
	marker.setup(is_attack)

func _physics_process(delta):
	_handle_input()
			
	var offset = (Vector2.LEFT * 200 + Vector2.DOWN * 100).rotated(global_rotation)
	var new_wingman_target_position = global_position + offset

	wingman_target_position = wingman_target_position.move_toward(
		new_wingman_target_position,
		speed * delta
	)

func _get_target_or_null():
	var circle = CircleShape2D.new()
	circle.radius = 64.0

	var query = PhysicsShapeQueryParameters2D.new()
	query.shape = circle
	query.transform = Transform2D(0, target_position)
	query.collision_mask = TeamComponent.LAYER_TEAM_B_HURTBOX
	query.collide_with_areas = true
	
	var space_state = get_world_2d().direct_space_state
	var results = space_state.intersect_shape(query)

	if results.size() > 0:
		return _get_best_target(results, target_position)

	return null

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

func _fire_projectile():
	var p = projectile_scene.instantiate()
	get_tree().current_scene.add_child(p)
	p.init(muzzle_marker.global_position, targeting.current_target, projectile_damage)

func _on_died():
	died.emit(self)
	queue_free()

func _on_health_changed(new_health: float):
	health_bar.update_health(new_health, health_component.max_health)
