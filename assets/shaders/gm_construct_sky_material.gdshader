shader_type sky;

uniform sampler2D source_panorama : filter_linear, source_color, hint_default_black;

void sky() {
	// Called for every visible pixel in the sky background, as well as all pixels
	// in the radiance cubemap.
	COLOR = texture(source_panorama, SCREEN_UV).rgb;
}
