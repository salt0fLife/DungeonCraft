// NOTE: Shader automatically converted from Godot Engine 4.2.1.stable's StandardMaterial3D.

shader_type spatial;
render_mode blend_mix,depth_draw_opaque,cull_back,diffuse_toon;
uniform float power = 1.0;
uniform sampler2D gradient;

void vertex() {
}



void fragment() {
	vec2 base_uv = UV;
	ALBEDO = vec3(0.0,0.0,0.0);
	EMISSION = -vec3(1.0,1.0,1.0)*0.015;
	//float grad = sin(UV.x*PI)*0.1 + sin(UV.y*PI)*0.1;
	float grad = texture(gradient,UV).r;
	float invert = (0.5*(power-(grad*0.4)+0.5));
	//ALBEDO = vec3(invert,invert,invert)*0.05;
	ALPHA = invert;
	if (grad > (0.1+power*0.5)){
		//EMISSION = vec3(1.0,1.0,1.0);
		ALPHA = 0.0;
	}
}
