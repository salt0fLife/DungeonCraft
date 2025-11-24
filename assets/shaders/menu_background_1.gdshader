shader_type canvas_item;
uniform sampler2D n1 : repeat_enable;
uniform vec4 col1 : source_color;
uniform vec4 col2 : source_color;
uniform sampler2D n2 : repeat_enable;
uniform vec4 col3 : source_color;
uniform vec4 col4 : source_color;
uniform sampler2D title_card : source_color, filter_nearest, repeat_disable;
uniform sampler2D shine : source_color, repeat_enable;
uniform vec4 shine_col : source_color;
uniform vec4 background_col : source_color;
uniform vec4 background_col_2 : source_color;
uniform sampler2D gradient : source_color;
uniform vec2 offset_percent = vec2(0.0,0.0);

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec2 rol1_uv = UV + vec2(TIME*0.02,TIME*0.01) + offset_percent*0.001;
	vec2 rol2_uv = UV + vec2(TIME*0.001,TIME*0.005) + offset_percent*0.01;
	vec2 rol3_uv = UV - vec2(TIME*0.005,TIME*0.01) + offset_percent*0.05;
	COLOR = mix(col1,col2,texture(n1,rol2_uv).r);
	COLOR = mix(COLOR,col3,texture(n2,rol1_uv).r);
	COLOR = mix(COLOR,col4,texture(n2,rol1_uv).r*texture(n1,rol2_uv).r);
	COLOR.a = texture(title_card,UV).a;//+vec2(sin(TIME*0.1)*0.01,sin(TIME*0.15)*0.01)).a;
	COLOR.rgb += texture(shine,rol3_uv).rgb * texture(title_card,UV).rgb * shine_col.rgb;
	COLOR.rgb += texture(title_card,UV+vec2(sin(TIME*0.1)*0.01,sin(TIME*0.15)*0.01)).rgb*1.0*shine_col.rgb;
	vec4 COLOR_bg = background_col;
	COLOR_bg = mix(background_col, background_col_2, (texture(gradient,UV).r+texture(gradient,UV).r+texture(gradient,UV).r+texture(n2,rol3_uv).r)*0.25);
	COLOR = mix(COLOR,COLOR_bg,(1.0-COLOR.a));
	NORMAL.b = texture(title_card,UV).a;
	// Called for every pixel the material is visible on.
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
