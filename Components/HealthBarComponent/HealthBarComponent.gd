class_name HealthBarComponent
extends Node2D

@export var size: Vector2 = Vector2(40, 4)
@export var offset: Vector2 = Vector2(0, -40)

var current_health: float = 100
var max_health: float = 100
var team: TeamComponent.Team = TeamComponent.Team.NONE

func _draw():
	var start_pos = Vector2(-size.x / 2, 0)
	
	# Background
	draw_rect(Rect2(start_pos, size), Color.BLACK)
	
	# Foreground
	var health_ratio = current_health / max_health
	var bar_color = Color.SKY_BLUE if team == TeamComponent.Team.A else Color.INDIAN_RED
	
	draw_rect(Rect2(start_pos, Vector2(size.x * health_ratio, size.y)), bar_color)

func _process(_delta):
	global_rotation = 0
	global_position = get_parent().global_position + offset

func update_health(current: float, total: float):
	current_health = current
	max_health = total
	queue_redraw()
