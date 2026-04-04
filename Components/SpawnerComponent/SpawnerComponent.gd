class_name SpawnerComponent
extends Marker2D

@export_group("Wave Settings")
@export var wave_data: WaveData
@export var wave_interval: float = 30.0

@export_group("Navigation")
@export var target_path: Path2D
@export var reverse_direction: bool = false

@onready var timer: Timer = $WaveTimer

func _ready():
	timer.wait_time = wave_interval
	timer.timeout.connect(_on_timer_timeout)
	timer.start()
	
func _on_timer_timeout():
	spawn_wave()

func spawn_wave():
	for i in range(wave_data.count):
		_create_unit()
		await get_tree().create_timer(wave_data.stagger_delay).timeout

func _create_unit():
	if not target_path:
		push_warning("SpawnerComponent: No path assigned!")
		return
	
	var follower = PathFollow2D.new()
	follower.loop = false
	
	target_path.add_child(follower)
	
	var unit = wave_data.minion_scene.instantiate() as Minion

	if reverse_direction:
		follower.progress_ratio = 1.0
		unit.rotation = PI
		unit.setup(TeamComponent.Team.B)
	else:
		follower.progress_ratio = 0.0
		unit.rotation = 0
		unit.setup(TeamComponent.Team.A)

	follower.add_child(unit)
	
	if unit.has_method("set_path_controller"):
		unit.set_path_controller(follower, reverse_direction)
