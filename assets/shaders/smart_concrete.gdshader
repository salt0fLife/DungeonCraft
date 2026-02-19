shader_type spatial;
uniform sampler2D base_concrete : repeat_enable, filter_nearest;
uniform sampler2D water_stained_concrete : repeat_enable,filter_nearest;
uniform sampler2D weathered_concrete : repeat_enable,filter_nearest;
uniform sampler2D cracked_concrete : repeat_enable, filter_nearest;
uniform sampler2D bleached_concrete : repeat_enable,filter_nearest;
uniform sampler2D noise : repeat_enable,filter_linear;
varying vec2 WORLD_UV;

void vertex() {
	
	//settup triplanar
	vec2 north_uv = VERTEX.xy;
	vec2 west_uv = VERTEX.zy+vec2(5.0,5.0);
	vec2 down_uv = VERTEX.xz+vec2(10.0,10.0);
	
	vec3 norm = (NORMAL);
	WORLD_UV = north_uv;
	WORLD_UV = mix(WORLD_UV,west_uv,norm.x);
	WORLD_UV = mix(WORLD_UV,down_uv,norm.y);
	
	
	
	WORLD_UV *= 0.00390625*32.0;
	// Called for every vertex the material is visible on.
}

float edges(vec2 uv) {
	float difx = (0.5-uv.x);
	float dify = (0.5-uv.y);
	float dif = ((difx*difx)+(dify*dify));
	return (dif*dif*dif)*20.0;
}

void fragment() {
	vec2 uv = UV;
	ALBEDO = texture(base_concrete,WORLD_UV).rgb;
	float n = texture(noise,WORLD_UV*0.1).r;
	n = n * n * n * n;
	n += n;
	
	ALBEDO = mix(ALBEDO,texture(cracked_concrete,WORLD_UV).rgb,n);
	
	float n_2 = texture(noise,WORLD_UV*0.05).r;
	n_2 = n_2 * n_2 * n_2 * n_2;
	n_2 += n_2;
	ALBEDO = mix(ALBEDO,texture(bleached_concrete,WORLD_UV).rgb,n_2);
	
	float edge = edges(uv);
	ALBEDO = mix(ALBEDO,texture(weathered_concrete,uv*vec2(2.0,2.0)).rgb,edge);
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
