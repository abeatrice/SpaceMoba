class_name ClickMarker
extends Node2D

var max_radius: float = 30.0
var min_radius: float = 10.0
var radius: float = max_radius
var color: Color = Color.CYAN
var tween: Tween = null

func setup(is_attack: bool):
	color = Color.RED if is_attack else Color.GREEN

	tween = create_tween()
	for i in 3:
		_play_animation()

	tween.finished.connect(queue_free)

func _play_animation():
	tween.tween_property(self, "radius", max_radius, 0.0)
	tween.tween_property(self, "radius", min_radius, 0.4)\
		.set_trans(Tween.TRANS_EXPO)\
		.set_ease(Tween.EASE_OUT)

func _draw():
	draw_arc(Vector2.ZERO, radius, 0, TAU, 32, color, 3.0, true)
	draw_circle(Vector2.ZERO, 2.0, color)

func _physics_process(_delta):
	queue_redraw()
