// NOTE: Shader automatically converted from Godot Engine 4.2.1.stable's StandardMaterial3D.

shader_type spatial;
render_mode blend_mix,depth_draw_opaque,diffuse_burley,specular_schlick_ggx;
uniform vec3 uv1_scale;
uniform vec3 uv1_offset;
uniform vec2 eyeSize;
uniform vec2 pupilSize;
uniform vec2 eyePos = vec2(0.0,0.0);
uniform vec3 whitesColor : source_color;
uniform vec3 eyeColor : source_color;
uniform vec3 eyeColor2 : source_color;
uniform vec3 pupilColor : source_color;
uniform float ec2os;
uniform vec2 eyeLids = vec2(0.5,0.5);
uniform float eyeScale = 1.0;
uniform float eyeTaper = 0.0;
uniform vec2 highlightSize;
uniform vec2 highlightPos;
uniform float highlightTrackIntensity = 0.75;
uniform vec2 eyelashes;
uniform vec3 eyelashCol : source_color;
uniform float eyelashTaper;

void vertex() {
	UV=UV*uv1_scale.xy+uv1_offset.xy;
}






void fragment() {
	vec2 uv = UV;
	vec3 color = whitesColor;
	//eyeColor
	if (uv.x > eyePos.x - eyeSize.x*0.5*eyeScale && uv.x < eyePos.x + eyeSize.x*0.5*eyeScale && uv.y > eyePos.y - eyeSize.y*0.5*eyeScale && uv.y < eyePos.y + eyeSize.y * 0.5*eyeScale){
		color = eyeColor;
	}
	if (uv.x > eyePos.x - pupilSize.x*0.5*eyeScale-ec2os && uv.x < eyePos.x + pupilSize.x*0.5*eyeScale+ec2os && uv.y > eyePos.y - pupilSize.y*0.5*eyeScale-ec2os && uv.y < eyePos.y + pupilSize.y * 0.5*eyeScale+ec2os){
		color = eyeColor2;
	}
	//pupil
	if (uv.x > eyePos.x - pupilSize.x*0.5*eyeScale && uv.x < eyePos.x + pupilSize.x*0.5*eyeScale && uv.y > eyePos.y - pupilSize.y*0.5*eyeScale && uv.y < eyePos.y + pupilSize.y * 0.5*eyeScale){
		color = pupilColor;
	}
	//highlight
	vec2 hlp = vec2(highlightPos.x + eyePos.x*highlightTrackIntensity, highlightPos.y + eyePos.y*highlightTrackIntensity);
	if (uv.x > hlp.x - highlightSize.x && uv.x < hlp.x + highlightSize.x && uv.y > hlp.y - highlightSize.y && uv.y < hlp.y + highlightSize.y){
		color = vec3(255.0,255.0,255.0);
	}
	//eyelashes
	if (uv.y + cos(uv.x)*(eyelashTaper+eyeTaper) < eyeLids.x + eyelashes.x-1.5) {
		color = eyelashCol;
	}
	if (uv.y - cos(uv.x)*(eyelashTaper+eyeTaper*0.25) > eyeLids.y - eyelashes.y+0.5) {
		color = eyelashCol;
	}
	
	ALBEDO = color;
	EMISSION = color*0.25;
	float trans = 1.0;
	if (uv.y + cos(uv.x)* eyeTaper < eyeLids.x-1.5) {
		trans = 0.0;
	}
	if (uv.y - cos(uv.x)* eyeTaper*0.25 > eyeLids.y+0.5) {
		trans = 0.0;
	}
	ALPHA = trans;
	//vec2 base_uv = UV;
	//vec4 albedo_tex = texture(texture_albedo,base_uv);
	//ALBEDO = albedo.rgb * albedo_tex.rgb;
	//float metallic_tex = dot(texture(texture_metallic,base_uv),metallic_texture_channel);
	//METALLIC = metallic_tex * metallic;
	//vec4 roughness_texture_channel = vec4(1.0,0.0,0.0,0.0);
	//float roughness_tex = dot(texture(texture_roughness,base_uv),roughness_texture_channel);
	//ROUGHNESS = roughness_tex * roughness;
	//SPECULAR = specular;
	//vec3 emission_tex = texture(texture_emission,base_uv).rgb;
	//EMISSION = (emission.rgb+emission_tex)*emission_energy;
	//ALPHA *= albedo.a * albedo_tex.a;
	//ALPHA_SCISSOR_THRESHOLD = alpha_scissor_threshold;
}
