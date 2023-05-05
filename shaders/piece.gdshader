shader_type canvas_item;

uniform bool is_flashing = false;
uniform bool is_selected = false;
uniform bool is_dim = false;

void fragment() {
	if (is_selected) {
		COLOR.rgb *= 1.125;
	} else if (is_dim) {
		COLOR.rgb *= 0.5;
	} else if (is_flashing) {
		COLOR.rgb *= (1.0 + abs(sin(TIME))) / 2.0;
	}
}
