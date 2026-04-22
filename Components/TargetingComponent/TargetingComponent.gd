class_name TargetingComponent
extends Node2D

@onready var detector: DetectorComponent = get_parent().get_node_or_null("EnemiesDetectorComponent")

var current_target: Node2D = null

func _ready():
	if detector:
		detector.target_found.connect(_on_target_found)
		detector.target_lost.connect(_on_target_lost)
	
func is_target_valid() -> bool:
	return is_instance_valid(current_target)

func get_dist_to_target_edge() -> float:
	if not is_target_valid(): return 0.0
	
	var hurtbox = current_target.get_node_or_null("HurtboxComponent")
	if not hurtbox: return global_position.distance_to(current_target.global_position)
	
	var shape = hurtbox.shape_owner_get_shape(0,0)
	var trans = hurtbox.global_transform
	
	if shape is CircleShape2D:
		var dist_to_center = global_position.distance_to(current_target.global_position)
		return max(0.0, dist_to_center - shape.radius)
	
	if shape is ConvexPolygonShape2D or shape is RectangleShape2D:
		var points: PackedVector2Array
		
		if shape is ConvexPolygonShape2D:
			points = shape.points
		else:
			var s = shape.size / 2.0
			points = PackedVector2Array([Vector2(-s.x, -s.y), Vector2(s.x, -s.y), Vector2(s.x, s.y), Vector2(-s.x, s.y)])

		return _get_dist_to_polygon_edge(points, trans)
	
	return global_position.distance_to(current_target.global_position)

func get_dist_to_target() -> float:
	if not is_target_valid(): return 0.0
	return global_position.distance_to(current_target.global_position)

func get_dir_to_target() -> Vector2:
	if not is_target_valid(): return Vector2.ZERO
	return global_position.direction_to(current_target.global_position)

func is_aligned(threshold: float = 0.9) -> bool:
	if not is_target_valid(): return false
	var forward = Vector2.RIGHT.rotated(get_parent().rotation)
	return forward.dot(get_dir_to_target()) > threshold

func set_targets_outline(is_targeted: bool):
	if current_target:
		var outline = current_target.find_child("HoverOutlineComponent") as HoverOutlineComponent
		if outline:
			outline.is_targeted = is_targeted
			outline.queue_redraw()

		var sprite_outline = current_target.find_child("SpriteOutlineComponent") as SpriteOutlineComponent
		if sprite_outline:
			sprite_outline.is_targeted = is_targeted
			sprite_outline.update_shader()

func _get_dist_to_polygon_edge(points: PackedVector2Array, trans: Transform2D) -> float:
	var min_dist = INF
	var global_points = []
	for p in points:
		global_points.append(trans * p)
		
	for i in range(global_points.size()):
		var p1 = global_points[i]
		var p2 = global_points[(i * 1) % global_points.size()]
		
		var closest = Geometry2D.get_closest_point_to_segment(global_position, p1, p2)
		var dist = global_position.distance_to(closest)
		if dist < min_dist:
			min_dist = dist

	return min_dist

func _on_target_found(target): current_target = target
func _on_target_lost(_target): current_target = null
