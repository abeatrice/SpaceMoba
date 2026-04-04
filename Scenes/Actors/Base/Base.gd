@tool
class_name Base
extends StaticBody2D

@export var projectile_scene: PackedScene
@export var team_from_inspector: TeamComponent.Team = TeamComponent.Team.NONE:
	set(value):
		team_from_inspector = value
		if is_inside_tree() and team_component:
			team_component.team = value
			update_team_visuals()

@onready var team_component: TeamComponent = $TeamComponent
@onready var health_component: HealthComponent = $HealthComponent
@onready var health_bar: HealthBarComponent = $HealthBarComponent
@onready var attack_timer = $AttackTimer
@onready var muzzle_marker_center = $MuzzleMarkerCenter
@onready var muzzle_marker_left = $MuzzleMarkerLeft
@onready var muzzle_marker_right = $MuzzleMarkerRight

var detector: DetectorComponent
var current_target: Node2D = null

func _draw():
	var draw_scale := 5.0
	var primary_color = team_component.get_colors()["primary"]
	var secondary_color = primary_color.darkened(0.5)

	draw_line(Vector2.ZERO, Vector2(60, 0) * draw_scale, primary_color, 2 * draw_scale)

	draw_circle(Vector2.ZERO, 50 * draw_scale, primary_color)
	draw_circle(Vector2.ZERO, 48 * draw_scale, secondary_color)

func _ready():
	if team_from_inspector != TeamComponent.Team.NONE:
		team_component.team = team_from_inspector
	update_team_visuals()
	health_component.died.connect(_on_died)
	health_component.health_changed.connect(_on_health_changed)
	detector.target_found.connect(_on_target_found)
	detector.target_lost.connect(_on_target_lost)
	
	health_bar.team = team_component.team
	health_bar.update_health(health_component.current_health, health_component.max_health)

func _physics_process(delta):
	if current_target and is_instance_valid(current_target):
		_attack_state(delta)
	else:
		_idle_state(delta)

func _ensure_references():
	if not detector: detector = get_node("EnemiesDetectorComponent")

func update_team_visuals():
	_ensure_references()
	
	remove_from_group("team_a")
	remove_from_group("team_b")
	if team_component.team == TeamComponent.Team.A:
		add_to_group("team_a")
	elif team_component.team == TeamComponent.Team.B:
		add_to_group("team_b")
	
	detector.target_group = team_component.get_enemy_group()

	queue_redraw()

func _attack_state(_delta):
	if not is_instance_valid(current_target): return

	var dir = global_position.direction_to(current_target.global_position)
	rotation = lerp_angle(rotation, dir.angle(), 0.1)
	
	if attack_timer.is_stopped():
		_fire_projectile()
		attack_timer.start()

func _idle_state(_delta):
	pass

func _can_fire_at_target() -> bool:
	if not is_instance_valid(current_target): return false
	
	var forward := Vector2.RIGHT.rotated(rotation)
	var dir_to_target := global_position.direction_to(current_target.global_position)
	var dot := forward.dot(dir_to_target)
	return dot > 0.9

func _fire_projectile():
	if not _can_fire_at_target(): return

	var muzzles = [
		muzzle_marker_center,
		muzzle_marker_left,
		muzzle_marker_right
	]
	for i in 3:
		var p = projectile_scene.instantiate()
		get_tree().current_scene.add_child(p)
		
		p.global_position = muzzles[i].global_position
		p.target = current_target
		p.damage = 10.0
		
		var hb = p.get_node("HitboxComponent")
		hb.target_group = team_component.get_enemy_group()

func _on_died():
	queue_free()

func _on_health_changed(new_health: float):
	health_bar.update_health(new_health, health_component.max_health)

func _on_target_found(target: Node2D):
	if is_instance_valid(target):
		current_target = target

func _on_target_lost(_target: Node2D):
	current_target = null
