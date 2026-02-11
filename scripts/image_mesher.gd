@tool
extends Node3D
var unit_scale: Vector3 = Vector3(0.02,0.02,0.02)
var material = load("res://assets/materials/item_effects_mat.tres") #StandardMaterial3D.new()

func _ready():
	for i in $model.get_children(false):
		i.queue_free()
	resize_blocks()
	settup_world()
	create_greedy_mesh()

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

enum {
	air,
	opaque,
	
}

var st = SurfaceTool.new()
var world_size = Vector3i(16,16,5)
var blocks = []



const block_data = {
	air : {
		"transparent" : true,
		"fertile" : false
	},
	opaque : {
		"transparent" : false,
		UP : 3,
		DOWN : 4,
		NORTH : 4,
		SOUTH : 4,
		EAST : 4,
		WEST : 4,
		"roughness" : 0.0,
		"metallic" : 0.0,
		"fertile" : false
	},
}

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

var image_path = "res://assets/textures/items/3dBase/boneSword.png"
var pixel_size = (1.0/16.0)

func settup_world():
	var im = Image.load_from_file(image_path)
	var data = im.get_data()
	var size = data.size() - 1
	var i = 3
	material = material.duplicate()
	#material.albedo_texture = load(image_path)
	material.set("shader_parameter/texture_albedo",load(image_path))
	#material.set("shading_mode",0)
	#material.set("texture_repeat",false)
	for x in range(0,world_size.x):
		for y in range(0,world_size.y):
			if i > size:
				return
			var val = float(data[i])/255.0
			if val > 0.5:
				blocks[y][x][2] = opaque
				#if data[i-3] < 128:
					#blocks[y][x][1] = opaque
					#blocks[y][x][3] = opaque
				#if data[i-3] < 40:
					#blocks[y][x][0] = opaque
					#blocks[y][x][4] = opaque
			#if data[i] == 255: #no floating point errors :D
				#blocks[y][x][0] = opaque
				#blocks[y][x][1] = opaque
				#blocks[y][x][2] = opaque
				#blocks[y][x][3] = opaque
				#blocks[y][x][4] = opaque
			#if val > 0.75: #transparency varies thickness
				#blocks[y][x][1] = opaque
				#blocks[y][x][2] = opaque
				#blocks[y][x][3] = opaque
			#elif val > 0.25:
				#blocks[y][x][2] = opaque
			#else dont draw
			i += 4
	#blocks[0][0][0] = air
	#blocks[1][0][0] = air
	#blocks[1][2][0] = air
	#blocks[30][30][0] = air


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
						
						var uv_a = (Vector2(0,greed_y+1)+Vector2(x,y))*pixel_size
						var uv_b = (Vector2.ZERO+Vector2(x,y))*pixel_size
						var uv_c = (Vector2(greed_x+1,0)+Vector2(x,y))*pixel_size
						var uv_d = (Vector2(greed_x+1,greed_y+1)+Vector2(x,y))*pixel_size
						
						#var uv_d = (Vector2(greed_x,0.0)/Vector2(world_size.x,world_size.y))  #Vector2(1.0,0.0)
						#var uv_c = (Vector2(greed_x,greed_y)/Vector2(world_size.x,world_size.y)) #Vector2(1.0,1.0)
						#var uv_b = (Vector2(0,greed_y)/Vector2(world_size.x,world_size.y))#Vector2(0.0,1.0)
						#var uv_a = (Vector2.ZERO)
						
						#var uv_d = Vector2(pixel_size,0.0) + Vector2(x,y)*pixel_size + Vector2(greed_x,0.0)*pixel_size
						#var uv_c = Vector2(pixel_size,pixel_size) + Vector2(x,y)*pixel_size + Vector2(greed_x,greed_y)*pixel_size
						#var uv_b = Vector2(0.0,pixel_size) + Vector2(x,y)*pixel_size + Vector2(0.0,greed_y)*pixel_size
						#var uv_a = Vector2.ZERO + Vector2(x,y)*pixel_size
						
						#Color(float(block_data[type][NORTH])*0.01,block_data[type]["roughness"],block_data[type]["metallic"],0.0)
						var col = Color.WHITE
						var norm = Vector3.BACK
						
						st.add_triangle_fan(([a, b, c]), ([uv_a, uv_b, uv_c]), ([col,col,col]),([uv_a,uv_b,uv_c]),([norm,norm,norm]))
						st.add_triangle_fan(([a, c, d]), ([uv_a, uv_c, uv_d]), ([col,col,col]),[uv_a, uv_c, uv_d],([norm,norm,norm]))
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
						
						var uv_a = (Vector2(0,greed_y+1)+Vector2(x,y))*pixel_size#/Vector2(world_size.x,world_size.y)
						var uv_b = (Vector2.ZERO+Vector2(x,y))*pixel_size#/Vector2(world_size.x,world_size.y)
						var uv_c = (Vector2(greed_x+1,0)+Vector2(x,y))*pixel_size#/Vector2(world_size.x,world_size.y)
						var uv_d = (Vector2(greed_x+1,greed_y+1)+Vector2(x,y))*pixel_size#/Vector2(world_size.x,world_size.y)
						
						#var col = Color(float(block_data[type][SOUTH])*0.01,block_data[type]["roughness"],block_data[type]["metallic"],0.0)
						var col = Color.WHITE
						var norm = Vector3.FORWARD
						
						st.add_triangle_fan(([a, b, c]), ([uv_a, uv_b, uv_c]), ([col,col,col]),([uv_a,uv_b,uv_c]),([norm,norm,norm]))
						st.add_triangle_fan(([a, c, d]), ([uv_a, uv_c, uv_d]), ([col,col,col]),[uv_a, uv_c, uv_d],([norm,norm,norm]))
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
						var uv_a = (Vector2(x,y)+Vector2(0,1+greed_y))*pixel_size#(Vector2(0,greed_y+1)+Vector2(x,y))*pixel_size#
						var uv_b = (Vector2(x,y)+Vector2(0,0))*pixel_size#(Vector2.ZERO+Vector2(x,y))*pixel_size#
						var uv_c = (Vector2(x,y)+Vector2(1,0))*pixel_size#(Vector2(greed_z+1,0)+Vector2(x,y))*pixel_size#
						var uv_d = (Vector2(x,y)+Vector2(1,1+greed_y))*pixel_size#(Vector2(greed_z+1,-greed_y+1)+Vector2(x,y))*pixel_size#
						
						#var col = Color(float(block_data[type][EAST])*0.01,block_data[type]["roughness"],block_data[type]["metallic"],0.0)
						
						var col = Color.WHITE
						var norm = Vector3.RIGHT
						
						st.add_triangle_fan(([a, b, c]), ([uv_a, uv_b, uv_c]), ([col,col,col]),([uv_a,uv_b,uv_c]),([norm,norm,norm]))
						st.add_triangle_fan(([a, c, d]), ([uv_a, uv_c, uv_d]), ([col,col,col]),[uv_a, uv_c, uv_d],([norm,norm,norm]))
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
						
						var uv_a = (Vector2(0,greed_y+1)+Vector2(x,y))*pixel_size#
						var uv_b = (Vector2.ZERO+Vector2(x,y))*pixel_size#
						var uv_c = (Vector2(1,0)+Vector2(x,y))*pixel_size#
						var uv_d = (Vector2(1,greed_y+1)+Vector2(x,y))*pixel_size#
						
						#var col = Color(float(block_data[type][WEST])*0.01,block_data[type]["roughness"],block_data[type]["metallic"],0.0)
						
						var col = Color.WHITE
						var norm = Vector3.LEFT
						
						st.add_triangle_fan(([a, b, c]), ([uv_a, uv_b, uv_c]), ([col,col,col]),([uv_a,uv_b,uv_c]),([norm,norm,norm]))
						st.add_triangle_fan(([a, c, d]), ([uv_a, uv_c, uv_d]), ([col,col,col]),[uv_a, uv_c, uv_d],([norm,norm,norm]))
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
						
						var uv_a = (Vector2(0,greed_x+1)+Vector2(x,y))*pixel_size#
						var uv_b = (Vector2.ZERO+Vector2(x,y))*pixel_size#
						var uv_c = (Vector2(1,0)+Vector2(x,y))*pixel_size#
						var uv_d = (Vector2(1,greed_x+1)+Vector2(x,y))*pixel_size#
						
						#var col = Color(float(block_data[type][UP])*0.01,block_data[type]["roughness"],block_data[type]["metallic"],0.0)
						
						var col = Color.WHITE
						var norm = Vector3.UP
						
						st.add_triangle_fan(([a, b, c]), ([uv_a, uv_b, uv_c]), ([col,col,col]),([uv_a,uv_b,uv_c]),([norm,norm,norm]))
						st.add_triangle_fan(([a, c, d]), ([uv_a, uv_c, uv_d]), ([col,col,col]),[uv_a, uv_c, uv_d],([norm,norm,norm]))
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
						
						var uv_a = (Vector2(0,1)+Vector2(x,y))*pixel_size#
						var uv_b = (Vector2.ZERO+Vector2(x,y))*pixel_size#
						var uv_c = (Vector2(greed_x+1,0)+Vector2(x,y))*pixel_size#
						var uv_d = (Vector2(greed_x+1,1)+Vector2(x,y))*pixel_size#
						
						#var col = Color(float(block_data[type][DOWN])*0.01,block_data[type]["roughness"],block_data[type]["metallic"],0.0)
						
						var col = Color.WHITE
						var norm = Vector3.DOWN
						
						st.add_triangle_fan(([a, b, c]), ([uv_a, uv_b, uv_c]), ([col,col,col]),([uv_a,uv_b,uv_c]),([norm,norm,norm]))
						st.add_triangle_fan(([a, c, d]), ([uv_a, uv_c, uv_d]), ([col,col,col]),[uv_a, uv_c, uv_d],([norm,norm,norm]))
				z += 1
			z = 0
			y += 1
		y = 0
		x += 1
	#if (z + 1 >= world_size.z) or (block_data[blocks[x][y][z+1]]["transparent"]):
	#st.generate_normals(false)
	#st.generate_tangents()
	var m = st.commit()
	m.regen_normal_maps()
	mi.mesh = m
	mi.set_surface_override_material(0,material)
	$model.add_child(mi,true)
	
	#var col = StaticBody3D.new()
	#$model.add_child(col,true)
	#var shape = CollisionShape3D.new()  #mi.mesh.create_trimesh_shape()
	#shape.shape = mi.mesh.create_trimesh_shape()
	#$model.col.add_child(shape,true)
	mi.owner = self
	#col.owner = self
	#shape.owner = self








