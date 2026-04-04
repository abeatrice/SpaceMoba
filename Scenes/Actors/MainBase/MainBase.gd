extends StaticBody2D

func _draw():
	var draw_scale := 5.0

	# Outer diamond
	draw_polygon([
		Vector2(0, -60) * draw_scale,
		Vector2(60, 0) * draw_scale,
		Vector2(0, 60) * draw_scale,
		Vector2(-60, 0) * draw_scale
	], [Color.DARK_GRAY])

	# Inner diamond
	draw_polygon([
		Vector2(0, -30) * draw_scale,
		Vector2(30, 0) * draw_scale,
		Vector2(0, 30) * draw_scale,
		Vector2(-30, 0) * draw_scale
	], [Color.GRAY])

	# Core
	draw_circle(Vector2.ZERO, 10 * draw_scale, Color.SKY_BLUE)

	# Direction line
	draw_line(
		Vector2.ZERO,
		Vector2(80, 0) * draw_scale,
		Color.RED,
		2 * draw_scale
	)
