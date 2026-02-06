shader_type particles;
uniform float num_particles = 8.0; //not sure why float but i need sqrt of it so yeah
uniform int side_length = 4;
uniform float spacing = 1.0;
uniform float y_height = 0.0; //make this texture or something later
uniform float random_pos_strength = 0.0;
uniform float random_rot_strength = 0.0;
uniform float random_size_strength = 0.0;

float randf_from_seed(float seed){
	return sin(seed*157.0+sin(seed*123.0+sin(seed*13.0)*14.0)*12.0); //yeah ik but it works for what we need and is fast
}


void start() {
	float grid_scale = 1.0;
	// Called when a particle is spawned.
	vec3 pos = EMISSION_TRANSFORM[3].xyz - vec3(float(side_length)*0.5*spacing,0.0,float(side_length)*0.5*spacing);
	grid_scale = 1.0 / spacing;
	pos.x = round(pos.x*grid_scale)/grid_scale;
	pos.z = round(pos.z*grid_scale)/grid_scale;
	//dont snap y because height could be anything
	pos.y = y_height;
	int row = int(INDEX);
	int col = int(float(INDEX)/float(side_length));
	row -= col * side_length;
	pos.x += float(row)*spacing;
	pos.z += float(col)*spacing;
	float seed = (pos.x*41.0 + pos.z*23.0)*3.0;
	pos.x += randf_from_seed(seed)*random_pos_strength;
	pos.z += randf_from_seed(seed*2.0)*random_pos_strength;
	//position done
	float rot = 0.0;
	rot = randf_from_seed(seed*7.0)*PI*random_rot_strength;
	//TRANSFORM *= rotation3d(vec3(1.0,0.0,0.0),rot);
	mat4 scaled = EMISSION_TRANSFORM;
	scaled[0].x = sin(rot);
	scaled[0].z = cos(rot);
	scaled[2].x = -cos(rot);
	scaled[2].z = sin(rot);
	
	float size = (1.0-randf_from_seed(seed*13.0)*random_size_strength);
	
	scaled *= size;
	scaled[3].xyz = pos;
	
	//TRANSFORM[3].xyz = pos;
	TRANSFORM = scaled;
}

void process() {
	// Called every frame on existing particles (according to the Fixed FPS property).
	
	//vec3 pos = EMISSION_TRANSFORM[3].xyz - vec3(side*0.5,0.0,side*0.5);
	//TRANSFORM = basis*scale;
	//TRANSFORM[3].xyz = EMISSION_TRANSFORM[3].xyz;
	
}
