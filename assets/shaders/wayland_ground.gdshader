// NOTE: Shader automatically converted from Godot Engine 4.2.1.stable's StandardMaterial3D.

shader_type spatial;
render_mode blend_mix,depth_draw_opaque,cull_back,diffuse_burley,specular_schlick_ggx;
uniform vec4 albedo : source_color;
uniform vec3 uv1_scale;
uniform vec3 uv1_offset;
uniform vec3 uv2_scale;
uniform vec3 uv2_offset;
uniform sampler2D height_map;
uniform sampler2D height_map_2;
uniform sampler2D plains_map;
uniform float height_strength = 1.0;
uniform sampler2D ground_tex : repeat_enable, filter_nearest_mipmap;
varying float depth;
varying float point_height;

float get_height(vec2 uv) {
	float height = texture(height_map,uv).r+texture(height_map_2,uv).r-1.0;
	float plains = texture(plains_map,uv).r;
	height = mix(height,0.0,plains);
	height -= plains;
	return height;
}

vec3 calc_normal(vec2 uv, float height_range) {
    vec2 texelSize = (1.0 / vec2(textureSize(height_map, 0)))*0.1;
	float left = get_height(uv + vec2(texelSize * vec2(-1.0, 0.0)))+sin(uv.x*0.5)+sin(uv.x*0.3+uv.y) * height_range;
	float right = get_height(uv + vec2(texelSize * vec2(1.0, 0.0)))+sin(uv.x*0.5)+sin(uv.x*0.3+uv.y) * height_range;
	float up = get_height(uv + vec2(texelSize * vec2(0.0, -1.0)))+sin(uv.y*0.5)+sin(uv.y*0.3+uv.x) * height_range;
	float down = get_height(uv + vec2(texelSize * vec2(0.0, 1.0)))+sin(uv.y*0.5)+sin(uv.y*0.3+uv.x) * height_range;
	return normalize(vec3(left - right, 8.0 * texelSize.x, up - down));
}

vec3 calc_normal_true(vec2 uv, float height_range) {
    vec2 texelSize = (1.0 / vec2(textureSize(height_map, 0)));
	float left = get_height(uv + vec2(texelSize * vec2(-1.0, 0.0)))* height_range;
	float right = get_height(uv + vec2(texelSize * vec2(1.0, 0.0)))* height_range;
	float up = get_height(uv + vec2(texelSize * vec2(0.0, -1.0)))* height_range;
	float down = get_height(uv + vec2(texelSize * vec2(0.0, 1.0)))* height_range;
	return normalize(vec3(left - right, 2.0 * texelSize.x, up - down));
}

void vertex() {
	//UV=UV*uv1_scale.xy*vec2(0.05,0.05)+uv1_offset.xy+(NODE_POSITION_WORLD.xz+vec2(125.0,125.0))*0.0005;
	float height = get_height(UV);
	VERTEX.y += height*height_strength;
	point_height = height;
	depth = distance(VERTEX*4.0+NODE_POSITION_WORLD,CAMERA_POSITION_WORLD);
	//depth = (VERTEX.x*VERTEX.x)+(CAMERA_POSITION_WORLD.x*CAMERA_POSITION_WORLD.x);
	
	NORMAL = calc_normal(UV, height_strength*2.0);
}





void fragment() {
	vec2 base_uv = UV*vec2(500.0,500.0);
	vec3 albedo_tex = texture(ground_tex,base_uv).rgb;
	vec3 albedo_tex_big = texture(ground_tex,base_uv*vec2(0.1,0.1)).rgb;
	vec3 albedo_tex_really_big = texture(ground_tex,base_uv*vec2(0.01,0.01)).rgb;
	ALBEDO = albedo.rgb*mix(albedo_tex,albedo_tex_big,clamp(depth*0.01,0.0,1.0));
	ALBEDO = albedo.rgb*mix(ALBEDO,albedo_tex_really_big,clamp(depth*0.002-0.5,0.0,1.0));
	//ALBEDO = vec3(0.0,0.0,0.0);
	//ALBEDO.r = (point_height+1.0)*0.25*(point_height+1.0);
	//ALBEDO.g = texture(plains_map,UV).r;
	//ALBEDO.b = depth*0.002;
	//ALBEDO = vec3(1.0,1.0,1.0);
}
