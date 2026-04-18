class_name MatchManager
extends Node

@export var respawn_time: float = 1.0
@export var hero_spawner: HeroSpawnerComponent
@export var camera_component: CameraComponent

@onready var respawn_ui = $RespawnUI

var current_hero: Node2D = null

func _ready():
	if not hero_spawner:
		push_warning("no hero spawner assigned to match manager")

	respawn_ui.hide()

	var hero = get_tree().get_first_node_in_group("player")
	if hero:
		_connect_hero(hero)

func _connect_hero(hero):
	current_hero = hero
	if not hero.died.is_connected(_on_hero_died):
		hero.died.connect(_on_hero_died)

func _on_hero_died(_hero):
	respawn_ui.show()

	var timer_label = respawn_ui.get_node("%TimerLabel")
	var time_left = respawn_time
	while time_left > 0:
		timer_label.text = str(int(ceil(time_left)))

		await get_tree().create_timer(1.0).timeout
		time_left -= 1.0

	respawn_ui.hide()
	_perform_spawn()

func _perform_spawn():
	var hero = hero_spawner.spawn_hero(TeamComponent.Team.A)
	_connect_hero(hero)
	camera_component.hero = hero
