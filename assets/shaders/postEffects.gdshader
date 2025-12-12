shader_type canvas_item;
uniform sampler2D ScreenTexture : hint_screen_texture;
uniform float spiral = 0.0;
uniform float wave = 0.0;
uniform float flash = 0.0;
uniform vec3 flash_color : source_color;
uniform sampler2D noise_1 : repeat_enable;
uniform sampler2D red_ramp;
uniform sampler2D green_ramp;
uniform sampler2D blue_ramp;
uniform float grading_power;
uniform sampler2D lightness_map;
uniform float lightness_map_power;
uniform float heart_pounding = 0.0;
uniform sampler2D vingette_tex : filter_linear;
uniform vec3 blood_col : source_color;
uniform sampler2D vision_veins :filter_linear;
uniform vec3 fire_color : source_color;
uniform sampler2D fire_noise : filter_linear, repeat_enable;
uniform sampler2D screen_gradient : filter_linear;
uniform bool burning = false;

vec2 spiral_uv(vec2 uv, vec2 center, float angle) {
	uv -= center;
	angle = angle/length(uv);
	
	mat2 rm = mat2(
		vec2(cos(angle), -sin(angle)),
		vec2(sin(angle), cos(angle))
	);
	
	uv = rm * uv;
	uv += center;
	return uv;
}
vec2 wavy_uv(vec2 uv) {
	//vec2 uv = UV;
	uv.x += sin(TIME*2.0+wave+uv.y*20.0)*0.01*wave;
	uv.x += sin(TIME*1.5*2.0+wave+uv.y*25.0)*0.01*wave;
	uv.y += sin(TIME*1.25*2.0+wave+uv.x*22.0)*0.01*wave;
	uv.y += sin(TIME*1.4*2.0+wave+uv.x*18.0)*0.01*wave;
	return uv;
}

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec2 uv = wavy_uv(UV);
	COLOR = texture(ScreenTexture, spiral_uv(uv, vec2(0.5), spiral));
	vec3 col_flash = mix(flash_color - 0.2, flash_color, texture(noise_1, spiral_uv(uv, vec2(0.5), 0.5) + vec2(TIME*0.25)).r);
	COLOR = vec4(mix(COLOR.rgb, flash_color, flash), 1.0);
	COLOR.rgb = mix(COLOR.rgb, col_flash, flash);
	vec3 graded_col = vec3(0.0,0.0,0.0);
	graded_col += texture(red_ramp,vec2(COLOR.r,0.0)).rgb;
	graded_col += texture(blue_ramp,vec2(COLOR.b,0.0)).rgb;
	graded_col += texture(green_ramp,vec2(COLOR.g,0.0)).rgb;
	COLOR.rgb = mix(COLOR.rgb,graded_col,grading_power);
	float luminance = (COLOR.r + COLOR.g + COLOR.b) * 0.33333333333;
	vec3 lum_grad_col = vec3(1.0) * mix(vec3(0.0), texture(lightness_map, vec2(luminance,0.0)).rgb, lightness_map_power);
	COLOR.rgb += lum_grad_col;
	float h_p = heart_pounding*0.5*heart_pounding*1.25 + sin(TIME*6.1+sin(TIME*12.0))*0.025;
	vec4 vingette = texture(vingette_tex,UV);
	vec4 veins = texture(vision_veins,UV);
	if (veins.r*vingette.r*h_p > 0.1){
		//COLOR.rgb = mix(COLOR.rgb,blood_col,h_p);
		COLOR.rgb = mix(COLOR.rgb,blood_col,vingette.r*h_p*2.0);
	}
	if (heart_pounding > 0.5) {
		COLOR.rgb = mix(COLOR.rgb,COLOR.rgb+blood_col,(heart_pounding-0.5)*veins.r*0.2);
	}
	vec3 fire = texture(screen_gradient,UV).rgb*(texture(fire_noise,UV*vec2(2.0,2.0)+vec2(TIME*0.5,TIME*1.2))*texture(fire_noise,UV*vec2(2.0,2.0)+vec2(-TIME*0.5,TIME*1.5))).rgb;
	if (burning) {
		if (fire.r > 0.15){
			COLOR.rgb = mix(fire_color,vec3(1.0,1.0,1.0),fire.r);
		}
		if (fire.r > 0.1){
			COLOR.rgb += fire_color;
		}
	}
	
	
	//COLOR.rgb = mix(COLOR.rgb, blood_col,(vingette.r+sin(TIME*10.0+sin(TIME*20.0))*0.1)*heart_pounding*0.5);
	//
	//if ((vingette.r+sin(TIME*10.0+sin(TIME*20.0))*0.01+texture(vision_veins, UV).r*0.25)*heart_pounding > 0.2) {
		////COLOR = texture(ScreenTexture,UV+vec2(vingette.r*heart_pounding*0.001*sin(TIME*4.0),vingette.r*heart_pounding*0.001*sin(TIME*4.0)));
		//COLOR.rgb = mix(COLOR.rgb,blood_col,vingette.r*heart_pounding);
		////COLOR = texture(ScreenTexture,UV+vec2(vingette.r*heart_pounding,vingette.r*heart_pounding));
	//}
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
