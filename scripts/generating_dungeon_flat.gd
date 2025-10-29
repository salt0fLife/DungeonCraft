extends Node3D
@onready var hallways1 = [
	preload("res://debug/generation/hallway_debug.tscn")
]

@onready var rooms_scenes = [
	preload("res://debug/generation/room_1_debug.tscn"),
	preload("res://debug/generation/room_2_debug.tscn")
]
 
var world_dimensions = Vector3(20.0,20.0, 40.0)
var number_of_rooms = 50
var rooms = [Vector3(6.0,3.0,6.0), Vector3(4.0,2.0, 2.0)]
var room_doors = [[Vector3(3.0,0.0, -1.0), Vector3(-1.0,0.0,3.0), Vector3(6.0,0.0,3.0), Vector3(3.0,0.0,6.0)],
[Vector3(0.0,0.0,-1.0), Vector3(3.0,0.0,2.0)]
]
var ocupado = []
var room_buffer = 1.0
var active_doors = []
var scaling = 1.0

func _ready():
	generate(109810359814)

func generate(seed):
	var s = seed
	var world = []
	#place_rooms
	for i in range(0, number_of_rooms):
		var room_id = rand_from_seed(seed+i)[0]
		room_id = int(room_id%rooms.size())
		#print(room_id)
		var x = rand_from_seed(seed+i)[0]%int(world_dimensions.x)
		var y = rand_from_seed(seed+i+1)[0]%int(world_dimensions.y)
		var z = rand_from_seed(seed+i+2)[0]%int(world_dimensions.z)
		var pos = Vector3(x,y,z)
		var room = rooms[room_id]
		var safe = true
		for rect in ocupado:
			##check1
			if check_overlap(pos, room, rect[0], rect[1]):
				safe = false
		if safe:
			ocupado += [[pos, rooms[room_id]]]
			world += [[room_id, pos, i]]
	#print(world)
	populate_world(world)
	#110983759814 makes #13132

func check_overlap(pos1,size1,pos2,size2, buffer = 0.0):
	#x overlap
	var xOverlap = (pos1.x+buffer >= pos2.x and pos1.x-buffer <= pos2.x+size2.x) or (pos1.x+size1.x+buffer >= pos2.x and pos1.x+size1.x-buffer <= pos2.x+size2.x) or (pos1.x-buffer <= pos2.x and pos1.x+size1.x+buffer >= pos2.x+size2.x)
	var yOverlap = (pos1.y+buffer >= pos2.y and pos1.y-buffer <= pos2.y+size2.y) or (pos1.y+size1.y+buffer >= pos2.y and pos1.y+size1.y-buffer <= pos2.y+size2.y) or (pos1.y-buffer <= pos2.y and pos1.y+size1.y+buffer >= pos2.y+size2.y)
	var zOverlap = (pos1.z+buffer >= pos2.z and pos1.z-buffer <= pos2.z+size2.z) or (pos1.z+size1.z+buffer >= pos2.z and pos1.z+size1.z-buffer <= pos2.z+size2.z) or (pos1.z-buffer <= pos2.z and pos1.z+size1.z+buffer >= pos2.z+size2.z)
	return (xOverlap and yOverlap and zOverlap)

func populate_world(world):
	var hallway = []
	for x in range(0, world_dimensions.x):
		hallway.append([])
		for y in range(0, world_dimensions.y):
			hallway[x].append([])
			for z in range(0, world_dimensions.z):
				hallway[x][y].append(0)
	#var backdrop = ColorRect.new()
	#backdrop.color = Color.BLUE
	#backdrop.size = world_dimensions * display_scale
	#$background.add_child(backdrop)
	for e in world:
		#room.text = "id:"+str(e[0])+" index:"+str(e[2])
		#room.position = e[1]
		var r = rooms_scenes[e[0]].instantiate()
		r.position.x = e[1].x * scaling
		r.position.y = e[1].y * scaling
		r.position.z = e[1].z * scaling
		r.scale = Vector3(scaling,scaling,scaling)
		$mesher.add_child(r)
		
		##handle hallways
		#[room_id, pos, i]
		var doors = room_doors[e[0]]
		for d in doors:
			var dPos = d + e[1]
			var coordx = clamp(int(dPos.x), -1, world_dimensions.x)
			var coordy = clamp(int(dPos.y), -1, world_dimensions.y)
			var coordz = clamp(int(dPos.z), -1, world_dimensions.z)
			if coordx > -1 and coordx < world_dimensions.x and coordy > -1 and coordy < world_dimensions.y and coordz > -1 and coordz < world_dimensions.z:
				hallway[coordx][coordy][coordz] = 1
				active_doors += [Vector3i(coordx, coordy, coordz)]
	for di in range(0,active_doors.size()):
		var d = active_doors[di]
		var ti = di + 3
		if ti > active_doors.size()-1:
			ti -= int(active_doors.size()-1)
		var t = active_doors[ti]
		
		var steps = abs((d.x - t.x)) + abs((d.y - t.y)) + abs((d.z-t.z)) + 5
		var current_pos = d
		for s in steps:
			hallway[current_pos.x][current_pos.y][current_pos.z] = di
			var dir = (t - current_pos)
			var desired_move = Vector3i.ZERO
			var secondary_move = Vector3i.ZERO
			if s%2 != 0:
				if abs(dir.x) > abs(dir.y) and s%9!=0:
					if abs(dir.x) > abs(dir.z):
						desired_move.x = sign(dir.x)*1.0
						secondary_move.z = sign(dir.z)*1.0
					else:
						desired_move.z = sign(dir.z)*1.0
						secondary_move.x = sign(dir.x)*1.0
				else:
					if abs(dir.y) > abs(dir.z):
						desired_move.y = sign(dir.y)*1.0
						secondary_move.z = sign(dir.z)*1.0
					else:
						desired_move.z = sign(dir.z)*1.0
						secondary_move.y = sign(dir.y)*1.0
			else:
				if abs(dir.z) > abs(dir.x) and s%8!=0:
					if abs(dir.z) > abs(dir.y):
						desired_move.z = sign(dir.z)*1.0
						secondary_move.y = sign(dir.y)*1.0
					else:
						desired_move.y = sign(dir.y)*1.0
						secondary_move.z = sign(dir.z)*1.0
				else:
					if abs(dir.x) > abs(dir.y):
						desired_move.x = sign(dir.x)*1.0
						secondary_move.y = sign(dir.y)*1.0
					else:
						desired_move.y = sign(dir.y)*1.0
						secondary_move.x = sign(dir.x)*1.0
			if check_safe(current_pos + desired_move, Vector3(1.0,1.0,1.0), -1.0):
				current_pos += desired_move
			else:
				current_pos += secondary_move
	#draw hallway
	for x in range(0,hallway.size()):
		for y in range(0,hallway[x].size()):
			#print("hallway[x][y] = " + str(hallway[x][y]))
			for z in range(0, hallway[x][y].size()):
				if hallway[x][y][z] != 0:
					var b = hallways1[0].instantiate()
					b.position.x = x * scaling
					b.position.y = y * scaling
					b.position.z = z * scaling
					b.scale = Vector3(scaling,scaling,scaling)
					#var block = ColorRect.new()
					#block.position = Vector2(x, y)
					var col = colors[int(rand_from_seed(hallway[x][y][z])[0]%colors.size())]
					#block.color = col#Color.ALICE_BLUE#Color(randf(),randf(),randf(),1.0)
					$mesher.add_child(b)
	#print(active_doors)
	
	
	
func check_safe(pos, size, buffer):
	for r in ocupado:
		if check_overlap(pos, size, r[0], r[1], buffer):
			return false
	return true
const colors = [Color.RED, Color.BLUE, Color.GREEN, Color.YELLOW, Color.PURPLE]









