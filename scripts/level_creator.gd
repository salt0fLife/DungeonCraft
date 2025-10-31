extends Node3D

@export var world_size = Vector3i(5,5,10)
var blocks = []

func _ready():
	resize_blocks()
	generate_world()
	print(blocks)
	print(blocks.size())
	print(blocks[0].size())
	print(blocks[0][0].size())
	create_mesh()
	pass

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
	var x = 0
	var y = 0
	var z = 0
	blocks[x][y][z] = 1
	blocks[x][y][z+1] = 1

const unit_scale = 0.25

enum directions {
	up,down,north,south,east,west
}

enum b_id {
	air,
	brick
}

var st = SurfaceTool.new()
func create_mesh():
	var mi = MeshInstance3D.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for x in range(0,blocks.size()):
		for y in range(0,blocks[x].size()):
			for z in range(0,blocks[x][y].size()):
				var type = blocks[x][y][z]
				match type:
					b_id.air:
						#dont do anything :3
						pass
					b_id.brick:
						#create block
						create_block(b_id.brick, Vector3(x,y,z))
						pass
	var m = st.commit()
	mi.mesh = m
	add_child(mi)

func create_block(id, coords):
	#print("created block " + str(id) + " " + str(coords))
	create_face(directions.up, coords, id)
	create_face(directions.down, coords, id)
	create_face(directions.north, coords, id)
	create_face(directions.south, coords, id)
	create_face(directions.east, coords, id)
	create_face(directions.west, coords, id)

func create_face(tag, coords, id):
	match tag:
		directions.up:
			print("created up face at " + str(coords))
			#(0,1,0), (1,1,0), (0,1,1)
			#(1,1,1), (1,1,0), (0,1,1)
			st.add_vertex(Vector3(coords.x*unit_scale, (1.0+coords.y)*unit_scale, coords.z*unit_scale))
			st.add_vertex(Vector3((coords.x+1.0)*unit_scale, (1.0+coords.y)*unit_scale, coords.z*unit_scale))
			st.add_vertex(Vector3(coords.x*unit_scale, (1.0+coords.y)*unit_scale, (coords.z+1.0)*unit_scale))
			
			st.add_vertex(Vector3((coords.x+1.0)*unit_scale, (1.0+coords.y)*unit_scale, coords.z*unit_scale))
			st.add_vertex(Vector3((coords.x+1.0)*unit_scale, (1.0+coords.y)*unit_scale, (coords.z+1.0)*unit_scale))
			st.add_vertex(Vector3(coords.x*unit_scale, (1.0+coords.y)*unit_scale, (coords.z+1.0)*unit_scale))
			pass
		directions.down:
			
			pass
		directions.north:
			
			pass
		directions.south:
			
			pass
		directions.east:
			
			pass
		directions.west:
			
			pass
	pass

