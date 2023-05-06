shader_type canvas_item;

void fragment()
{
    vec3 ring_color = vec3(0.976, 0.447, 0.023);
    
    vec2 uv = FRAGCOORD.xy/(1.0 / SCREEN_PIXEL_SIZE);
    float ratio = (1.0 / SCREEN_PIXEL_SIZE).y/(1.0 / SCREEN_PIXEL_SIZE).x;
    uv.y *= ratio;
    
    vec2 center = ((1.0 / SCREEN_PIXEL_SIZE).xy * .5f) / (1.0 / SCREEN_PIXEL_SIZE).xy;
    center.y *= ratio;

	float dist = distance(uv, center);
    float idist = 1.0 - dist;
    vec2 dir = normalize(uv - center);
    
    vec3 finalSamp = vec3(0.25);
    vec3 col = ring_color * pow(1.0 - dist, 5.);

    COLOR = vec4(finalSamp + 1.2 * finalSamp * col, 1.);
}