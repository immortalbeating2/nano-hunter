shader_type canvas_item;
render_mode unshaded;

// 符印灵力链由玩法窗口比例裁切；motion_amount=0 时 TIME 的乘积恒为零，像素保持静止。
uniform float window_ratio : hint_range(0.0, 1.0) = 1.0;
uniform float motion_amount : hint_range(0.0, 1.0) = 1.0;
uniform float reaction_mode : hint_range(0.0, 2.0) = 0.0;
uniform vec4 wind_tint : source_color = vec4(0.24, 0.88, 0.78, 1.0);
uniform vec4 thunder_tint : source_color = vec4(0.48, 0.58, 1.0, 1.0);

void fragment() {
	vec2 centered = UV - vec2(0.5);
	float animated_time = TIME * motion_amount;
	float horizontal_core = 1.0 - smoothstep(0.035, 0.13, abs(centered.y));
	float edge_fade = smoothstep(0.0, 0.08, UV.x) * smoothstep(0.0, 0.08, 1.0 - UV.x);
	float chain_pulse = 0.72 + 0.28 * sin(UV.x * 34.0 - animated_time * 9.0);
	float energy = horizontal_core * chain_pulse;

	if (reaction_mode > 0.5 && reaction_mode < 1.5) {
		float sweep_position = fract(animated_time * 0.85);
		float sweep = 1.0 - smoothstep(0.02, 0.16, abs(UV.x - sweep_position));
		energy = max(energy, horizontal_core * (0.72 + sweep * 0.95));
	} else if (reaction_mode >= 1.5) {
		float angle = atan(centered.y, centered.x);
		float rays = pow(abs(cos(angle * 4.0 + animated_time * 1.8)), 12.0);
		float radial_fade = 1.0 - smoothstep(0.08, 0.72, length(centered));
		energy = max(energy * 0.48, rays * radial_fade);
	}

	// 平滑边缘等价于 step(UV.x, window_ratio)，确保真实窗口衰减会缩短可见链路。
	float window_mask = 1.0 - smoothstep(window_ratio, window_ratio + 0.025, UV.x);
	vec3 tint = mix(wind_tint.rgb, thunder_tint.rgb, UV.x);
	COLOR = vec4(tint, clamp(energy * edge_fade * window_mask, 0.0, 1.0));
}
