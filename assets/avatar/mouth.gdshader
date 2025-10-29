// NOTE: Shader automatically converted from Godot Engine 4.2.1.stable's StandardMaterial3D.

shader_type spatial;
render_mode blend_mix,depth_draw_opaque,diffuse_burley,specular_toon;
uniform vec3 uv1_scale;
uniform vec3 uv1_offset;
uniform vec2 mouthPos = vec2(0.0,0.0);
uniform vec2 mouth_size = vec2(0.1,0.04);
uniform float smile = 0.0;
uniform float owo = 0.0;
uniform vec3 col_outline : source_color;
uniform vec3 col_internal : source_color;
uniform vec3 col_tongue : source_color;
uniform vec3 col_teeth : source_color;
uniform float teeth = 0.1;
uniform float fangs = 0.0;
uniform float pointy_teeth = 0.0;
uniform float open = 0.0;
uniform float outline_thickness = 0.025;

void vertex() {
	UV=UV*uv1_scale.xy+uv1_offset.xy;
}






void fragment() {
	vec2 uv = UV;
	float trans = 0.0;
	vec3 col = vec3(1.0,1.0,1.0);
	vec2 pos = mouthPos + vec2(0.5,0.5 - open*0.5 + owo);
	float smile_width_mult = 1.0/mouth_size.x;
	//mouth col
	if (uv.y - cos((uv.x-pos.x)*PI*0.5*smile_width_mult)*smile+smile + cos((uv.x-pos.x)*PI*1.5*smile_width_mult)*owo+owo > pos.y - mouth_size.y && uv.y - open + owo*2.0 - cos((uv.x-pos.x)*PI*0.5*smile_width_mult)*smile+smile - cos((uv.x-pos.x)*PI*1.0*smile_width_mult)*owo+owo< pos.y + mouth_size.y && uv.x - sin((uv.y-pos.y-open+smile)*PI*(1.0/open))*open*0.05 > pos.x - mouth_size.x + owo*0.5 && uv.x + sin((uv.y-pos.y-open+smile)*PI * (1.0/open))*open*0.05 < pos.x + mouth_size.x - owo*0.5){
		trans = 1.0;
		col = col_internal;
	}
	//tongue col
	if (uv.y-0.6-mouthPos.y*0.5 - open*0.05> cos((uv.x-mouthPos.x*0.5)*PI*2.0)*0.1) {
		col = col_tongue;
	}
	//teeth
	if (uv.y - teeth+owo*3.0 - cos(uv.x*PI*70.0)*pointy_teeth-pointy_teeth < pos.y - mouth_size.y){
		col = col_teeth;
	} //top
	if (uv.y + teeth-mouth_size.y - open + owo*2.0 + cos(uv.x*PI*64.0)*pointy_teeth+pointy_teeth > pos.y + mouth_size.y){
		col = col_teeth; 
	} //bottom
	
	// mouth outline
	if (uv.y - cos((uv.x-pos.x)*PI*0.5*smile_width_mult)*smile+smile + cos((uv.x-pos.x)*PI*1.5*smile_width_mult)*owo+owo < pos.y - mouth_size.y){
		col = col_outline; //top
	}
	if (uv.y + outline_thickness - open + owo*2.0 - cos((uv.x-pos.x)*PI*0.5*smile_width_mult)*smile+smile - cos((uv.x-pos.x)*PI*1.0*smile_width_mult)*owo+owo > pos.y + mouth_size.y){
		col = col_outline; //bottom
	}
	if (uv.x - outline_thickness*0.5  - sin((uv.y-pos.y-open+smile)*PI*(1.0/open))*open*0.05 < pos.x - mouth_size.x + owo*0.5){
		col = col_outline;
	}
	if (uv.x + outline_thickness*0.5 + sin((uv.y-pos.y-open+smile)*PI*(1.0/open))*open*0.05> pos.x + mouth_size.x - owo*0.5){
		col = col_outline;
	}
	//fangs
	if (uv.y - teeth - cos((uv.x-pos.x-mouth_size.x+0.15)*PI*32.0)*fangs-fangs+ owo*2.0 < pos.y - mouth_size.y - 0.025 && uv.x > pos.x + mouth_size.x - 0.05 && uv.x < pos.x + mouth_size.x && uv.y - cos((uv.x-pos.x)*PI*0.5*smile_width_mult)*smile+smile + cos((uv.x-pos.x)*PI*1.5*smile_width_mult)*owo+owo > pos.y - mouth_size.y){
		col = col_teeth;
		trans = 1.0;
	}
	if (uv.y - teeth - cos((uv.x-pos.x+mouth_size.x+0.035)*PI*32.0)*fangs-fangs+ owo*2.0 < pos.y - mouth_size.y - 0.025 && uv.x < pos.x - mouth_size.x + 0.05 && uv.x > pos.x - mouth_size.x && uv.y - cos((uv.x-pos.x)*PI*0.5*smile_width_mult)*smile+smile + cos((uv.x-pos.x)*PI*1.5*smile_width_mult)*owo+owo > pos.y - mouth_size.y){
		col = col_teeth;
		trans = 1.0;
	}
	//mouth top
	if (uv.y - cos((uv.x-pos.x)*PI*0.5*smile_width_mult)*smile+smile + cos((uv.x-pos.x)*PI*1.5*smile_width_mult)*owo+owo > pos.y - mouth_size.y && uv.y - cos((uv.x-pos.x)*PI*0.5*smile_width_mult)*smile+smile + cos((uv.x-pos.x)*PI*1.5*smile_width_mult)*owo+owo < pos.y + mouth_size.y && uv.x > pos.x - mouth_size.x && uv.x < pos.x + mouth_size.x){
		trans = 1.0;
		col = col_outline;
	}
	ALBEDO = col;
	ALPHA = trans;
}