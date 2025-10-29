extends Node3D


var world_dimensions = Vector2(100.0,100.0)
var number_of_rooms = 50
var rooms = [Vector2(5.0,5.0), Vector2(1.0,3.0), Vector2(4.0,2.0), Vector2(7.0,2.0)]
var room_doors = [[Vector2(0.0,5.0), Vector2(-1.0,2.0), Vector2(2.0,-1.0)], [Vector2(1.0,1.0),Vector2(0.0,-1.0)], [Vector2(3.0,2.0), Vector2(1.0,-1.0)], [Vector2(6.0,-1.0),Vector2(1.0, 2.0)]]
var ocupado = []
var room_buffer = 1.0
var active_doors = []
var display_scale = Vector2(10.0,10.0)

func _ready():
	generate(10981359814)

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
		var pos = Vector2(x,y)
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
	return (xOverlap and yOverlap)

func populate_world(world):
	var hallway = []
	for y in range(0, world_dimensions.y):
		hallway.append([])
		for x in range(0, world_dimensions.x):
			hallway[y].append(0)
	var backdrop = ColorRect.new()
	backdrop.color = Color.BLUE
	backdrop.size = world_dimensions * display_scale
	$background.add_child(backdrop)
	for e in world:
		var room_backdrop = ColorRect.new()
		var room = Label.new()
		room.text = "id:"+str(e[0])+" index:"+str(e[2])
		room.position = e[1] * display_scale
		room_backdrop.position = e[1] * display_scale
		room_backdrop.size = rooms[e[0]]*display_scale
		#print(str(rooms[e[0]]) +" "+ str(e[0])+" "+str(e[2]))
		room_backdrop.color = Color(randf(),randf(),randf(),0.8)#Color.RED
		$rooms.add_child(room_backdrop)
		$rooms.add_child(room)
		
		##handle hallways
		#[room_id, pos, i]
		var doors = room_doors[e[0]]
		for d in doors:
			var dPos = d + e[1]
			var coordx = clamp(int(dPos.x), -1, world_dimensions.x)
			var coordy = clamp(int(dPos.y), -1, world_dimensions.y)
			if coordx > -1 and coordx < world_dimensions.x and coordy > -1 and coordy < world_dimensions.y:
				hallway[coordx][coordy] = 1
				active_doors += [Vector2i(coordx, coordy)]
	for di in range(0,active_doors.size()):
		var d = active_doors[di]
		var ti = di + 3
		if ti > active_doors.size()-1:
			ti -= int(active_doors.size()-1)
		var t = active_doors[ti]
		
		var steps = abs((d - t).x) + abs((d - t).y) + 10
		var current_pos = d
		for s in steps:
			hallway[current_pos.x][current_pos.y] = di
			var dir = (t - current_pos)
			var desired_move = Vector2i.ZERO
			var secondary_move = Vector2i.ZERO
			if s%8 != 0:
				if abs(dir.x) > abs(dir.y):# and s%9!=0:
					desired_move.x = sign(dir.x)*1.0
					secondary_move.y = sign(dir.y)*1.0
				else:
					desired_move.y = sign(dir.y)*1.0
					secondary_move.x = sign(dir.x)*1.0
			else:
				if abs(dir.y) > abs(dir.x):# and s%8!=0:
					desired_move.y = sign(dir.y)*1.0
					secondary_move.x = sign(dir.x)*1.0
				else:
					desired_move.x = sign(dir.x)*1.0
					secondary_move.y = sign(dir.y)*1.0
			if check_safe(current_pos + desired_move, Vector2(1.0,1.0), -1.0):
				current_pos += desired_move
			else:
				current_pos += secondary_move
	#draw hallway
	for x in range(0,hallway.size()):
		for y in range(0,hallway[x].size()):
			if hallway[x][y] != 0:
				var block = ColorRect.new()
				block.position = Vector2(x*display_scale.x, y*display_scale.y)
				block.size = Vector2(display_scale.x,display_scale.y)
				var col = colors[int(rand_from_seed(hallway[x][y])[0]%colors.size())]
				block.color = col#Color.ALICE_BLUE#Color(randf(),randf(),randf(),1.0)
				$hallways.add_child(block)
	#print(active_doors)
	
	
	
func check_safe(pos, size, buffer):
	for r in ocupado:
		if check_overlap(pos, size, r[0], r[1], buffer):
			return false
	return true
const colors = [Color.RED, Color.BLUE, Color.GREEN, Color.YELLOW, Color.PURPLE]









