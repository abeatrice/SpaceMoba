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

func _draw():
	var draw_scale := 1
	var primary_color = team_component.get_colors()["primary"]
	var secondary_color = primary_color.darkened(0.5)

	var points = PackedVector2Array([
		Vector2(0, -16) * draw_scale,
		Vector2(16, 0) * draw_scale,
		Vector2(0, 16) * draw_scale,
		Vector2(-16, 0) * draw_scale,
		Vector2(0, -16) * draw_scale,
	])

	draw_polygon(points, [secondary_color])
	draw_polyline(points, primary_color, .5 * draw_scale, true)
	draw_line(Vector2.ZERO, Vector2(16, 0) * draw_scale, primary_color, 2 * draw_scale, true)

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

func _physics_process(delta):
	if targeting.is_target_valid():
		_attack_state(delta)
	else:
		_move_state(delta)

func _attack_state(_delta):
	if not targeting.is_target_valid(): return
	var dir = targeting.get_dir_to_target()
	rotation = lerp_angle(rotation, dir.angle(), 0.1)
	
	velocity = get_avoidance_velocity()
	move_and_slide()
	
	if attack_timer.is_stopped():
		_fire_projectile()
		attack_timer.start()

func _move_state(delta):
	if path_controller:
		var old_pos = global_position
		var move_amount = move_speed * delta
		if is_reversed:
			path_controller.progress -= move_amount
			if path_controller.progress_ratio <= 0.0:
				path_controller.queue_free()
		else:
			path_controller.progress += move_amount
			if path_controller.progress_ratio >= 1.0:
				path_controller.queue_free()

		var distance_moved = old_pos.distance_to(global_position)
		if distance_moved > 0.1:
			var move_dir = old_pos.direction_to(global_position)
			rotation = lerp_angle(rotation, move_dir.angle(), 0.1)

		velocity = get_avoidance_velocity()
		move_and_slide()

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
