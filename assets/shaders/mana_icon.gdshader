shader_type canvas_item;
uniform vec3 mana_col : source_color;
uniform float full_percent : hint_range(0.0, 1.0, 0.01);
uniform vec3 highlight_col : source_color;
uniform vec3 shadow_col : source_color;
uniform float highlight_angle : hint_range(0.0, 1.0, 0.1);
uniform float glow = 0.75;
uniform float amplitude = 0.05;
uniform float frequency = 4.0;
uniform float speed = 2.0;
uniform float wobble = 0.0;
uniform vec3 outline_col : source_color;
uniform vec3 outline_col_shadow : source_color;

bool height_front(vec2 uv){
	float height = (uv.y); //increases range for clipping
	height += sin(uv.x*frequency+ uv.x + TIME*speed)* (amplitude+amplitude*sin(TIME*(wobble*0.5)));
	height += sin(uv.x*frequency+ uv.x + TIME*speed*0.9)* (amplitude+amplitude*sin(TIME*(wobble*0.6)));
	height += sin(uv.x*frequency*2.0+ uv.x + TIME*speed*1.333+PI*0.25)* (amplitude*0.5+0.5*amplitude*sin(2.333*TIME*(wobble*0.2)));
	height += sin(uv.x*frequency*4.0+ uv.x + TIME*speed*2.5*PI*0.5)* (amplitude*0.25+0.25*amplitude*sin(4.2*TIME*(wobble*0.4)));
	return (height < (1.0-full_percent));
}
bool height_back(vec2 uv){
	return !height_front(vec2(uv.x+TIME*0.1,uv.y));
}

float gradient(vec2 uv) {
	//return (sin(uv.x*PI)+sin(uv.y*PI))*0.5;
	vec2 dif = vec2(0.5,0.5) - uv;
	return sqrt(dif.x*dif.x + dif.y*dif.y);
}

void vertex() {
	// Called for every vertex the material is visible on.
}

float magic(vec2 uv) {
	float val = (1.0+sin(uv.x+TIME*speed*wobble))*0.5;
	val = (val + (1.0+sin(uv.y+TIME*speed*wobble*1.2))*0.5)*0.5;
	val = (val + (1.0+sin(uv.x-TIME*speed*wobble*1.5-uv.y))*0.5)*0.5;
	return val;
}

uniform float pixelate = 0.0;
void fragment() {
	vec2 uv = round(UV * float(pixelate)) / float(pixelate);
	COLOR.rgb = mana_col;
	COLOR.r = gradient(uv);
	COLOR.rgb = mix(COLOR.rgb,shadow_col,(gradient(uv)*(UV.y*(1.0-highlight_angle)+UV.x*highlight_angle))*2.0);
	COLOR.rgb = mix(COLOR.rgb,highlight_col,((1.0-gradient(uv))* (1.0-UV.y)*0.75));
	COLOR.rgb += mana_col*glow* ( 0.5 + magic(uv)*0.5);
	if (height_front(uv)){ //fill
		COLOR.a = 0.0;
		if (height_back(uv)){
			COLOR.a = 1.0;
			COLOR.rgb += highlight_col*0.2;
		}
	}
	
	COLOR.rgba = mix(COLOR.rgba,vec4(highlight_col,1.0),0.2*(1.0-gradient(uv)));
	
	//outlines
	if (gradient(uv) > 0.47){
		COLOR.rgb = mix(outline_col,outline_col_shadow,UV.y*0.75);
		COLOR.a = 1.0;
		//COLOR.a = gradient(uv)*3.0-1.0;
		
	}
	if (gradient(uv) > 0.5){
		COLOR.a = 0.0;
	}
	//COLOR.rgb = mix(COLOR.rgb,highlight_col,gradient(uv));
	// Called for every pixel the material is visible on.
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
