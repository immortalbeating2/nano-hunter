shader_type canvas_item;
render_mode unshaded;

// 单条符光由 TIME 持续驱动；节点移动只负责追踪当前菜单焦点。
uniform vec4 core_color : source_color = vec4(0.42, 0.95, 0.98, 1.0);
uniform vec4 glow_color : source_color = vec4(0.08, 0.58, 0.66, 1.0);
uniform float flow_speed : hint_range(0.1, 2.0) = 0.55;

float noise_1d(float value) {
	float cell = floor(value);
	float blend = fract(value);
	blend = blend * blend * (3.0 - 2.0 * blend);
	float a = fract(sin(cell * 127.1) * 43758.5453);
	float b = fract(sin((cell + 1.0) * 127.1) * 43758.5453);
	return mix(a, b, blend);
}

float random_2d(vec2 cell) {
	return fract(sin(dot(cell, vec2(127.1, 311.7))) * 43758.5453);
}

void fragment() {
	vec2 uv = UV;
	float distance_to_line = abs(uv.y - 0.5);
	float time = TIME * flow_speed;
	float edge_fade = smoothstep(0.0, 0.08, uv.x) * smoothstep(0.0, 0.08, 1.0 - uv.x);
	float ripple = 0.5 + 0.5 * sin(uv.x * 42.0 - time * 12.0 + sin(uv.x * 8.0 + time) * 1.4);
	float core = 1.0 - smoothstep(0.008, 0.032, distance_to_line);
	float glow = (1.0 - smoothstep(0.025, 0.32, distance_to_line)) * (0.14 + ripple * 0.24);
	float pulse = pow(0.5 + 0.5 * sin(uv.x * 18.0 - time * 8.0), 10.0);
	float breakup = 0.72 + noise_1d(uv.x * 48.0 - time * 8.0) * 0.28;
	float dust = smoothstep(0.82, 0.98, noise_1d(uv.x * 82.0 + uv.y * 19.0 - time * 10.0));
	vec2 particle_space = vec2(uv.x * 90.0 - time * 5.0, uv.y * 8.0);
	vec2 particle_cell = floor(particle_space);
	vec2 particle_local = fract(particle_space) - 0.5;
	float particles = step(0.955, random_2d(particle_cell));
	particles *= 1.0 - smoothstep(0.08, 0.20, length(particle_local));
	float energy = core * breakup + glow + pulse * (1.0 - smoothstep(0.01, 0.16, distance_to_line)) * 0.55;
	energy += dust * (1.0 - smoothstep(0.04, 0.34, distance_to_line)) * 0.30;
	energy += particles * (1.0 - smoothstep(0.08, 0.48, distance_to_line)) * 0.60;
	vec3 color = mix(glow_color.rgb, core_color.rgb, clamp(core + pulse * 0.5, 0.0, 1.0));
	COLOR = vec4(color, clamp(energy * edge_fade, 0.0, 1.0));
}
