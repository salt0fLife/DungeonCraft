// NOTE: Shader automatically converted from Godot Engine 4.2.1.stable's StandardMaterial3D.

shader_type spatial;
render_mode blend_mix,depth_draw_opaque,cull_back,diffuse_toon,specular_schlick_ggx,depth_prepass_alpha;
uniform vec4 albedo : source_color;
uniform vec4 col1 : source_color;
uniform vec4 col2 : source_color;
uniform vec4 col3 : source_color;
uniform vec4 col4 : source_color;
uniform sampler2D texture_albedo : source_color,filter_nearest,repeat_enable;
uniform float point_size : hint_range(0,128);
uniform float roughness : hint_range(0,1);
uniform sampler2D texture_metallic : hint_default_white,filter_nearest,repeat_enable;
uniform vec4 metallic_texture_channel;
uniform sampler2D texture_roughness : hint_roughness_r,filter_nearest,repeat_enable;
uniform float specular;
uniform float metallic;
uniform vec3 uv1_scale;
uniform vec3 uv1_offset;
uniform vec3 uv2_scale;
uniform vec3 uv2_offset;
uniform float ghostly = 0.0;
uniform sampler2D SCREEN_T : hint_screen_texture;
uniform bool do_transparency = false;
uniform bool burning = false;
uniform sampler2D fire_tex : repeat_enable, filter_nearest;
uniform vec3 fire_col : source_color;
uniform bool poisoned = false;
uniform bool cursed = false;
uniform bool blessed = false;
uniform sampler2D cursed_tex : repeat_enable, filter_nearest;
uniform vec3 cursed_col : source_color;
uniform sampler2D blessed_tex : repeat_enable, filter_linear;
uniform vec3 blessed_col : source_color;

void vertex() {
	UV=UV*uv1_scale.xy+uv1_offset.xy;
	VERTEX.x += sin(TIME*PI*0.5+VERTEX.y*4.0) * ghostly * 0.005;
	if (burning || cursed){
		VERTEX.x += sin(TIME*10.0+VERTEX.y*50.0+VERTEX.z*40.0+sin(TIME*15.0))*0.002;
		//VERTEX.z += sin(TIME*11.0+VERTEX.y+VERTEX.x+sin(TIME*15.0))*0.005;
		VERTEX.y += sin(TIME*9.0+VERTEX.z*50.0+VERTEX.x*40.0+sin(TIME*15.0))*0.002;
	}
}






void fragment() {
	vec2 base_uv = UV;
	vec4 albedo_tex = texture(texture_albedo,base_uv);
	ALBEDO = col1.rgb;
	ALBEDO = mix(ALBEDO,col2.rgb,albedo_tex.r);
	ALBEDO = mix(ALBEDO,col3.rgb,albedo_tex.g);
	ALBEDO = mix(ALBEDO,col4.rgb,albedo_tex.b);
	ALBEDO = ALBEDO * albedo.rgb;
	float metallic_tex = dot(texture(texture_metallic,base_uv),metallic_texture_channel);
	METALLIC = metallic_tex * metallic;
	vec4 roughness_texture_channel = vec4(1.0,0.0,0.0,0.0);
	float roughness_tex = dot(texture(texture_roughness,base_uv),roughness_texture_channel);
	ROUGHNESS = roughness_tex * roughness;
	SPECULAR = specular;
	ALBEDO = mix(ALBEDO,ALBEDO*vec3(0.5,1.0,0.8),ghostly);
	if (do_transparency || ghostly > 0.0){
		ALPHA = albedo_tex.a - ghostly*0.75;
	}
	if (burning) {
		vec4 fire = texture(fire_tex,base_uv*vec2(5.0,5.0)+vec2(TIME,TIME*0.5))*texture(fire_tex,base_uv*vec2(5.0,5.0)+vec2(TIME*0.5,-TIME));
		ALBEDO = mix(ALBEDO, fire_col,fire.r);
		EMISSION = fire.rgb*fire_col;
	}
	if (poisoned) {
		ALBEDO = mix(ALBEDO, vec3(0.5,1.0,0.5),0.05);
	}
	if (cursed) {
		vec4 curse = texture(cursed_tex,base_uv*vec2(3.0,3.0)+vec2(TIME*0.075,TIME*0.005))*texture(cursed_tex,base_uv*vec2(3.0,3.0)+vec2(TIME*0.005,-TIME*0.05));
		EMISSION += curse.rgb*cursed_col;
	}
	if (blessed) {
		vec4 bless = texture(blessed_tex,base_uv*vec2(1.0,1.0)-vec2(TIME*0.001, TIME*0.002))*texture(cursed_tex,base_uv*vec2(6.0,6.0)+vec2(TIME*0.01,TIME*0.05));
		//ALBEDO = bless.rgb;
		EMISSION += bless.rgb*blessed_col*0.02;
		if (bless.r > 0.75){
			EMISSION += mix(blessed_col, blessed_col*vec3(0.5,0.0,0.2),texture(blessed_tex,base_uv).r)*4.0;
		}
	}
}
