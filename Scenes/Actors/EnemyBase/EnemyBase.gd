extends StaticBody2D

func _draw():
	var draw_scale := 5.0

	draw_circle(Vector2.ZERO, 50 * draw_scale, Color.DARK_GRAY)
	draw_circle(Vector2.ZERO, 20 * draw_scale, Color.GRAY)

	draw_rect(Rect2(Vector2(-60, -5) * draw_scale, Vector2(120, 10) * draw_scale), Color.LIGHT_GRAY)
	draw_rect(Rect2(Vector2(-5, -60) * draw_scale, Vector2(10, 120) * draw_scale), Color.LIGHT_GRAY)

	draw_line(Vector2.ZERO, Vector2(-80, 0) * draw_scale, Color.RED, 2 * draw_scale)
