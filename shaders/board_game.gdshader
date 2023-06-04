shader_type canvas_item;

float random(vec2 uv) {
    return fract(sin(dot(uv.xy,
        vec2(12.9898,78.233))) *
            43758.5453123);
}

float noise(vec2 uv) {
    vec2 uv_index = floor(uv);
    vec2 uv_fract = fract(uv);

    // Four corners in 2D of a tile
    float a = random(uv_index);
    float b = random(uv_index + vec2(1.0, 0.0));
    float c = random(uv_index + vec2(0.0, 1.0));
    float d = random(uv_index + vec2(1.0, 1.0));

    vec2 blur = smoothstep(0.0, 1.0, uv_fract);

    return mix(a, b, blur.x) +
            (c - a) * blur.y * (1.0 - blur.x) +
            (d - b) * blur.x * blur.y;
}

float fbm(vec2 uv) {
    int octaves = 6;
    float amplitude = 0.5;
    float frequency = 3.0;
	float value = 0.0;
	
    for(int i = 0; i < octaves; i++) {
        value += amplitude * noise(frequency * uv);
        amplitude *= 0.5;
        frequency *= 2.0;
    }
    return value;
}


void fragment()
{
    vec3 ring_color = vec3(0.976, 0.447, 0.023);
    
    vec2 uv = FRAGCOORD.xy/(1.0 / SCREEN_PIXEL_SIZE);
    float ratio = (1.0 / SCREEN_PIXEL_SIZE).y/(1.0 / SCREEN_PIXEL_SIZE).x;
    uv.y *= ratio;
    
    vec2 center = ((1.0 / SCREEN_PIXEL_SIZE).xy * .5f) / (1.0 / SCREEN_PIXEL_SIZE).xy;
    center.y *= ratio;

	float dist = distance(uv, center) * 0.5;
    
    vec3 finalSamp = vec3(0.25);
    vec3 col = ring_color * pow(1.0 - dist, 5.);

    COLOR = vec4(finalSamp + 1.2 * finalSamp * col, 1.);
	
	float noise = 1. + fbm(vec2(UV.x + sin(1.5 * TIME/64.), UV.y + cos(TIME/32.)));
	COLOR.rgb *= vec3(noise);
}