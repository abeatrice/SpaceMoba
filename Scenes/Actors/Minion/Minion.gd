class_name Minion
extends CharacterBody2D

@export var move_speed: float = 150.0
@export var projectile_scene: PackedScene
@export var projectile_damage: float = 50.0
@export var team_from_inspector: TeamComponent.Team = TeamComponent.Team.NONE:
	set(value):
		team_from_inspector = value
		if is_inside_tree() and team_component:
			team_component.team = value
			update_team_visuals()

@onready var health_component: HealthComponent = $HealthComponent
@onready var attack_timer = $AttackTimer
@onready var team_component: TeamComponent = $TeamComponent
@onready var health_bar: HealthBarComponent = $HealthBarComponent
@onready var targeting: TargetingComponent = $TargetingComponent

var detector: DetectorComponent
var muzzle_marker: Marker2D

var is_reversed: bool = false
var path_controller: PathFollow2D

func _ready():
	_ensure_references()
	
	if team_from_inspector != TeamComponent.Team.NONE:
		team_component.team = team_from_inspector
	
	update_team_visuals()
	
	health_component.died.connect(_on_died)
	health_component.health_changed.connect(_on_health_changed)
	
	health_bar.team = team_component.team
	health_bar.update_health(health_component.current_health, health_component.max_health)

func _ensure_references():
	if not detector: detector = get_node("EnemiesDetectorComponent")
	if not muzzle_marker: muzzle_marker = get_node("MuzzleMarker2D")

func update_team_visuals():
	_ensure_references()
	team_component.sync_team_data(self, detector)

func setup(new_team: TeamComponent.Team):
	team_component = get_node("TeamComponent")
	_ensure_references()

	team_component.team = new_team
	update_team_visuals()

func set_path_controller(controller: PathFollow2D, reversed: bool = false):
	path_controller = controller
	is_reversed = reversed

func get_avoidance_velocity() -> Vector2:
	var push_vector = Vector2.ZERO
	var neighbors = $AvoidanceArea.get_overlapping_bodies()
	
	for neighbor in neighbors:
		if neighbor == self: continue
		if neighbor is Minion and neighbor.team_component.team == team_component.team:
			var push_dir = neighbor.global_position.direction_to(global_position)
			push_vector += push_dir

	return push_vector.normalized() * (move_speed * 0.5)

func _fire_projectile():
	var p = projectile_scene.instantiate()
	get_tree().current_scene.add_child(p)
	p.init(muzzle_marker.global_position, targeting.current_target, projectile_damage)

func _on_died():
	if path_controller:
		path_controller.queue_free()
	else:
		queue_free()

func _on_health_changed(new_health: float):
	health_bar.update_health(new_health, health_component.max_health)
