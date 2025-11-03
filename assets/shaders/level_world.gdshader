// NOTE: Shader automatically converted from Godot Engine 4.2.1.stable's StandardMaterial3D.

shader_type spatial;
render_mode blend_mix,depth_draw_opaque,cull_back,diffuse_burley,specular_schlick_ggx;
uniform vec4 albedo : source_color;
uniform sampler2DArray texture_albedo : source_color,filter_nearest,repeat_enable;
//uniform sampler2DArray texture_normal : source_color,filter_nearest,repeat_enable;
uniform float point_size : hint_range(0,128);
uniform float specular;
uniform vec3 uv1_scale;
uniform vec3 uv1_offset;
uniform vec3 uv2_scale;
uniform vec3 uv2_offset;
varying float tex_index;

void vertex() {
	UV=UV*uv1_scale.xy+uv1_offset.xy;
	tex_index = COLOR.r*100.0;
}






void fragment() {
	vec2 base_uv = UV;
	vec4 albedo_tex = texture(texture_albedo,vec3(base_uv.x,base_uv.y,tex_index));
	ALBEDO = albedo_tex.rgb;
	METALLIC = COLOR.b;
	ROUGHNESS = COLOR.g;
	SPECULAR = specular;
	//NORMAL_MAP = texture(texture_normal,vec3(base_uv.x,base_uv.y,tex_index)).rgb;
	//NORMAL_MAP_DEPTH = 1.0;
	//ALBEDO = vec3(COLOR.r*10.0,ROUGHNESS,METALLIC);
	
}
