extends Node2D

var circles = []
var lines = []

func draw_debug_circle(pos: Vector2, radius: float, color: Color):
	circles.append({"pos": pos, "radius": radius, "color": color})
	
func draw_debug_line(start: Vector2, end: Vector2, color: Color, width: float = 2.0):
	lines.append({"start": start, "end": end, "color": color, "width": width})

func _process(_delta):
	queue_redraw()
	
func _draw():
	if not OS.is_debug_build(): return
	
	for c in circles:
		draw_circle(c.pos, c.radius, c.color)	
	for l in lines:
		draw_line(l.start, l.end, l.color, l.width)
		
	circles.clear()
	lines.clear()
