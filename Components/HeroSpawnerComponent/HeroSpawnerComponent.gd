class_name HeroSpawnerComponent
extends Marker2D

@export var hero_scene: PackedScene
@export var player_controller: PlayerController
@export var camera: CameraComponent

func spawn_hero(team: TeamComponent.Team):
	if not hero_scene: 
		push_warning("Hero Spawner Component: no hero scene assigned")

	var new_hero = hero_scene.instantiate()
	new_hero.team = team

	get_parent().add_child(new_hero)
	new_hero.global_position = global_position

	player_controller.hero = new_hero
	
	if camera:
		camera.state.transition("lockedstate")

	return new_hero
