@tool
extends Node3D
@export var reload = false

var world_size = Vector3i(64,16,64)
var blocks = []
var level_name = "level_3_test"
var level_path = "res://world/levels/"
var graphics_paths = []

func _ready():
	if reload:
		quick_build()
	

func resize_blocks():
	blocks = []
	var z = []
	z.resize(world_size.z)
	for f in range(0,z.size()):
		z[f] = 0
	var y = []
	for i in range(0, world_size.y):
		y += [z.duplicate(true)]
	for j in range(0, world_size.x):
		blocks += [y.duplicate(true)]

func generate_world():
	for x in range(0,blocks.size()):
		for y in range(0,blocks[x].size()):
			for z in range(0,blocks[x][y].size()):
				if y < 3:
					blocks[x][y][z] = brick
				elif y == 3:
					if x > 32 and z > 32:
						blocks[x][y][z] = living_dirt
					else: blocks[x][y][z] = dead_dirt
				elif y > 10:
					if x > 48 and z > 48:
						blocks[x][y][z] = air
					else:
						blocks[x][y][z] = metal
				
				if y > 13 and x >11 and x < 33 and z > 11 and z < 33:
					blocks[x][y][z] = brick
					pass
				
				if y > 13 and x >12 and x < 32 and z > 12 and z < 32:
					if y > 14:
						blocks[x][y][z] = air
					else:
						blocks[x][y][z] = living_dirt
					
	blocks[0][1][1] = air
	blocks[0][1][2] = air
	blocks[0][1][3] = air
	blocks[0][2][1] = air
	blocks[0][2][2] = air
	blocks[0][2][3] = air
	blocks[0][3][1] = air
	blocks[0][3][2] = air
	blocks[0][3][3] = air
	blocks[1][2][1] = air
	blocks[1][2][2] = air
	blocks[1][2][3] = air
	blocks[1][3][1] = air
	blocks[1][3][2] = air
	blocks[1][3][3] = air
	blocks[2][3][1] = air
	blocks[2][3][2] = air
	blocks[2][3][3] = air
	
	
	blocks[3][4][0] = brick
	blocks[3][5][0] = brick
	blocks[3][6][0] = brick
	blocks[3][7][0] = brick
	blocks[3][8][0] = brick
	blocks[3][9][0] = brick
	blocks[3][10][0] = brick
	
	blocks[6][4][0] = brick
	blocks[6][5][0] = brick
	blocks[6][6][0] = brick
	blocks[6][7][0] = brick
	blocks[6][8][0] = brick
	blocks[6][9][0] = brick
	blocks[6][10][0] = brick
	
	blocks[10][4][0] = brick
	blocks[10][5][0] = brick
	blocks[10][6][0] = brick
	blocks[10][7][0] = brick
	blocks[10][8][0] = brick
	blocks[10][9][0] = brick
	blocks[10][10][0] = brick
	
	blocks[15][4][0] = brick
	blocks[15][5][0] = brick
	blocks[15][6][0] = brick
	blocks[15][7][0] = brick
	blocks[15][8][0] = brick
	blocks[15][9][0] = brick
	blocks[15][10][0] = brick
	
	blocks[15][10][1] = living_dirt
	
	blocks[15][4][15] = brick
	
	blocks[17][7][15] = metal
	blocks[18][7][15] = metal
	blocks[19][7][15] = metal
	blocks[17][8][15] = metal
	blocks[18][8][15] = metal
	blocks[19][8][15] = metal
	blocks[17][9][15] = metal
	blocks[18][9][15] = metal
	blocks[19][9][15] = metal
	blocks[17][10][15] = metal
	blocks[18][10][15] = metal
	blocks[19][10][15] = metal
	
	blocks[20][8][15] = metal
	blocks[21][8][15] = metal
	blocks[22][8][15] = metal
	blocks[20][9][15] = metal
	blocks[21][9][15] = metal
	blocks[22][9][15] = metal
	blocks[20][10][15] = metal
	blocks[21][10][15] = metal
	blocks[22][10][15] = metal
	
	blocks[23][9][15] = metal
	blocks[24][9][15] = metal
	blocks[25][9][15] = metal
	blocks[23][10][15] = metal
	blocks[24][10][15] = metal
	blocks[25][10][15] = metal
	
	blocks[26][10][15] = metal
	blocks[27][10][15] = metal
	blocks[28][10][15] = metal
	
	
	blocks[28][9][15] = metal
	blocks[16][5][16] = living_dirt
	blocks[17][5][16] = living_dirt
	blocks[17][5][17] = living_dirt
	blocks[16][5][17] = living_dirt

func add_effects():
	var n = Node3D.new()
	var sn = Node3D.new()
	n.name = "plant_parent"
	sn.name = "junk_parent"
	add_child(n,true)
	add_child(sn,true)
	n.owner = self
	sn.owner = self
	var noise_1 = FastNoiseLite.new()
	for x in range(0,blocks.size()):
		for y in range(0,blocks[x].size()):
			for z in range(0,blocks[x][y].size()):
				var type = blocks[x][y][z]
				#grow grass on fertile blocks
				if block_data[type]["fertile"]:
					if can_see_sky(x,y,z):
						if float(y)+1.0>=world_size.y or blocks[x][y+1][z] == air:
							var grow = noise_1.get_noise_3d(x*16,y*16,z*16)
							if grow > -0.1:
								grow_plants(x,y,z,1.0, n, true)
					else:
						if float(y)+1.0>=world_size.y or blocks[x][y+1][z] == air:
							var grow = noise_1.get_noise_3d(x*16,y*16,z*16)
							if grow > 0.25:
								grow_plants(x,y,z,1.0, n, false)
				
				#perform block specific functions
				match type:
					brick:
						var bp = noise_1.get_noise_3d(x*50,y*50,z*50)
						if bp > 0.35:
							add_brick(x,y,z,sn)
							pass
				

func can_see_sky(x,y,z) -> bool:
	var check = 0
	while y+check+1<world_size.y:
		check += 1
		var type = blocks[x][y+check][z]
		if !block_data[type]["transparent"]:
			return false
	return true

func get_open_edges(x,y,z) -> Array:
	var v = [false]
	#x
	if (x + 1 >= world_size.x):
		v[0] = true
		v += [Vector2(1.0,0.0)]
	elif block_data[blocks[x+1][y][z]]["transparent"]:
		v[0] = true
		v += [Vector2(1.0,0.0)]
	if (x - 1 < 0):
		v[0] = true
		v += [Vector2(-1.0,0.0)]
	elif block_data[blocks[x-1][y][z]]["transparent"]:
		v[0] = true
		v += [Vector2(-1.0,0.0)]
	#z
	if (z + 1 >= world_size.z):
		v[0] = true
		v += [Vector2(0.0,1.0)]
	elif block_data[blocks[x][y][z+1]]["transparent"]:
		v[0] = true
		v += [Vector2(0.0,1.0)]
	if (z - 1 < 0):
		v[0] = true
		v += [Vector2(0.0,-1.0)]
	elif block_data[blocks[x][y][z-1]]["transparent"]:
		v[0] = true
		v += [Vector2(0.0,-1.0)]
	return v

const plants = [
	"res://assets/environmentPieces/level_details/grass_1.tscn",
	"res://assets/environmentPieces/level_details/grass_2.tscn",
	"res://assets/environmentPieces/level_details/grass_3.tscn",
	"res://assets/environmentPieces/level_details/flower_1.tscn"
	]

const hardy_plants = [
	0,1,2
]

func grow_plants(x,y,z,scale_mult, node, sky = true):
	await get_tree().process_frame
	var free_x = 1.0
	var mod_x = 0.0
	var free_z = 1.0
	var mod_z = 0.0
	#makes sure grass never grows on air or non_fertile substances
	if !x+1>=world_size.x:
		if !block_data[blocks[x+1][y][z]]["fertile"]:
			mod_x -= unit_scale*0.5
			free_x -= 0.5
	else:
		mod_x -= unit_scale*0.5
		free_x -= 0.5
	if !x-1<0:
		if !block_data[blocks[x-1][y][z]]["fertile"]:
			mod_x += unit_scale*0.5
			free_x -= 0.5
	else:
		mod_x += unit_scale*0.5
		free_x -= 0.5
	if !z+1 >= world_size.z:
		if !block_data[blocks[x][y][z+1]]["fertile"]:
			mod_z -= unit_scale*0.5
			free_z -= 0.5
	else:
		mod_z -= unit_scale*0.5
		free_z -= 0.5
	if !z-1<0:
		if !block_data[blocks[x][y][z-1]]["fertile"]:
			mod_z += unit_scale*0.5
			free_z -= 0.5
	else:
		mod_z += unit_scale*0.5
		free_z -= 0.5
	
	var n = FastNoiseLite.new()
	var i = 0
	if sky: 
		i = int(abs(n.get_noise_3d(x*75.0,y*75.0,z*75.0)*255.0))
		while i > plants.size()-1:
			i -= plants.size()
	else:
		i = int(abs(n.get_noise_3d(x*75.0,y*75.0,z*75.0)*255.0))
		while i > hardy_plants.size()-1:
			i -= hardy_plants.size()
		i = hardy_plants[i]
	var p = load(plants[i]).instantiate()
	p.position = Vector3(x*unit_scale+unit_scale*0.5,y*unit_scale+unit_scale,z*unit_scale+unit_scale*0.5)
	p.position.x += (n.get_noise_3d(x*100.0,y*100.0,z*100.0)*unit_scale + mod_x)*free_x
	p.position.z += (n.get_noise_3d(x*100.0,y*100.0,z*100.0)*unit_scale + mod_z)*free_z
	var s = unit_scale*1.5*(n.get_noise_3d(x*10.0,y*10.0,z*10.0)+1.0)*0.5
	p.scale = Vector3(s*(free_x+unit_scale),s*1.5,s*(free_z+unit_scale))
	p.rotation.y = n.get_noise_3d(x*64.0,y*64.0,z*64.0)*0.5
	node.add_child(p,true)
	p.owner = self
	pass

func add_brick(x,y,z,node):
	await get_tree().process_frame
	var b = load("res://assets/environmentPieces/level_details/brick.tscn").instantiate()
	var n = FastNoiseLite.new()
	var r = n.get_noise_3d(x,y,z)
	var length = unit_scale*randf_range(0.9,1.6)
	var off_y = unit_scale*randf_range(-1.0,1.0)*0.1
	var off_hori = unit_scale*randf_range(-1.0,1.0)*0.1
	b.position = Vector3(x,y,z) * unit_scale + Vector3(unit_scale,unit_scale,unit_scale)*0.5
	b.position.y += off_y
	
	var o_s = get_open_edges(x,y,z)
	if ! o_s[0]:
		#nowhere to put brick :(
		return
	#somewhere to put brick :D
	o_s.remove_at(0)
	
	var i = randi_range(0, o_s.size()-1.0)
	var dir = o_s[i]
	
	b.scale.z = length
	
	b.position.x += dir.x*unit_scale*randf_range(0.25,0.5)
	b.position.z += dir.y*unit_scale*randf_range(0.25,0.5)
	
	b.position.z += dir.x*off_hori
	b.position.x += dir.y*off_hori
	
	node.add_child(b,true)
	b.owner = self
	b.rotation.y += PI*0.5*dir.y
	pass

const unit_scale = 0.4

enum directions {
	up,down,north,south,east,west
}

#block types
enum {
	air,
	brick,
	living_dirt,
	dead_dirt,
	metal
}

const block_data = {
	air : {
		"transparent" : true,
		"fertile" : false
	},
	brick : {
		"transparent" : false,
		UP : 3,
		DOWN : 4,
		NORTH : 4,
		SOUTH : 4,
		EAST : 4,
		WEST : 4,
		"roughness" : 0.9,
		"metallic" : 0.0,
		"fertile" : false
	},
	living_dirt : {
		"transparent" : false,
		UP : 0,
		DOWN : 1,
		NORTH : 0,
		SOUTH : 0,
		EAST : 0,
		WEST : 0,
		"roughness" : 0.8,
		"metallic" : 0.0,
		"fertile" : true
	},
	dead_dirt : {
		"transparent" : false,
		UP : 1,
		DOWN : 1,
		NORTH : 1,
		SOUTH : 1,
		EAST : 1,
		WEST : 1,
		"roughness" : 0.8,
		"metallic" : 0.0,
		"fertile" : false
	},
	metal : {
		"transparent" : false,
		UP : 5,
		DOWN : 5,
		NORTH : 2,
		SOUTH : 2,
		EAST : 2,
		WEST : 2,
		"roughness" : 0.5,
		"metallic" : 0.8,
		"fertile" : false
	},
}


var st = SurfaceTool.new()
var material = load("res://assets/materials/worldShaderMat.tres")
func create_mesh():
	var mi = MeshInstance3D.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for x in range(0,blocks.size()):
		for y in range(0,blocks[x].size()):
			for z in range(0,blocks[x][y].size()):
				var type = blocks[x][y][z]
				if type != air:
					create_block(type, Vector3(x,y,z))
	st.generate_normals()
	var m = st.commit()
	mi.mesh = m
	mi.set_surface_override_material(0,material)
	add_child(mi,true)
	
	var col = StaticBody3D.new()
	add_child(col,true)
	var shape = CollisionShape3D.new()  #mi.mesh.create_trimesh_shape()
	shape.shape = mi.mesh.create_trimesh_shape()
	col.add_child(shape,true)
	mi.owner = self
	col.owner = self
	shape.owner = self
	graphics_paths += [mi]
	graphics_paths += [col]




func create_greedy_mesh():
	var meshed = {
		NORTH : [],
		SOUTH : [],
		EAST : [],
		WEST : [],
		UP: [],
		DOWN: [],
	}
	var mi = MeshInstance3D.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	var x = 0
	var y = 0
	var z = 0
	
	while x < world_size.x:
		while y < world_size.y:
			while z < world_size.z:
				var type = blocks[x][y][z]
				if type != air:
					var coords = Vector3(x,y,z)
					#north
					if ((z + 1 >= world_size.z) or (block_data[blocks[x][y][z+1]]["transparent"])) and !meshed[NORTH].has(Vector3i(x,y,z)):
						var greed_x = 0
						while (x + greed_x + 1) < world_size.x and blocks[x+greed_x + 1][y][z] == type and ((z + 1 >= world_size.z) or block_data[blocks[x+greed_x + 1][y][z+1]]["transparent"]):
							greed_x += 1
							meshed[NORTH] += [Vector3i(x+greed_x,y,z)]
						
						var greed_y = 0
						var y_greed_dead = false
						while !y_greed_dead and (y + greed_y + 1 < world_size.y):
							for gx in range(0,greed_x+1):
								if !blocks[x+gx][y+greed_y+1][z] == type:
									y_greed_dead = true
								elif !((z + 1 >= world_size.z) or (block_data[blocks[x+gx][y+greed_y+1][z+1]]["transparent"])):
									y_greed_dead = true
								elif meshed[NORTH].has(Vector3i(x+gx,y+greed_y+1,z)):
									y_greed_dead = true
							if ! y_greed_dead:
								for cgx in range(0,greed_x+1):
									meshed[NORTH] += [Vector3i(x+cgx,y+greed_y+1,z)]
									pass
								greed_y += 1
						
						
						var a = (vertices[NORTH[0]] + coords + Vector3(greed_x,greed_y,0))*unit_scale
						var b = (vertices[NORTH[1]] + coords + Vector3(greed_x,0,0))*unit_scale
						var c = (vertices[NORTH[2]] + coords)*unit_scale
						var d = (vertices[NORTH[3]] + coords + Vector3(0,greed_y,0))*unit_scale
						
						#var uv_offset = block_data[type]["north"] / atlas_size
						#
						#var height = 1.0 / atlas_size.y
						#var width = 1.0 / atlas_size.x
						
						var uv_a = Vector2(0,-greed_y-1)#uv_offset + Vector2(0, 0) + Vector2(0,-greed_y*height)
						var uv_b = Vector2.ZERO#uv_offset + Vector2(0, height)
						var uv_c = Vector2(-greed_x-1,0)#uv_offset + Vector2(width, height) + Vector2(greed_x*width,0)
						var uv_d = Vector2(-greed_x-1,-greed_y-1)#uv_offset + Vector2(width, 0) + Vector2(greed_x*width,-greed_y*height)
						
						var col = Color(float(block_data[type][NORTH])*0.01,block_data[type]["roughness"],block_data[type]["metallic"],0.0)
						
						st.add_triangle_fan(([a, b, c]), ([uv_a, uv_b, uv_c]), ([col,col,col]))
						st.add_triangle_fan(([a, c, d]), ([uv_a, uv_c, uv_d]), ([col,col,col]))
					#south
					if ((z - 1 < 0) or (block_data[blocks[x][y][z-1]]["transparent"])) and !meshed[SOUTH].has(Vector3i(x,y,z)):
						var greed_x = 0
						while (x + greed_x + 1) < world_size.x and blocks[x+greed_x + 1][y][z] == type and ((z - 1 < 0) or block_data[blocks[x+greed_x + 1][y][z-1]]["transparent"]):
							greed_x += 1
							meshed[SOUTH] += [Vector3i(x+greed_x,y,z)]
						
						var greed_y = 0
						var y_greed_dead = false
						while !y_greed_dead and (y + greed_y + 1 < world_size.y):
							for gx in range(0,greed_x+1):
								if !blocks[x+gx][y+greed_y+1][z] == type:
									y_greed_dead = true
								elif !((z - 1 < 0) or (block_data[blocks[x+gx][y+greed_y+1][z-1]]["transparent"])):
									y_greed_dead = true
								elif meshed[SOUTH].has(Vector3i(x+gx,y+greed_y+1,z)):
									y_greed_dead = true
							if ! y_greed_dead:
								for cgx in range(0,greed_x+1):
									meshed[SOUTH] += [Vector3i(x+cgx,y+greed_y+1,z)]
									pass
								greed_y += 1
						
						
						var a = (vertices[SOUTH[0]] + coords + Vector3(0,greed_y,0))*unit_scale
						var b = (vertices[SOUTH[1]] + coords + Vector3(0,0,0))*unit_scale
						var c = (vertices[SOUTH[2]] + coords + Vector3(greed_x,0,0))*unit_scale
						var d = (vertices[SOUTH[3]] + coords + Vector3(greed_x,greed_y,0))*unit_scale
						
						#var uv_offset = block_data[type]["south"] / atlas_size
						#
						#var height = 1.0 / atlas_size.y
						#var width = 1.0 / atlas_size.x
						
						#var uv_d = uv_offset + Vector2(0, 0)
						#var uv_c = uv_offset + Vector2(0, height)
						#var uv_b = uv_offset + Vector2(width, height)
						#var uv_a = uv_offset + Vector2(width, 0)
						
						var uv_a = Vector2(0,-greed_y-1)
						var uv_b = Vector2.ZERO
						var uv_c = Vector2(-greed_x-1,0)
						var uv_d = Vector2(-greed_x-1,-greed_y-1)
						
						var col = Color(float(block_data[type][SOUTH])*0.01,block_data[type]["roughness"],block_data[type]["metallic"],0.0)
						
						st.add_triangle_fan(([a, b, c]), ([uv_a, uv_b, uv_c]), ([col,col,col]))
						st.add_triangle_fan(([a, c, d]), ([uv_a, uv_c, uv_d]), ([col,col,col]))
						pass
					#east
					if ((x + 1 >= world_size.x) or (block_data[blocks[x+1][y][z]]["transparent"])) and !meshed[EAST].has(Vector3i(x,y,z)):
						var greed_z = 0
						while (z + greed_z + 1) < world_size.z and blocks[x][y][z+greed_z + 1] == type and ((x + 1 >= world_size.x) or block_data[blocks[x+1][y][z+greed_z + 1]]["transparent"]):
							meshed[EAST] += [Vector3i(x,y,z+greed_z + 1)]
							greed_z += 1
						
						var greed_y = 0
						var y_greed_dead = false
						while !y_greed_dead and (y + greed_y + 1 < world_size.y):
							for gz in range(0,greed_z+1):
								if !blocks[x][y+greed_y+1][z+gz] == type:
									y_greed_dead = true
								elif !((x + 1 >= world_size.x) or (block_data[blocks[x+1][y+greed_y+1][z+gz]]["transparent"])):
									y_greed_dead = true
								elif meshed[EAST].has(Vector3i(x,y+greed_y+1,z+gz)):
									y_greed_dead = true
							if ! y_greed_dead:
								for cgz in range(0,greed_z+1):
									meshed[EAST] += [Vector3i(x,y+greed_y+1,z+cgz)]
									pass
								greed_y += 1
						
						var a = (vertices[EAST[0]] + coords + Vector3(0,greed_y,0))*unit_scale
						var b = (vertices[EAST[1]] + coords + Vector3(0,0,0))*unit_scale
						var c = (vertices[EAST[2]] + coords + Vector3(0,0,greed_z))*unit_scale
						var d = (vertices[EAST[3]] + coords + Vector3(0,greed_y,greed_z))*unit_scale
						
						#var uv_offset = block_data[type]["east"] / atlas_size
						#
						#var height = 1.0 / atlas_size.y
						#var width = 1.0 / atlas_size.x
						#
						#var uv_d = uv_offset + Vector2(0, 0)
						#var uv_c = uv_offset + Vector2(0, height)
						#var uv_b = uv_offset + Vector2(width, height)
						#var uv_a = uv_offset + Vector2(width, 0)
						var uv_a = Vector2(0,-greed_y-1)
						var uv_b = Vector2.ZERO
						var uv_c = Vector2(-greed_z-1,0)
						var uv_d = Vector2(-greed_z-1,-greed_y-1)
						
						var col = Color(float(block_data[type][EAST])*0.01,block_data[type]["roughness"],block_data[type]["metallic"],0.0)
						
						
						st.add_triangle_fan(([a, b, c]), ([uv_a, uv_b, uv_c]), ([col,col,col]))
						st.add_triangle_fan(([a, c, d]), ([uv_a, uv_c, uv_d]), ([col,col,col]))
					#west
					if ((x - 1 < 0) or (block_data[blocks[x-1][y][z]]["transparent"])) and !meshed[WEST].has(Vector3i(x,y,z)):
						var greed_z = 0
						while (z + greed_z + 1) < world_size.z and blocks[x][y][z+greed_z + 1] == type and ((x - 1 < 0) or block_data[blocks[x-1][y][z+greed_z + 1]]["transparent"]):
							meshed[WEST] += [Vector3i(x,y,z+greed_z + 1)]
							greed_z += 1
						
						var greed_y = 0
						var y_greed_dead = false
						while !y_greed_dead and (y + greed_y + 1 < world_size.y):
							for gz in range(0,greed_z+1):
								if !blocks[x][y+greed_y+1][z+gz] == type:
									y_greed_dead = true
								elif !((x - 1 < 0) or (block_data[blocks[x-1][y+greed_y+1][z+gz]]["transparent"])):
									y_greed_dead = true
								elif meshed[WEST].has(Vector3i(x,y+greed_y+1,z+gz)):
									y_greed_dead = true
							if ! y_greed_dead:
								for cgz in range(0,greed_z+1):
									meshed[WEST] += [Vector3i(x,y+greed_y+1,z+cgz)]
									pass
								greed_y += 1
						
						var a = (vertices[WEST[0]] + coords + Vector3(0,greed_y,greed_z))*unit_scale
						var b = (vertices[WEST[1]] + coords + Vector3(0,0,greed_z))*unit_scale
						var c = (vertices[WEST[2]] + coords + Vector3(0,0,0))*unit_scale
						var d = (vertices[WEST[3]] + coords + Vector3(0,greed_y,0))*unit_scale
						
						#var uv_offset = block_data[type]["west"] / atlas_size
						#
						#var height = 1.0 / atlas_size.y
						#var width = 1.0 / atlas_size.x
						#
						#var uv_d = uv_offset + Vector2(0, 0)
						#var uv_c = uv_offset + Vector2(0, height)
						#var uv_b = uv_offset + Vector2(width, height)
						#var uv_a = uv_offset + Vector2(width, 0)
						
						var uv_a = Vector2(0,-greed_y-1)
						var uv_b = Vector2.ZERO
						var uv_c = Vector2(-greed_z-1,0)
						var uv_d = Vector2(-greed_z-1,-greed_y-1)
						
						var col = Color(float(block_data[type][WEST])*0.01,block_data[type]["roughness"],block_data[type]["metallic"],0.0)
						
						st.add_triangle_fan(([a, b, c]), ([uv_a, uv_b, uv_c]), ([col,col,col]))
						st.add_triangle_fan(([a, c, d]), ([uv_a, uv_c, uv_d]), ([col,col,col]))
					#up
					if ((y + 1 >= world_size.y) or (block_data[blocks[x][y+1][z]]["transparent"])) and !meshed[UP].has(Vector3i(x,y,z)):
						var greed_x = 0
						while (x + greed_x + 1) < world_size.x and blocks[x+greed_x + 1][y][z] == type and ((y + 1 >= world_size.y) or block_data[blocks[x+greed_x + 1][y+1][z]]["transparent"]):
							greed_x += 1
							meshed[UP] += [Vector3i(x+greed_x,y,z)]
						
						var greed_z = 0
						var z_greed_dead = false
						while !z_greed_dead and (z + greed_z + 1 < world_size.z):
							for gx in range(0,greed_x+1):
								if !blocks[x+gx][y][z+greed_z+1] == type:
									z_greed_dead = true
								elif !((y + 1 >= world_size.y) or (block_data[blocks[x+gx][y+1][z+greed_z+1]]["transparent"])):
									z_greed_dead = true
								elif meshed[UP].has(Vector3i(x+gx,y,z+greed_z+1)):
									z_greed_dead = true
							if ! z_greed_dead:
								for cgx in range(0,greed_x+1):
									meshed[UP] += [Vector3i(x+cgx,y,z+greed_z+1)]
									pass
								greed_z += 1
						var a = (vertices[UP[0]] + coords + Vector3(0,0,0))*unit_scale
						var b = (vertices[UP[1]] + coords + Vector3(greed_x,0,0))*unit_scale
						var c = (vertices[UP[2]] + coords + Vector3(greed_x,0,greed_z))*unit_scale
						var d = (vertices[UP[3]] + coords + Vector3(0,0,greed_z))*unit_scale
						
						#var uv_offset = block_data[type]["up"] / atlas_size
						#
						#var height = 1.0 / atlas_size.y
						#var width = 1.0 / atlas_size.x
						#
						#var uv_d = uv_offset + Vector2(0, 0)
						#var uv_c = uv_offset + Vector2(0, height)
						#var uv_b = uv_offset + Vector2(width, height)
						#var uv_a = uv_offset + Vector2(width, 0)
						
						var uv_a = Vector2(0,-greed_x-1)
						var uv_b = Vector2.ZERO
						var uv_c = Vector2(-greed_z-1,0)
						var uv_d = Vector2(-greed_z-1,-greed_x-1)
						
						var col = Color(float(block_data[type][UP])*0.01,block_data[type]["roughness"],block_data[type]["metallic"],0.0)
						
						st.add_triangle_fan(([a, b, c]), ([uv_a, uv_b, uv_c]), ([col,col,col]))
						st.add_triangle_fan(([a, c, d]), ([uv_a, uv_c, uv_d]), ([col,col,col]))
					#down
					if ((y -1 < 0) or (block_data[blocks[x][y-1][z]]["transparent"])) and !meshed[DOWN].has(Vector3i(x,y,z)):
						var greed_x = 0
						while (x + greed_x + 1) < world_size.x and blocks[x+greed_x + 1][y][z] == type and ((y -1 < 0) or block_data[blocks[x+greed_x + 1][y-1][z]]["transparent"]):
							greed_x += 1
							meshed[DOWN] += [Vector3i(x+greed_x,y,z)]
						
						var greed_z = 0
						var z_greed_dead = false
						while !z_greed_dead and (z + greed_z + 1 < world_size.z):
							for gx in range(0,greed_x+1):
								if !blocks[x+gx][y][z+greed_z+1] == type:
									z_greed_dead = true
								elif !((y - 1 < 0) or (block_data[blocks[x+gx][y-1][z+greed_z+1]]["transparent"])):
									z_greed_dead = true
								elif meshed[DOWN].has(Vector3i(x+gx,y,z+greed_z+1)):
									z_greed_dead = true
							if ! z_greed_dead:
								for cgx in range(0,greed_x+1):
									meshed[DOWN] += [Vector3i(x+cgx,y,z+greed_z+1)]
									pass
								greed_z += 1
						var a = (vertices[DOWN[0]] + coords + Vector3(0,0,0))*unit_scale
						var b = (vertices[DOWN[1]] + coords + Vector3(0,0,greed_z))*unit_scale
						var c = (vertices[DOWN[2]] + coords + Vector3(greed_x,0,greed_z))*unit_scale
						var d = (vertices[DOWN[3]] + coords + Vector3(greed_x,0,0))*unit_scale
						
						#var uv_offset = block_data[type]["down"] / atlas_size
						#
						#var height = 1.0 / atlas_size.y
						#var width = 1.0 / atlas_size.x
						#
						#var uv_d = uv_offset + Vector2(0, 0)
						#var uv_c = uv_offset + Vector2(0, height)
						#var uv_b = uv_offset + Vector2(width, height)
						#var uv_a = uv_offset + Vector2(width, 0)
						
						var uv_a = Vector2(0,-greed_z-1)
						var uv_b = Vector2.ZERO
						var uv_c = Vector2(-greed_x-1,0)
						var uv_d = Vector2(-greed_x-1,-greed_z-1)
						
						var col = Color(float(block_data[type][DOWN])*0.01,block_data[type]["roughness"],block_data[type]["metallic"],0.0)
						
						st.add_triangle_fan(([a, b, c]), ([uv_a, uv_b, uv_c]), ([col,col,col]))
						st.add_triangle_fan(([a, c, d]), ([uv_a, uv_c, uv_d]), ([col,col,col]))
				z += 1
			z = 0
			y += 1
		y = 0
		x += 1
	#if (z + 1 >= world_size.z) or (block_data[blocks[x][y][z+1]]["transparent"]):
	st.generate_normals(false)
	st.generate_tangents()
	var m = st.commit()
	mi.mesh = m
	mi.set_surface_override_material(0,material)
	add_child(mi,true)
	
	var col = StaticBody3D.new()
	add_child(col,true)
	var shape = CollisionShape3D.new()  #mi.mesh.create_trimesh_shape()
	shape.shape = mi.mesh.create_trimesh_shape()
	col.add_child(shape,true)
	mi.owner = self
	col.owner = self
	shape.owner = self


func block_safe(x,y,z) -> bool:
	return (((x+1 >= world_size.x or x > 0) or (y+1 >= world_size.y or y < 0)) or (z+1 >= world_size.z or z < 0))


func create_block(id, coords):
	var TU = true
	var TD = true
	var TN = true
	var TS = true
	var TE = true
	var TW = true
	if !(coords.y + 1 >= world_size.y):
		TU = block_data[blocks[coords.x][coords.y+1][coords.z]]["transparent"]
	if !(coords.y - 1 < 0):
		TD = block_data[blocks[coords.x][coords.y-1][coords.z]]["transparent"]
	if !(coords.x + 1 >= world_size.x):
		TE = block_data[blocks[coords.x+1][coords.y][coords.z]]["transparent"]
	if !(coords.x - 1 < 0):
		TW = block_data[blocks[coords.x-1][coords.y][coords.z]]["transparent"]
	if !(coords.z + 1 >= world_size.z):
		TN = block_data[blocks[coords.x][coords.y][coords.z+1]]["transparent"]
	if !(coords.z - 1 < 0):
		TS = block_data[blocks[coords.x][coords.y][coords.z-1]]["transparent"]
	if TU:
		create_face(UP, coords, block_data[id][UP])
	if TD:
		create_face(DOWN, coords, block_data[id][DOWN])
	if TN:
		create_face(NORTH, coords, block_data[id][NORTH])
	if TS:
		create_face(SOUTH, coords, block_data[id][SOUTH])
	if TE:
		create_face(EAST, coords, block_data[id][EAST])
	if TW:
		create_face(WEST, coords, block_data[id][WEST])


const vertices = [
	Vector3(0,0,0), #0
	Vector3(1,0,0), #1
	Vector3(0,1,0), #2
	Vector3(1,1,0), #3
	Vector3(0,0,1), #4
	Vector3(1,0,1), #5
	Vector3(0,1,1), #6
	Vector3(1,1,1), #7
]

const UP = [2, 3, 7, 6]
const DOWN = [0, 4, 5, 1]
const WEST = [6, 4, 0, 2]
const EAST = [3, 1, 5, 7]
const NORTH = [7, 5, 4, 6]
const SOUTH = [2, 0, 1, 3]

const atlas_size = Vector2(3,3)

func create_face(i, coords, texture_atlas_offset):
	var a = (vertices[i[0]] + coords)*unit_scale
	var b = (vertices[i[1]] + coords)*unit_scale
	var c = (vertices[i[2]] + coords)*unit_scale
	var d = (vertices[i[3]] + coords)*unit_scale
	
	var uv_offset = Vector2.ZERO / atlas_size
	
	var height = 1.0 / atlas_size.y
	var width = 1.0 / atlas_size.x
	
	var uv_a = uv_offset + Vector2(0, 0)
	var uv_b = uv_offset + Vector2(0, height)
	var uv_c = uv_offset + Vector2(width, height)
	var uv_d = uv_offset + Vector2(width, 0)
	
	
	st.add_triangle_fan(([a, b, c]), ([uv_a, uv_b, uv_c]))
	st.add_triangle_fan(([a, c, d]), ([uv_a, uv_c, uv_d]))

func final_build():
	for c in get_children(false):
		c.queue_free()
	await get_tree().process_frame
	#resize_blocks()
	#await get_tree().process_frame
	#generate_world()
	#await get_tree().process_frame
	#create_mesh()
	create_greedy_mesh()
	await get_tree().process_frame
	add_effects()
	await get_tree().process_frame
	if !Engine.is_editor_hint():
		save_level()
		await get_tree().process_frame
		print("done")
		#var c_b = load("res://tools/creative_builder.tscn").instantiate()
		#add_child(c_b)
		#c_b.connect("final_build", save_and_close)
		get_tree().quit(0)

func save_and_close():
	save_level()
	await get_tree().process_frame
	get_tree().quit(0)
	pass


func quick_build():
	for c in get_children(false):
		c.queue_free()
	await get_tree().process_frame
	resize_blocks()
	await get_tree().process_frame
	generate_world()
	await get_tree().process_frame
	create_mesh()
	await get_tree().process_frame
	if !Engine.is_editor_hint():
		var c_b = load("res://tools/creative_builder.tscn").instantiate()
		add_child(c_b)
		c_b.connect("place",place_block)
		c_b.connect("final_build", final_build)

func fast_update():
	for i in graphics_paths:
		i.queue_free()
	graphics_paths = []
	create_mesh()

func save_level():
	#var l = self.duplicate(true)
	#l.set_script(load("res://scripts/world_level.gd"))
	#add_child(l,true)
	#for ch in l.get_children(false):
		#ch.owner = l
		#for c in ch.get_children(false):
			#c.owner = ch
	var l = Node3D.new()
	for i in get_children():
		i.reparent(l)
		i.owner = l
		for c in i.get_children():
			c.owner = l
	l.name = level_name
	#l.blocks = blocks
	var scene = PackedScene.new()
	scene.pack(l)
	ResourceSaver.save(scene, (level_path + level_name + ".tscn"))
	pass

func place_block(x,y,z,type) -> void:
	if x >= world_size.x or x < 0:
		return
	if y >= world_size.y or y < 0:
		return
	if z >= world_size.z or z < 0:
		return
	blocks[x][y][z] = type
	fast_update()
	
	pass
