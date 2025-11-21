
// NOTE: Shader automatically converted from Godot Engine 4.2.1.stable's PanoramaSkyMaterial.


shader_type spatial;
render_mode blend_mix,depth_draw_opaque,unshaded;

uniform sampler2D source_panorama : filter_linear, source_color, hint_default_black;

void fragment() {
	ALBEDO = texture(source_panorama, SCREEN_UV).rgb;
}