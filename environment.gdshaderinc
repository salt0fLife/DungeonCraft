
global uniform vec4 clouds_shadow_color;
global uniform sampler2D clouds_shadow_texture;
global uniform vec4 fog_color;
global uniform float fog_start;
global uniform float fog_strength;
//varying vec2 cloud_shadow_uv;
//cloud shadows and custum fog :3
vec2 get_cloud_uv(vec3 npw, vec3 v) {
	vec3 vertex_world_pos = npw + v;
	vec2 clouds_shadow_uv = vec2(vertex_world_pos.x,vertex_world_pos.z);
	return (clouds_shadow_uv*0.002)+vec2(TIME*0.005,TIME*0.01);
}

vec3 csc_light(vec3 diffuse, vec3 norm, vec3 light, float attunation, vec3 light_col,vec2 c_uv){
	diffuse = clamp(dot(norm, light), 0.0, 1.0) * attunation * light_col / PI;
	//float cs = texture(clouds_shadow_texture,c_uv).r;
	//return mix(diffuse,diffuse*clouds_shadow_color.rgb,cs*3.0);
	return diffuse;
}

vec3 albedo_fog_apply(vec3 diffuse,float dist){
	//float fog = clamp(dist-fog_start, 0.0, 200.0)*0.005; //0.005 is 1/200
	//vec3 nd = mix(diffuse,fog_color.rgb,clamp(fog*fog_strength,0.0,1.0));
	//return nd;
	return diffuse;
}