class_name HoverOutlineComponent
extends Node2D

@export var outline_width: float = 6.0
@export var hover_color: Color = Color(1, 1, 1, 0.6)
@export var target_color: Color = Color(1, 0.2, 0.2, 0.8)
@export var hover_area: Area2D

var is_hovered: bool = false
var is_targeted: bool = false
var collision_shape: Shape2D

func _draw():
	if not (is_hovered or is_targeted): return
	
	var color: Color = target_color if is_targeted else hover_color
	
	if collision_shape is CircleShape2D:
		draw_arc(Vector2.ZERO, collision_shape.radius, 0, TAU, 32, color, outline_width, true)
	elif collision_shape is RectangleShape2D:
		var rect = Rect2(-collision_shape.size / 2, collision_shape.size)
		draw_rect(rect, color, false, outline_width)
	elif collision_shape is ConvexPolygonShape2D or collision_shape is ConcavePolygonShape2D:
		var points = Array(collision_shape.points)
		if points.size() > 2:
			points.append(points[0])
			var draw_points = PackedVector2Array(points)
			#draw_polyline(draw_points, color * 0.5, outline_width * 0.2, true) # soft outer line
			draw_polyline(draw_points, color, outline_width, true)

func _ready():
	if !hover_area:
		push_warning("HoverOutlineComponent doesnt have a hover area")
		return
	
	var shape_node = hover_area.find_child("CollisionShape2D")
	if !shape_node:
		push_warning("HoverOutlineComponent's hover area doesnt have a CollisionShape2D")
		return

	collision_shape = shape_node.shape

	hover_area.mouse_entered.connect(_on_mouse_entered)
	hover_area.mouse_exited.connect(_on_mouse_exited)
	
func _on_mouse_entered():
	is_hovered = true
	queue_redraw()
	
func _on_mouse_exited():
	is_hovered = false
	queue_redraw()
	
