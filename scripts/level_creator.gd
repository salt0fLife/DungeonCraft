@tool
extends Node3D

var world_size = Vector3i(16,16,16)
var blocks = []
var level_name = "level_1_test"
var level_path = "res://world/levels/"

func _ready():
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
					blocks[x][y][z] = grass
				elif y > 10:
					blocks[x][y][z] = metal
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
	
	blocks[15][10][1] = grass

const unit_scale = 0.5

enum directions {
	up,down,north,south,east,west
}

#block types
enum {
	air,
	brick,
	grass,
	metal
}

const block_data = {
	air : {
		"transparent" : true
	},
	brick : {
		"transparent" : false,
		"up" : Vector2(0,0),
		"down" : Vector2(1,1),
		"north" : Vector2(1,0),
		"south" : Vector2(1,0),
		"east" : Vector2(2,0),
		"west" : Vector2(0,1)
	},
	grass : {
		"transparent" : false,
		"up" : Vector2(2,1),
		"down" : Vector2(1,2),
		"north" : Vector2(0,2),
		"south" : Vector2(0,2),
		"east" : Vector2(0,2),
		"west" : Vector2(0,2)
	},
	metal : {
		"transparent" : false,
		"up" : Vector2(2,2),
		"down" : Vector2(2,2),
		"north" : Vector2(2,2),
		"south" : Vector2(2,2),
		"east" : Vector2(2,2),
		"west" : Vector2(2,2)
	},
}

var st = SurfaceTool.new()
var material = load("res://assets/materials/worldMat.tres")
func create_mesh():
	var mi = MeshInstance3D.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for x in range(0,blocks.size()):
		for y in range(0,blocks[x].size()):
			for z in range(0,blocks[x][y].size()):
				var type = blocks[x][y][z]
				if type != air:
					create_block(type, Vector3(x,y,z))
	var m = st.commit()
	mi.mesh = m
	mi.set_surface_override_material(0,material)
	add_child(mi,true)
	
	var col = StaticBody3D.new()
	add_child(col,true)
	var shape = CollisionShape3D.new()  #mi.mesh.create_trimesh_shape()
	shape.shape = mi.mesh.create_trimesh_shape()
	col.add_child(shape,true)
	mi.owner = get_tree().edited_scene_root
	col.owner = get_tree().edited_scene_root
	shape.owner = get_tree().edited_scene_root


var meshed = {
	NORTH : [],
	SOUTH : [],
	EAST : [],
	WEST : [],
	UP: [],
	DOWN: [],
}


func create_greedy_mesh():
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
							if ! y_greed_dead:
								for cgx in range(0,greed_x+1):
									meshed[NORTH] += [Vector3i(x+cgx,y+greed_y+1,z)]
									pass
								greed_y += 1
						
						
						var a = (vertices[NORTH[0]] + coords + Vector3(greed_x,greed_y,0))*unit_scale
						var b = (vertices[NORTH[1]] + coords + Vector3(greed_x,0,0))*unit_scale
						var c = (vertices[NORTH[2]] + coords)*unit_scale
						var d = (vertices[NORTH[3]] + coords + Vector3(0,greed_y,0))*unit_scale
						
						var uv_offset = block_data[type]["north"] / atlas_size
						
						var height = 1.0 / atlas_size.y
						var width = 1.0 / atlas_size.x
						
						var uv_a = uv_offset + Vector2(0, 0)
						var uv_b = uv_offset + Vector2(0, height)
						var uv_c = uv_offset + Vector2(width, height)
						var uv_d = uv_offset + Vector2(width, 0)
						
						
						st.add_triangle_fan(([a, b, c]), ([uv_a, uv_b, uv_c]))
						st.add_triangle_fan(([a, c, d]), ([uv_a, uv_c, uv_d]))
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
					if !(coords.z - 1 < 0):
						TS = block_data[blocks[coords.x][coords.y][coords.z-1]]["transparent"]
					if TU:
						create_face(UP, coords, block_data[type]["up"])
					if TD:
						create_face(DOWN, coords, block_data[type]["down"])
					if TS:
						create_face(SOUTH, coords, block_data[type]["south"])
					if TE:
						create_face(EAST, coords, block_data[type]["east"])
					if TW:
						create_face(WEST, coords, block_data[type]["west"])
				z += 1
			z = 0
			y += 1
		y = 0
		x += 1
	#if (z + 1 >= world_size.z) or (block_data[blocks[x][y][z+1]]["transparent"]):
	var m = st.commit()
	mi.mesh = m
	mi.set_surface_override_material(0,material)
	add_child(mi,true)

#func mesh_side_from_block(x,y,z,dir_en,dir_str):
	#
	#var check_dir = Vector3.ZERO
	#
	#match dir_en:
		#NORTH:check_dir = Vector3(0,0,1)
		#SOUTH:check_dir = Vector3(0,0,-1)
		#EAST:check_dir = Vector3(1,0,0)
		#WEST:check_dir = Vector3(-1,0,0)
		#UP:check_dir = Vector3(0,1,0)
		#DOWN:check_dir = Vector3(0,-1,0)
	#
	#
	#var type = blocks[x][y][z]
	#var check_x = x+check_dir.x
	#var check_y = y+check_dir.y
	#var check_z = z+check_dir.z
	#if type != air:
		#var coords = Vector3(x,y,z)
		##north
		#if block_safe(check_x,check_y,check_z) and !meshed[dir_en].has(Vector3i(x,y,z)):
			#var greed_x = 0
			#while (x + greed_x + 1) < world_size.x and blocks[x+greed_x + 1][y][z] == type and ((z + 1 >= world_size.z) or block_data[blocks[x+greed_x + 1][y][z+1]]["transparent"]):
				#greed_x += 1
				#meshed[dir_en] += [Vector3i(x+greed_x,y,z)]
			#
			#var greed_y = 0
			#var y_greed_dead = false
			#while !y_greed_dead and (y + greed_y + 1 < world_size.y):
				#for gx in range(0,greed_x+1):
					#if !blocks[x+gx][y+greed_y+1][z] == type:
						#y_greed_dead = true
					#elif !(block_safe(check_x,check_y,check_z) or (block_data[blocks[x+gx][y+greed_y+1][z+1]]["transparent"])):
						#y_greed_dead = true
				#if ! y_greed_dead:
					#for cgx in range(0,greed_x+1):
						#meshed[dir_en] += [Vector3i(x+cgx,y+greed_y+1,z)]
						#pass
					#greed_y += 1
			#
			#
			#var a = (vertices[dir_en[0]] + coords + Vector3(greed_x,greed_y,0))*unit_scale
			#var b = (vertices[dir_en[1]] + coords + Vector3(greed_x,0,0))*unit_scale
			#var c = (vertices[dir_en[2]] + coords)*unit_scale
			#var d = (vertices[dir_en[3]] + coords + Vector3(0,greed_y,0))*unit_scale
			#
			#var uv_offset = block_data[type][dir_str] / atlas_size
			#
			#var height = 1.0 / atlas_size.y
			#var width = 1.0 / atlas_size.x
			#
			#var uv_a = uv_offset + Vector2(0, 0)
			#var uv_b = uv_offset + Vector2(0, height)
			#var uv_c = uv_offset + Vector2(width, height)
			#var uv_d = uv_offset + Vector2(width, 0)
			#
			#
			#st.add_triangle_fan(([a, b, c]), ([uv_a, uv_b, uv_c]))
			#st.add_triangle_fan(([a, c, d]), ([uv_a, uv_c, uv_d]))

func block_safe(x,y,z) -> bool:
	return x >= world_size.x or x > 0 or y >= world_size.y or y < 0 or z >= world_size.z or z < 0


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
		create_face(UP, coords, block_data[id]["up"])
	if TD:
		create_face(DOWN, coords, block_data[id]["down"])
	if TN:
		create_face(NORTH, coords, block_data[id]["north"])
	if TS:
		create_face(SOUTH, coords, block_data[id]["south"])
	if TE:
		create_face(EAST, coords, block_data[id]["east"])
	if TW:
		create_face(WEST, coords, block_data[id]["west"])


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
	
	var uv_offset = texture_atlas_offset / atlas_size
	
	var height = 1.0 / atlas_size.y
	var width = 1.0 / atlas_size.x
	
	var uv_a = uv_offset + Vector2(0, 0)
	var uv_b = uv_offset + Vector2(0, height)
	var uv_c = uv_offset + Vector2(width, height)
	var uv_d = uv_offset + Vector2(width, 0)
	
	
	st.add_triangle_fan(([a, b, c]), ([uv_a, uv_b, uv_c]))
	st.add_triangle_fan(([a, c, d]), ([uv_a, uv_c, uv_d]))

func quick_build():
	for c in get_children(false):
		c.queue_free()
	resize_blocks()
	generate_world()
	#create_mesh()
	create_greedy_mesh()
	if !Engine.is_editor_hint():
		save_level()
		get_tree().quit(0)

func save_level():
	var l = self.duplicate()
	l.name = level_name
	l.set_script(load("res://scripts/world_level.gd"))
	#l.blocks = blocks
	var scene = PackedScene.new()
	scene.pack(l)
	ResourceSaver.save(scene, (level_path + level_name + ".tscn"))
	pass
