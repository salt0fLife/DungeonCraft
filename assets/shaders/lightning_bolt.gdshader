shader_type spatial;
render_mode cull_disabled,unshaded;
uniform vec3 albedo : source_color = vec3(0.2,0.3,0.8);
uniform int octave_count : hint_range(1,20) = 10;
uniform float amp_start = 0.5;
uniform float amp_coeff = 0.5;
uniform float freq_coeff = 2.0;
uniform float filter = 0.05;
uniform float top_fade : hint_range(0.0, 1.0, 0.1) = 0.0;
uniform float wobble_speed = 1.0;
uniform float desync_speed = 1.0;
uniform float desync_amount = 1.0;

float gradient (vec2 uv){
	return (1.0 - sin(uv.x*PI))*0.5 + (1.0 - sin(uv.y*PI))*0.5;
}

float hash12 (vec2 x) {
	return (1.0 - fract(cos(mod(dot(x,vec2(12.1382,8.1282)),12.12))*120834.290784))*0.5;
}

float wave_hash (float t) {
	return (1.0-sin(t*100.0+cos(t*20.0+sin(t*120.0))+sin(t*40.0)))*0.5;
}

float noise(vec2 uv) {
	uv.x += gradient(uv+vec2(-uv.x,TIME*0.5+wave_hash(TIME)*0.25));
	float val = sin(uv.x);
	
	return val;
}

float fbm(vec2 uv, int octaves, vec2 uv_2) {
	float value = 0.0;
	float amplitude = amp_start*(0.5-gradient(uv_2));
	for (int i = 0; i < octaves; i++){
		value += amplitude * noise(uv)*sin(uv.y*4.0);
		uv *= freq_coeff+0.0001*desync_amount*(1.0-sin(TIME*10000.0*desync_speed));
		amplitude *= amp_coeff ;
	}
	return value;
}

void vertex(){
	//Modify the vertex normal so it's pointing towards the camera (positive Z)
	//NORMAL = vec3(0.0, 1.0, 0.0);
	//unshaded we do not need accurate normals
	//Modify the model view matrix to make the vertex look at the camera
	MODELVIEW_MATRIX = VIEW_MATRIX * mat4(
		vec4(normalize(cross(vec3(0.0, 1.0, 0.0), INV_VIEW_MATRIX[2].xyz)), 0.0), 
		vec4(0.0, 1.0, 0.0, 0.0), 
		vec4(normalize(cross(INV_VIEW_MATRIX[0].xyz, vec3(0.0, 1.0, 0.0))), 0.0), 
		MODEL_MATRIX[3]
	);
}

void fragment() {
	vec2 uv = 2.0*UV - 1.0;
	uv += fbm(uv+vec2(0.0,-TIME+NODE_POSITION_WORLD.x+NODE_POSITION_WORLD.z),octave_count,UV);
	float dist = abs(uv.x);
	float lightning = hash12(vec2(TIME+NODE_POSITION_WORLD.x,TIME+NODE_POSITION_WORLD.z))* filter / dist;
	vec3 color = albedo * lightning;
	ALBEDO = color;
	//ALPHA = clamp(lightning,0.0,1.0);
	ALPHA = 0.0;
	if (lightning > 1.0) {
		ALPHA = clamp(lightning*0.01,0.0,1.0);
		ALPHA = mix(ALPHA,ALPHA*clamp((0.5-(1.0-uv.y)*0.25),0.0,1.0),top_fade);
	}
	//ALPHA = clamp((0.5-(1.0-uv.y)*0.25),0.0,1.0);
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
