// NOTE: Shader automatically converted from Godot Engine 4.2.1.stable's StandardMaterial3D.

shader_type spatial;
render_mode blend_mix,depth_draw_opaque,cull_disabled,diffuse_burley,specular_schlick_ggx,depth_prepass_alpha;
uniform vec4 albedo : source_color;
uniform sampler2D texture_albedo : source_color,filter_nearest_mipmap,repeat_enable;
uniform float point_size : hint_range(0,128);
uniform float roughness : hint_range(0,1);
uniform sampler2D texture_metallic : hint_default_white,filter_nearest_mipmap,repeat_enable;
uniform vec4 metallic_texture_channel;
uniform sampler2D texture_roughness : hint_roughness_r,filter_nearest_mipmap,repeat_enable;
uniform float specular;
uniform float metallic;
uniform vec3 uv1_scale;
uniform vec3 uv1_offset;
uniform vec3 uv2_scale;
uniform vec3 uv2_offset;
uniform float speed = 1.0;


void vertex() {
	UV=UV*uv1_scale.xy+uv1_offset.xy;
	vec3 plus = vec3(0.0,0.0,0.0);
	plus.x += sin(TIME*2.0*speed+VERTEX.z+NODE_POSITION_WORLD.z)*VERTEX.y*0.1;
	plus.x += sin(TIME*1.3*speed+VERTEX.z+NODE_POSITION_WORLD.z)*VERTEX.y*0.1;
	plus.x += sin(TIME*0.5*speed+VERTEX.z+NODE_POSITION_WORLD.z)*VERTEX.y*0.1;
	plus.z += sin(TIME*0.6*speed+VERTEX.x+NODE_POSITION_WORLD.x)*VERTEX.y*0.1;
	plus.z += sin(TIME*1.4*speed+VERTEX.x+NODE_POSITION_WORLD.x)*VERTEX.y*0.1;
	plus.z += sin(TIME*1.9*speed+VERTEX.x+NODE_POSITION_WORLD.x)*VERTEX.y*0.1;
	plus.z += sin((TIME*1.9+VERTEX.x+NODE_POSITION_WORLD.x)*speed)*VERTEX.y*0.1;
	VERTEX += plus;
	VERTEX.y -= (abs(plus.x) + abs(plus.z))*0.25;
}






void fragment() {
	NORMAL = vec3(0.0,1.0,0.0) + VIEW;
	vec2 base_uv = UV;
	vec4 albedo_tex = texture(texture_albedo,base_uv);
	ALBEDO = albedo.rgb * albedo_tex.rgb;
	float metallic_tex = dot(texture(texture_metallic,base_uv),metallic_texture_channel);
	METALLIC = metallic_tex * metallic;
	vec4 roughness_texture_channel = vec4(1.0,0.0,0.0,0.0);
	float roughness_tex = dot(texture(texture_roughness,base_uv),roughness_texture_channel);
	ROUGHNESS = roughness_tex * roughness;
	SPECULAR = specular;
	ALPHA *= albedo.a * albedo_tex.a;
}
