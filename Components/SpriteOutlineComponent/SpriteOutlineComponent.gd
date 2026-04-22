class_name SpriteOutlineComponent
extends Node2D

@export var outline_width: float = 2.0
@export var hover_color: Color = Color(1, 1, 1, 0.8)
@export var target_color: Color = Color(1, 0.2, 0.2, 1.0)
@export var hover_area: Area2D
@export var sprite: CanvasItem

var is_hovered: bool = false
var is_targeted: bool = false

func _ready():
	if not sprite:
		push_warning("SpriteOutlineComponent couldnt find a Sprite2D or AnimatedSprite2D")

	if hover_area:
		hover_area.mouse_entered.connect(_on_mouse_entered)
		hover_area.mouse_exited.connect(_on_mouse_exited)
		
	var mat = ShaderMaterial.new()
	mat.shader = load("uid://pcmmh6bvi6sf")
	sprite.material = mat
	sprite.material = sprite.material.duplicate()

	update_shader()

func update_shader():
	if not sprite or not sprite.material: return

	var mat = sprite.material as ShaderMaterial
	var color = target_color if is_targeted else hover_color
	
	var thickness = outline_width if (is_hovered or is_targeted) else 0.0

	mat.set_shader_parameter("line_color", color)
	mat.set_shader_parameter("line_thickness", thickness)

func _on_mouse_entered():
	is_hovered = true
	update_shader()

func _on_mouse_exited():
	is_hovered = false
	update_shader()
