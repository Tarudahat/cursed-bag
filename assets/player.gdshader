shader_type canvas_item;

uniform bool enabled = false;
uniform float speed = 10.0;

void fragment() {
    vec4 tex = texture(TEXTURE, UV);
    float flicker = enabled ? abs(sin(TIME * speed)) : 1.0;
    COLOR = tex * flicker;
}