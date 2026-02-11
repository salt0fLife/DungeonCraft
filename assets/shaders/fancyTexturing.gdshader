shader_type spatial;
uniform vec2 uv_mult = vec2(1.0,1.0);
uniform sampler2D blend_texture : repeat_enable, filter_nearest;
uniform sampler2D tex_base : repeat_enable, filter_nearest;
uniform sampler2D variation_1 : repeat_enable, filter_nearest;
uniform sampler2D variation_1_2 : repeat_enable, filter_nearest;
uniform sampler2D variation_1_3 : repeat_enable, filter_nearest;
uniform sampler2D variation_2 : repeat_enable, filter_nearest;
uniform sampler2D variation_2_2 : repeat_enable, filter_nearest;
uniform sampler2D variation_2_3 : repeat_enable, filter_nearest;


void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Called for every pixel the material is visible on.
	vec2 tex_uv = UV*uv_mult;
	vec2 blend_uv = tex_uv * 0.125*0.5+vec2(NODE_POSITION_WORLD.x+NODE_POSITION_WORLD.y,NODE_POSITION_WORLD.z+NODE_POSITION_WORLD.y)*PI;
	float blend_1 = texture(blend_texture,blend_uv+vec2(0.5,0.0)).r;
	float blend_2 = texture(blend_texture,blend_uv*0.5+vec2(0.0,0.5)).g;
	float blend_3 = texture(blend_texture,blend_uv+vec2(0.5,0.5)).b;
	
	vec3 tex_1 = texture(tex_base,tex_uv).rgb;
	vec3 tex_var_1 = texture(variation_1_3,tex_uv).rgb;//vec3(0.0,0.0,0.0);
	if (blend_1 < 0.6){
		tex_var_1 = texture(variation_1_2,tex_uv).rgb;
		}
	if (blend_1 < 0.25){
		tex_var_1 = texture(variation_1,tex_uv).rgb;
		}
	
	if (blend_2 > 0.5) {
		tex_1 = tex_var_1;
	}
	
	vec3 tex_var_2 = texture(variation_2,tex_uv).rgb;//vec3(0.0,0.0,0.0);
	if (blend_1 < 0.6){
		tex_var_2 = texture(variation_2_2,tex_uv).rgb;
		}
	if (blend_1 < 0.15){
		tex_var_2 = texture(variation_2_3,tex_uv).rgb;
		}
	
	if (blend_3 > 0.5) {
		tex_1 = tex_var_2;
	}
	
	ALBEDO = tex_1*tex_1;
	ROUGHNESS = 1.0;
	
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
