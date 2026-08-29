shader_type canvas_item;
render_mode unshaded;

// 正常图标必须先通过 Alpha keyline；此遮罩只在异常资产越界时兜底，不能代替像素门禁。
uniform float mask_radius : hint_range(0.0, 0.5) = 0.49;
uniform float feather : hint_range(0.0, 0.1) = 0.01;
uniform vec4 region_uv_rect = vec4(0.0, 0.0, 1.0, 1.0);

void fragment() {
	vec4 sampled = texture(TEXTURE, UV) * COLOR;
	vec2 local_uv = (UV - region_uv_rect.xy) / max(region_uv_rect.zw, vec2(0.000001));
	float radius = length(local_uv - vec2(0.5));
	float mask_alpha = 1.0 - smoothstep(mask_radius - feather, mask_radius, radius);
	sampled.a *= mask_alpha;
	COLOR = sampled;
}
