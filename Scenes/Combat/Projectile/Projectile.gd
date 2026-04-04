class_name Projectile
extends Node2D

@export var speed: float = 400.0
@export var damage: float = 10.0

@onready var hitbox_component: HitboxComponent = $HitboxComponent

var target: Node2D = null

func _draw():
	draw_circle(Vector2.ZERO, 5, Color.WHITE)

func _ready():
	hitbox_component.area_entered.connect(_on_hitbox_component_area_entered)

func _physics_process(delta):
	if is_instance_valid(target):
		var direction = global_position.direction_to(target.global_position)
		global_position += direction * speed * delta
		rotation = direction.angle()
	else:
		queue_free()

func _on_hitbox_component_area_entered(area: Node2D):
	if area is HurtboxComponent:
		var target_group = hitbox_component.target_group
		if target_group == "" or area.get_parent().is_in_group(target_group):
			queue_free()
