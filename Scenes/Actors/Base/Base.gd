class_name Base
extends StaticBody2D

@export var projectile_scene: PackedScene
@export var projectile_damage: float = 300
@export var team_from_inspector: TeamComponent.Team = TeamComponent.Team.NONE:
	set(value):
		team_from_inspector = value
		if is_inside_tree() and team_component:
			team_component.team = value
			update_team_visuals()

@onready var team_component: TeamComponent = $TeamComponent
@onready var health_component: HealthComponent = $HealthComponent
@onready var health_bar: HealthBarComponent = $HealthBarComponent
@onready var attack_timer: Timer = $AttackTimer
@onready var targeting: TargetingComponent = $TargetingComponent
@onready var muzzles = [$MuzzleMarkerCenter, $MuzzleMarkerLeft, $MuzzleMarkerRight]

var detector: DetectorComponent

func _draw():
	var draw_scale := 1.0
	var primary_color = team_component.get_colors()["primary"]
	var secondary_color = primary_color.darkened(0.5)

	draw_circle(Vector2.ZERO, 128 * draw_scale, secondary_color, true, -1.0, false)
	draw_circle(Vector2.ZERO, 128 * draw_scale, primary_color, false, 4 * draw_scale, true)
	draw_line(Vector2.ZERO, Vector2(130, 0) * draw_scale, primary_color, 4 * draw_scale, true)
	
func draw_smooth_circle(center: Vector2, radius: float, color: Color, thickness: float = -1.0):
	var points = PackedVector2Array()
	var segments = 64 # Increase for smoother circles
	for i in range(segments + 1):
		var angle = i * TAU / segments
		points.append(center + Vector2(cos(angle), sin(angle)) * radius)
	
	if thickness < 0:
		# Draw the solid fill
		draw_polygon(points, [color])
	else:
		# Draw the smooth anti-aliased outline
		draw_polyline(points, color, thickness, true)

func _ready():
	if team_from_inspector != TeamComponent.Team.NONE:
		team_component.team = team_from_inspector
	update_team_visuals()
	health_component.died.connect(_on_died)
	health_component.health_changed.connect(_on_health_changed)

	health_bar.team = team_component.team
	health_bar.update_health(health_component.current_health, health_component.max_health)

func _physics_process(_delta):
	if targeting.is_target_valid():
		rotation = lerp_angle(rotation, targeting.get_dir_to_target().angle(), 0.1)
		
		if targeting.is_aligned(0.9) and attack_timer.is_stopped():
			_fire_projectiles()
			attack_timer.start()

func _ensure_references():
	if not detector: detector = get_node("EnemiesDetectorComponent")

func update_team_visuals():
	_ensure_references()
	team_component.sync_team_data(self, detector)

func _fire_projectiles():
	for m in muzzles:
		var p = projectile_scene.instantiate()
		get_tree().current_scene.add_child(p)
		p.init(m.global_position, targeting.current_target, projectile_damage)

func _on_died():
	queue_free()

func _on_health_changed(new_health: float):
	health_bar.update_health(new_health, health_component.max_health)
