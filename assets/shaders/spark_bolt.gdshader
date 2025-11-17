// NOTE: Shader automatically converted from Godot Engine 4.2.1.stable's StandardMaterial3D.

shader_type spatial;
render_mode blend_mix,depth_prepass_alpha,cull_disabled,diffuse_burley,specular_schlick_ggx;
uniform sampler2D n1 : repeat_enable;
uniform sampler2D gradient : repeat_enable;
uniform vec4 base_col : source_color;
uniform vec3 sec_col : source_color;

void vertex() {
	VERTEX.x += sin(TIME*8.0-VERTEX.y*10.0)*0.01;
	VERTEX.z += sin(TIME*8.0-VERTEX.y*7.0)*0.01;
}






void fragment() {
	vec2 base_uv = UV + vec2(0.0,TIME*1.5);
	vec2 sec_uv = (UV*vec2(0.25,0.25) + vec2(0.0,TIME*0.1));
	ALPHA = texture(n1, base_uv).r * texture(gradient,UV).r * texture(n1, sec_uv).r;
	if (ALPHA < 0.05) {
		ALPHA = 0.0;
	}
	else {
		ALPHA = 1.0;
	}
	ALBEDO = mix(base_col.rgb, sec_col.rgb, texture(n1,base_uv).r);
	EMISSION = ALBEDO * 2.0;
}
