class_name Projectile
extends Node2D

@export var speed: float = 1000.0
@export var damage: float = 10.0

@onready var hitbox_component: HitboxComponent = $HitboxComponent

var target: Node2D = null
var is_dying: bool = false
var alpha: float = 1.0:
	set(value):
		alpha = value
		queue_redraw()

func init(initial_position: Vector2, initial_target: Node2D):
	global_position = initial_position
	target = initial_target
	if target.has_node("TeamComponent"):
		var targets_team = target.get_node("TeamComponent") as TeamComponent
		hitbox_component.target_group = targets_team.get_team_group()
		hitbox_component.collision_mask = targets_team.get_team_hurtbox_layer()

func _draw():
	draw_circle(Vector2.ZERO, 3, Color(1, 1, 1, alpha))

func _ready():
	hitbox_component.hit_confirmed.connect(_on_hit_confirmed)

func _physics_process(delta):
	if is_instance_valid(target):
		var direction = global_position.direction_to(target.global_position)
		global_position += direction * speed * delta
		rotation = direction.angle()
	else:
		if not is_dying:
			_start_fizzle_timer()
		global_position += Vector2.RIGHT.rotated(rotation) * speed * delta

func _start_fizzle_timer():
	is_dying = true
	var tween = create_tween()
	tween.tween_property(self, "alpha", 0.0, 1.0)
	tween.finished.connect(queue_free)

func _on_hit_confirmed():
	queue_free()
