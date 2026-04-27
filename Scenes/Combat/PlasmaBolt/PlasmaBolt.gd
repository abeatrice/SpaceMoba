class_name PlasmaBolt
extends Node2D

@export var speed: float = 800.0
@export var damage: float = 400.0
@export var lifetime: float = 2.0

@onready var hitbox_component: HitboxComponent = $HitboxComponent

var direction: Vector2 = Vector2.ZERO

func _draw():
	draw_circle(Vector2.ZERO, 10, Color(1, 1, 1, 1))

func _ready():
	hitbox_component.damage = damage
	hitbox_component.hit_confirmed.connect(queue_free)
	get_tree().create_timer(lifetime).timeout.connect(queue_free)

func _physics_process(delta):
	global_position += direction * speed * delta

func init(actor: Node2D, _global_position: Vector2, _direction: Vector2):
	direction = _direction
	rotation = direction.angle()
	global_position = _global_position
	hitbox_component.damage = damage
	if actor.has_node("TeamComponent"):
		var actors_team = actor.get_node("TeamComponent") as TeamComponent
		hitbox_component.target_group = actors_team.get_enemy_group()
		hitbox_component.collision_mask = actors_team.get_enemy_hurtbox_layer()
