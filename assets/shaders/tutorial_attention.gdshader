shader_type canvas_item;
render_mode unshaded;

// HUD 共享符光层：内部持续流动，节点本身由 TutorialHUD 追踪当前提示目标。
uniform vec4 glow_color : source_color = vec4(0.25, 0.92, 0.94, 1.0);
uniform float intensity : hint_range(0.0, 2.0) = 0.75;
uniform float motion_amount : hint_range(0.0, 1.0) = 1.0;
uniform float flow_speed : hint_range(0.0, 2.0) = 0.42;
uniform float edge_width : hint_range(0.005, 0.2) = 0.035;

void fragment() {
	vec2 edge_distance = min(UV, vec2(1.0) - UV);
	float nearest_edge = min(edge_distance.x, edge_distance.y);
	float outline = 1.0 - smoothstep(edge_width, edge_width * 2.4, nearest_edge);

	float flow_phase = fract(TIME * flow_speed * motion_amount + 0.5 * (1.0 - motion_amount));
	float wrapped_distance = abs(fract(UV.x - flow_phase + 0.5) - 0.5);
	float tracer = exp(-pow(wrapped_distance / 0.12, 2.0));
	float horizontal_edge = 1.0 - smoothstep(edge_width * 1.4, edge_width * 3.0, edge_distance.y);
	float rune_breaks = 0.62 + 0.38 * step(0.2, fract(UV.x * 17.0 + TIME * 0.18 * motion_amount));
	float breath = mix(1.0, 0.82 + 0.18 * sin(TIME * 2.2), motion_amount);
	float alpha = clamp(outline * 0.34 + tracer * horizontal_edge * rune_breaks * 0.9, 0.0, 1.0);

	COLOR = vec4(glow_color.rgb * intensity * breath, glow_color.a * alpha * intensity);
}
