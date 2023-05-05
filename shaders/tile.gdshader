shader_type canvas_item;

uniform float offset = 0.0;

void fragment() {
	COLOR.rgb *= 1.0 - abs(sin(TIME + offset)) * 0.125;
}
