shader_type canvas_item;
uniform bool wavy = false;
uniform vec3 enchanted_col : source_color;
uniform sampler2D enchanted_tex : repeat_enable;
uniform bool transparent_background = false;

void vertex() {
	if (wavy) {
		VERTEX.x += sin(TIME*1.25+sin(VERTEX.y))*3.0;
		}
	// Called for every vertex the material is visible on.
}

void fragment() {
	float gradient = sin(UV.x*PI)*(UV.y*2.5);
	//COLOR.rgb *= gradient;
	float ench = pow((texture(enchanted_tex,UV*0.25+vec2(TIME*0.05,TIME*0.025)).r+texture(enchanted_tex,UV*0.25+vec2(TIME*0.03,TIME*0.05)).r+texture(enchanted_tex,UV*0.25+vec2(TIME*-0.02,TIME*0.01)).r)*0.3,3.0);
	COLOR.rgb += (enchanted_col*ench+ench*0.1)*COLOR.rgb*8.0*(enchanted_col*ench+ench*0.1);
	if (COLOR.a < 0.5 && !transparent_background) {
		COLOR.rgb = enchanted_col + gradient*0.175+(sin(TIME*3.0+FRAGCOORD.y*0.1+FRAGCOORD.x*0.05)+1.0)*0.1;
		COLOR.a = gradient*0.3*(enchanted_col.r+enchanted_col.g+enchanted_col.b)*0.765;
	}
	//if (ench*ench*3.0 > 0.2) {
		//if (COLOR.a < 0.5) {
			//COLOR.rgb = (enchanted_col*ench+ench*0.1)*COLOR.rgb*8.0*(enchanted_col*ench+ench*0.1);
			//COLOR.a = 0.1;
		//}
	//}
	// Called for every pixel the material is visible on.
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
