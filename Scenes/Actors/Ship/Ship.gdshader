shader_type canvas_item;

void fragment() {
    vec2 uv = UV;
    uv.x += sin(uv.y * 20.0 + TIME * 5.0) * 0.01;

    COLOR = texture(TEXTURE, uv);
}