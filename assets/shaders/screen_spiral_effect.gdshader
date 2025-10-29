shader_type canvas_item;
uniform sampler2D ScreenTexture : hint_screen_texture;
uniform float spiral = 0.0;
uniform float wave = 0.0;

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

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec2 uv = UV;
	uv.x += sin(TIME*2.0+wave+uv.y*20.0)*0.01*wave;
	uv.x += sin(TIME*1.5*2.0+wave+uv.y*25.0)*0.01*wave;
	uv.y += sin(TIME*1.25*2.0+wave+uv.x*22.0)*0.01*wave;
	uv.y += sin(TIME*1.4*2.0+wave+uv.x*18.0)*0.01*wave;
	COLOR = texture(ScreenTexture, spiral_uv(uv, vec2(0.5), spiral));
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
