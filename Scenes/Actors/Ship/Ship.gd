class_name Ship
extends CharacterBody2D

signal died(ship_ref)

const click_marker_scene: PackedScene = preload("uid://dk1maojo402u8")
const plasma_bolt_scene: PackedScene = preload("uid://b3vdi8tcjc6ip")

@export var speed: float = 400.0
@export	var attack_range: float = 256.0
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
@onready var health: HealthComponent = $HealthComponent
@onready var targeting: TargetingComponent = $TargetingComponent
@onready var attack_timer: Timer = $AttackTimer
@onready var muzzle_marker = $MuzzleMarker
@onready var state: StatemachineComponent = $StateMachineComponent
@onready var movement: MovementComponent = $MovementComponent
@onready var cooldowns: CooldownComponent = $CooldownComponent

var wingman_target_position: Vector2
var marker: ClickMarker = null
var is_busy: bool = false

func _ready():
	if team != TeamComponent.Team.NONE:
		team_component.team = team
	update_team_visuals()
	wingman_target_position = global_position + (Vector2.LEFT * 200 + Vector2.DOWN * 100)
	
	cooldowns.setup_ability("q", 4.0)
	
	health.died.connect(_on_died)
	health.health_changed.connect(_on_health_changed)
	
	health_bar.team = team_component.team
	health_bar.update_health(health.current_health, health.max_health)

func _physics_process(delta):
	var offset = (Vector2.LEFT * 200 + Vector2.DOWN * 100).rotated(global_rotation)
	var new_wingman_target_position = global_position + offset

	wingman_target_position = wingman_target_position.move_toward(
		new_wingman_target_position,
		speed * delta
	)

func get_wingman_target_position() -> Vector2:
	return wingman_target_position

func update_team_visuals():
	team_component.sync_team_data(self)

func use_ability(slot: String, target_pos: Vector2, target_node: Node2D):
	match slot:
		"q":
			var ability_data = {
				"ability_type": "skillshot",
				"slot": "q",
				"target_pos": target_pos,
				"cast_time": 1.0
			}
			state.transition("caststate", ability_data)
		"w":
			print(slot, target_pos, target_node)
		"e":
			print(slot, target_pos, target_node)
		"r":
			print(slot, target_pos, target_node)
		"q":
			print(slot, target_pos, target_node)

func spawn_click_marker(pos: Vector2, is_attack: bool):
	if is_instance_valid(marker):
		marker.queue_free()

	marker = click_marker_scene.instantiate()
	get_tree().current_scene.add_child(marker)
	marker.global_position = pos
	marker.setup(is_attack)

func command_attack(target_node: Node2D):
	targeting.current_target = target_node
	if not in_attack_range():
		movement.move_to(target_node.global_position)
		state.transition("movestate", {"next_state": "attackstate"})
	else:
		state.transition("attackstate")

func in_attack_range() -> bool:
	if not targeting.is_target_valid(): return false
	var calculated_dist = targeting.get_dist_to_target_edge()
	print("Dist: ", calculated_dist, " | Range: ", attack_range)
	return calculated_dist <= attack_range

func _fire_projectile():
	var p = projectile_scene.instantiate()
	get_tree().current_scene.add_child(p)
	p.init(muzzle_marker.global_position, targeting.current_target, projectile_damage)

func _fire_plasma_bolt(target_pos: Vector2):
	var bolt = plasma_bolt_scene.instantiate() as PlasmaBolt
	var spawn_pos = muzzle_marker.global_position
	var dir = (target_pos - spawn_pos).normalized()
	get_tree().current_scene.add_child(bolt)
	bolt.init(self, spawn_pos, dir)

func _on_died():
	died.emit(self)
	queue_free()

func _on_health_changed(new_health: float):
	health_bar.update_health(new_health, health.max_health)
