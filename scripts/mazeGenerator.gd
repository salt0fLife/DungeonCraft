extends Node3D
@export var height : int = 4
@export var width : int = 4
@export var starting_pos = Vector2i.ZERO
@export var ending_pos = Vector2i.ZERO
@export var seed : int = 0
@export var max_straight:int = 10
@export var straight_backtrack:int = 3
@export var straight_backtrack_random : int = 3
@export var middle_area_start: Vector2i = Vector2i.ZERO
@export var middle_area_end: Vector2i = Vector2i.ZERO
var cell_spacing = 10.0

#func _ready():
	#resize_cells()
	#inject_randomness()
	#cuttout_area(Vector2i(19,19),Vector2i(30,30))
	#generate_maze()
	##inject_randomness()
	##generate_graphics_rectangles() #for base_layer
	##generate_graphics_textures()
	##generate_graphics_intersections()
	##highlight_path()
	##calculate_unique_intersections()
	#generate_graphics_3d()
	#highlight_path_3d()
	#highlight_injected_random_3d()
	#print(randi_range_from_seed(seed,0,10))
	#pass

func create_from_seed(s:int) -> void:
	seed = s
	resize_cells()
	inject_randomness()
	cuttout_area(middle_area_start,middle_area_end)
	generate_maze()
	generate_graphics_3d()
	highlight_path_3d()
	highlight_injected_random_3d()
	print(randi_range_from_seed(seed,0,10))

func calculate_unique_intersections():
	var keys = [] #tbf 256 down to 70 is pretty good
	for a in range(0,4):
		for b in range(0,4):
			for c in range(0,4):
				for d in range(0,4):
					var key = [a,b,c,d]
					if !keys.has(key): #unique rot 0
						key = rotate_key_90(key) 
						if !keys.has(key): #unique rot 0, 90
							key = rotate_key_90(key)
							if !keys.has(key): #unique rot 0, 90, 180
								key = rotate_key_90(key)
								if !keys.has(key): #truly unique key
									key = rotate_key_90(key) #spinny spinny weeee :D
									keys += [key] #add to list of unique keys
	#im a good programmer yes you can trust me
	var ind:int = 0
	for k in keys:
		var t = str(k) + " " + str(ind) #prints of own line
		ind += 1
		print(t)
	pass

var cells = []
var path_to_exit = []

enum {
	UP,
	DOWN,
	LEFT,
	RIGHT,
	NEUTRAL, #unset
	OPEN,
}

func highlight_path() -> void:
	for pos in path_to_exit:
		draw_maze_tile(pos.x,pos.y,Color(1.0,0.0,0.0,0.5))
	draw_maze_tile(starting_pos.x,starting_pos.y,Color.GREEN)
	draw_maze_tile(ending_pos.x,ending_pos.y,Color.BLUE)
	pass

func highlight_path_3d() -> void:
	for pos in path_to_exit:
		var a = load("res://debug/generation/maze/testPathwayIndicator.tscn").instantiate()
		a.position = Vector3(pos.x*cell_spacing,0.0,pos.y*cell_spacing)
		a.position.x -= width*0.5 * cell_spacing
		a.position.z -= height*0.5 * cell_spacing
		add_child(a)
	pass

func highlight_injected_random() -> void:
	for pos in randomized_cells:
		draw_maze_tile(pos.x,pos.y,Color(1.0,1.0,0.0,0.25))

func highlight_injected_random_3d() -> void:
	for pos in randomized_cells:
		var s = load("res://debug/generation/maze/test_randomized_indicator.tscn").instantiate()
		s.position = Vector3(pos.x*cell_spacing,0.0,pos.y*cell_spacing)
		s.position.x -= width*0.5 * cell_spacing
		s.position.z -= height*0.5 * cell_spacing
		add_child(s)

func resize_cells() -> void:
	starting_pos.x = clampi(starting_pos.x,0,width)
	starting_pos.y = clampi(starting_pos.y,0,height)
	#scales cells array to correct size
	var new_cells:Array = []
	for x in range(0,width):
		var ar = []
		for y in range(0,height):
			var cell_val = NEUTRAL
			ar += [NEUTRAL]
			pass
		new_cells += [ar]
	cells = new_cells

func generate_maze() -> void:
	#requires resize cells first
	var cell_coords : Vector2i = starting_pos
	var current_straight = 0
	var path = [] #keep track of your path and when you cannot continue backtrack
	#var path_to_exit = [] #set this as the path when the cell_pos == ending_pos
	var last_set_val = UP #starting val does not really matter
	var finished: bool = false
	var max_iterrations: int = 4096
	var found_path = false
	cells[starting_pos.x][starting_pos.y] = OPEN
	while !finished: #loops until you stop it
		var cell_seed = (cell_coords.x*2345 + cell_coords.y*1987) + seed
		
		#forced interest
		if current_straight >= max_straight:
			current_straight = 0
			var backtrack = straight_backtrack + randi_range_from_seed(cell_seed,0,straight_backtrack_random)
			for pi in range(0,path.size()): #pi is path_index
				var val = path[0]
				if !get_valid_options(val).is_empty() and !(pi < backtrack-1):
					var options2 = get_valid_options(val)
					var option = options2[randi_range_from_seed(cell_seed,0,options2.size())]#get_valid_options(val).pick_random()
					cell_coords = Vector2i(option.x,option.y) #sets next cell coords
					last_set_val = option.z
					break #end stop checking and deleting path we already moved
				else:
					path.remove_at(0) #this one was checked, backtracking
		
		
		
		
		var options = [ #up down left right
			Vector3i(cell_coords.x,cell_coords.y+1,UP),
			Vector3i(cell_coords.x,cell_coords.y-1,DOWN),
			Vector3i(cell_coords.x-1,cell_coords.y,LEFT),
			Vector3i(cell_coords.x+1,cell_coords.y,RIGHT),
			]
		var valid_options = []
		for c in options:
			if !is_in_bounds(Vector2i(c.x,c.y)):
				continue #not valid check other options
			elif cells[c.x][c.y] == NEUTRAL:
					valid_options += [c] #is in bounds and a neutral cell
			#else is in bounds but already set
		
		#tracks path
		path.insert(0,cell_coords)
		#path += [cell_coords]
		
		
		if cell_coords == ending_pos and !found_path:
			path_to_exit = path.duplicate(false)
			print(cell_coords)
			found_path = true
		
		if valid_options.is_empty():
			current_straight = 0
			#print("no valid cell options")
			#finished = true
			cells[cell_coords.x][cell_coords.y] = last_set_val
			var next_cell = get_neutral_cell_or_null()
			if next_cell == null:
				print("no more neutral cells")
				finished = true
			else:
				#hit end moving elsewhere
				#we dont want to set to the cells value because its
				#cell_coords = next_cell
				for pi in range(0,path.size()): #pi is path_index
					var val = path[0]
					if !get_valid_options(val).is_empty():
						#instead of just setting we need to move to next dir so we dont mess up existing architecture
						#this looks cool but creates unsolveable mazes
						#cell_coords = val #has_valid_options
						var options2 = get_valid_options(val)
						var option = options2[randi_range_from_seed(cell_seed,0,options2.size())]#get_valid_options(val).pick_random()
						cell_coords = Vector2i(option.x,option.y) #sets next cell coords
						last_set_val = option.z #for reference when there is no valid option
						#we started new branch without messing up existing maze
						break #end stop checking and deleting path we already moved
					else:
						path.remove_at(0) #this one was checked, backtracking
		else:
			current_straight += 1
			var option = valid_options[randi_range_from_seed(cell_seed,0,valid_options.size())] #we will make this less random later
			cells[cell_coords.x][cell_coords.y] = last_set_val #sets current cell to direction taken
			cell_coords = Vector2i(option.x,option.y) #sets next cell coords
			last_set_val = option.z #for reference when there is no valid option
		
		if cell_coords == ending_pos:
			current_straight = 0
			var new_options = get_valid_options(starting_pos)
			if !new_options.is_empty():
				#cell_coords = starting_pos #move to starting instead of wherever you were
				var option = new_options[randi_range_from_seed(cell_seed,0,new_options.size())]
				cell_coords = Vector2i(option.x,option.y) #sets next cell coords
				last_set_val = option.z
				#we move to start instead so its more interesting and there is not unused areas of maze past finish
		
		#i am naturally weary of while loops
		max_iterrations -= 1
		if max_iterrations < 0:
			print("max maze iterations reached")
			finished = true

func cuttout_area(start_pos:Vector2i,end_pos:Vector2i) -> void:
	var size = end_pos - start_pos
	for x in range(0,size.x):
		for y in range(0,size.y):
			var pos = Vector2i(x,y)+start_pos
			cells[pos.x][pos.y] = OPEN

var randomized_cells = []
func inject_randomness() -> void:
	var i = 0
	for x in range(0,width):
		for y in range(0,height):
			if path_to_exit.has(Vector2i(x,y)): #the maze must remain solvable
				continue
			var val = cells[x][y]
			var seed = float(val + seed + x + y + i)
			if randf_from_seed(seed+27.0) < 0.005:
				cells[x][y] = randi_range_from_seed(seed,0,3) #
				randomized_cells += [Vector2i(x,y)]
				pass
			i += 1

func get_valid_options(coords : Vector2i) -> Array:
	var options = [ #up down left right
		Vector3i(coords.x,coords.y+1,UP),
		Vector3i(coords.x,coords.y-1,DOWN),
		Vector3i(coords.x-1,coords.y,LEFT),
		Vector3i(coords.x+1,coords.y,RIGHT),
		]
	var valid_options = []
	for c in options:
		if !is_in_bounds(Vector2i(c.x,c.y)):
			continue #not valid check other options
		elif cells[c.x][c.y] == NEUTRAL:
				valid_options += [c] #is in bounds and a neutral cell
		#else is in bounds but already set
	return valid_options

func clear_children() -> void:
	for i in get_children(false):
		i.queue_free()

func generate_graphics_rectangles():
	for x in range(0,width):
		for y in range(0,height):
			var val = cells[x][y]
			var col = Color.BLACK
			match val:
				NEUTRAL: 
					col = Color(float(x)/float(width),float(y)/float(height),0.0,1.0)
				UP:
					col = Color(0.5,1.0,0.5,1.0)
				DOWN:
					col = Color(0.5,0.0,0.5,1.0)
				LEFT:
					col = Color(0.0,0.5,0.5,1.0)
				RIGHT:
					col = Color(1.0,0.5,0.5,1.0)
			var r = ColorRect.new()
			r.size = Vector2(cell_spacing,cell_spacing)
			r.color = col
			r.position = Vector2(float(x)*cell_spacing, float(y)*cell_spacing)
			add_child(r)

func draw_maze_tile(x : int,y : int,col : Color) -> void:
	var r = ColorRect.new()
	r.size = Vector2(cell_spacing,cell_spacing)
	r.color = col
	r.position = Vector2(float(x)*cell_spacing, float(y)*cell_spacing)
	add_child(r)

func generate_graphics_textures_old():
	for x in range(0,width):
		for y in range(0,height):
			var val = cells[x][y]
			var vertical = true
			match val:
				LEFT:
					vertical = false 
				RIGHT:
					vertical = false 
			if val == NEUTRAL:
				continue #dont draw neutral
			var r = TextureRect.new()
			#r.size = Vector2(cell_spacing,cell_spacing)
			if vertical:
				r.texture = load("res://debug/textures/NewPiskel-1.png.png")
			else:
				r.texture = load("res://debug/textures/NewPiskel-2.png1.png")
			r.position = Vector2(float(x)*cell_spacing, float(y)*cell_spacing)
			add_child(r)

const tiles_scenes = [
	"res://assets/environmentPieces/mazeCells/base_four_way.tscn", #0 empty
	"res://assets/environmentPieces/mazeCells/base_dead_end.tscn", #1 dead end
	"res://assets/environmentPieces/mazeCells/base_four_way.tscn", #2 four way
	"res://assets/environmentPieces/mazeCells/base_three_way.tscn", #3 three way
	"res://assets/environmentPieces/mazeCells/base_corner.tscn", #4 corner
	"res://assets/environmentPieces/mazeCells/base_hallway.tscn", #5 hallway
	"res://assets/environmentPieces/mazeCells/base_cell.tscn", #6 neutral
]

const ridged_tiles_scenes = [
	"res://assets/environmentPieces/mazeCells/base_four_way.tscn", #0 empty
	"res://assets/environmentPieces/mazeCells/ridge_dead_end.tscn", #1 dead end
	"res://assets/environmentPieces/mazeCells/base_four_way.tscn", #2 four way
	"res://assets/environmentPieces/mazeCells/ridge_three_way.tscn", #3 three way
	"res://assets/environmentPieces/mazeCells/ridge_corner.tscn", #4 corner
	"res://assets/environmentPieces/mazeCells/ridge_hallway.tscn", #5 hallway
	"res://assets/environmentPieces/mazeCells/base_cell.tscn", #6 neutral
]

const broken_tiles_1 = [
	"res://assets/environmentPieces/mazeCells/base_four_way.tscn", #0 empty
	"res://assets/environmentPieces/mazeCells/ridge_dead_end.tscn", #1 dead end
	"res://assets/environmentPieces/mazeCells/base_four_way.tscn", #2 four way
	"res://assets/environmentPieces/mazeCells/broken_three_way_1.tscn", #3 three way
	"res://assets/environmentPieces/mazeCells/broken_corner_1.tscn", #4 corner
	"res://assets/environmentPieces/mazeCells/ridge_hallway_broken_1.tscn", #5 hallway
	"res://assets/environmentPieces/mazeCells/base_cell.tscn", #6 neutral
]

const broken_tiles_2 = [
	"res://assets/environmentPieces/mazeCells/base_four_way.tscn", #0 empty
	"res://assets/environmentPieces/mazeCells/ridge_dead_end.tscn", #1 dead end
	"res://assets/environmentPieces/mazeCells/base_four_way.tscn", #2 four way
	"res://assets/environmentPieces/mazeCells/broken_three_way_2.tscn", #3 three way
	"res://assets/environmentPieces/mazeCells/broken_corner_2.tscn", #4 corner
	"res://assets/environmentPieces/mazeCells/ridge_hallway_broken_2.tscn", #5 hallway
	"res://assets/environmentPieces/mazeCells/base_cell.tscn", #6 neutral
]

const vines_corner = [
	"res://assets/environmentPieces/mazeCells/decor/corner_vines_1.tscn",
	"res://assets/environmentPieces/mazeCells/decor/corner_vines_2.tscn"
]

const vines_hallway = [
	"res://assets/environmentPieces/mazeCells/decor/hallway_vines_1.tscn",
	"res://assets/environmentPieces/mazeCells/decor/hallway_vines_2.tscn"
]

func generate_graphics_3d() -> void:
	var si = 0
	for x in range(0,width):
		for y in range(0,height):
			si += 1
			var val = cells[x][y]
			var tex_indx = 0
			var tex_rot = 0
			
			if val == OPEN:
				continue #so it does not instantiate for open
			
			var c_key = get_connected_borders(x,y)
			
			for i in range(0,4):
				if connected_lookup.has(c_key):
					tex_indx = connected_lookup[c_key]
					break
				else:
					c_key = rotate_key_90(c_key)
					tex_rot += 1
			#if cant find it tex_indx = 0 (empty)
			var path = tiles_scenes[tex_indx]
			
			var t_r = randf_from_seed(float(x+y+si))
			if t_r < 0.5:
				path = ridged_tiles_scenes[tex_indx]
			if t_r < 0.05: #rare chance, landmark thing
				if t_r > 0.025:
					path = broken_tiles_1[tex_indx]
				else:
					path = broken_tiles_2[tex_indx]
			
			var s = load(path).instantiate()
			s.position = Vector3(float(x)*cell_spacing, 0.0,float(y)*cell_spacing)
			s.position.x -= width*0.5 * cell_spacing
			s.position.z -= height*0.5 * cell_spacing
			match tex_rot:
				1: 
					s.rotation.y -= PI*0.5
					#s.position.x -= cell_spacing
				2: 
					s.rotation.y -= PI
					#s.position.z += cell_spacing
					#s.position.x -= cell_spacing
				3:
					s.rotation.y -= PI*1.5
					#s.position.z += cell_spacing
			s.rotation.y += PI #because I made them backwards lmao
			s.owner = self
			add_child(s)
			
			#now add decor
			var v_r = randf_from_seed(float(x+y+si+5))
			if v_r > 0.97:
				var v = load(vines_corner[randi_range_from_seed(x+y+si,0,(vines_corner.size()))]).instantiate()
				v.position = s.position
				v.position.y = remap(v_r,0.97,1.0,30.0,90.0) #dont really want the player getting to it frequently
				if v_r > 0.985:
					v.rotation.y += PI*0.5
				v.owner = self
				add_child(v)
			
			if tex_indx == 5: #is hallway
				var h_v_r = randf_from_seed(float(x+y+si+7))
				if h_v_r > 0.8:
					var v = load(vines_hallway[randi_range_from_seed(x+y+si,0,(vines_hallway.size()))]).instantiate()
					v.position = s.position
					v.position.y = remap(v_r,0.8,1.0,30.0,90.0) #dont really want the player getting to it frequently
					v.rotation.y = s.rotation.y
					if v_r > 0.9:
						v.rotation.y += PI
					v.owner = self
					add_child(v)
				pass
			

const tiles_tex = [
	"res://assets/textures/maze/mazeTiles04.png", #0 empty
	"res://assets/textures/maze/mazeTiles05.png", #1 dead end
	"res://assets/textures/maze/mazeTiles06.png", #2 four way
	"res://assets/textures/maze/mazeTiles07.png", #3 three way
	"res://assets/textures/maze/mazeTiles08.png", #4 corner
	"res://assets/textures/maze/mazeTiles09.png", #5 hallway
	"res://assets/textures/maze/mazeTiles10.png", #6 neutral
]

func generate_graphics_textures():
	for x in range(0,width):
		for y in range(0,height):
			var val = cells[x][y]
			
			var tex_indx = 0
			var tex_rot = 0
			
			var c_key = get_connected_borders(x,y)
			
			for i in range(0,4):
				if connected_lookup.has(c_key):
					tex_indx = connected_lookup[c_key]
					break
				else:
					c_key = rotate_key_90(c_key)
					tex_rot += 1
			#if cant find it tex_indx = 0 (empty)
			
			var r = TextureRect.new()
			r.texture = load(tiles_tex[tex_indx])
			r.position = Vector2(float(x)*cell_spacing, float(y)*cell_spacing)
			match tex_rot:
				1: 
					r.rotation = PI*0.5
					r.position.x += cell_spacing
				2: 
					r.rotation = PI
					r.position.x += cell_spacing
					r.position.y += cell_spacing
				3:
					r.rotation = PI*1.5
					r.position.y += cell_spacing
			add_child(r)

const connected_lookup = {
	[true,false,false,false]: 1, #up right down left
	[true,true,true,true]: 2,
	[true,true,false,true]: 3,
	[true,true,false,false]: 4,
	[true,false,true,false]: 5,
	[false,false,false,false]: 6,
}

func get_connected_borders(x:int,y:int): #up right down left
	var up = Vector2i(x,y+1) #up
	var down = Vector2i(x,y-1) #down
	var left = Vector2i(x-1,y) #left
	var right = Vector2i(x+1,y) #right
	
	var connections = [
		false, #up
		false, #right
		false, #down
		false #left
	]
	
	match cells[x][y]: #make sure it always connects to where its coming from
		UP:connections[2] = true
		RIGHT:connections[3] = true
		DOWN:connections[0] = true
		LEFT:connections[1] = true
		OPEN:
			connections[0] = true
			connections[1] = true
			connections[2] = true
			connections[3] = true
	
	if is_in_bounds(up): #connects to all the surrounding cells that exit from it
		match cells[up.x][up.y]:
			UP: connections[0] = true
			#OPEN: connections[0] = true
	if is_in_bounds(right):
		match cells[right.x][right.y]:
			RIGHT: connections[1] = true
			#OPEN: connections[1] = true
	if is_in_bounds(down):
		match cells[down.x][down.y]:
			DOWN: connections[2] = true
			#OPEN: connections[2] = true
	if is_in_bounds(left):
		match cells[left.x][left.y]:
			LEFT: connections[3] = true
			#OPEN: connections[3] = true
	return connections #up right down left

func rotate_connected_borders(c_key : Array) -> Array: #up right down left
	return [c_key[3],c_key[0],c_key[1],c_key[2]]

const corner_lookup = { #cut in half and stacked, not clockwise
	#god there are so many permutations (70 unique if you dont count rotations)
	[RIGHT,RIGHT,DOWN,LEFT] : Color.BLUE_VIOLET
}


#ok so permutations time
#there are like 256 unique intersection options or something but some are rotations
#is it worth rotating the tiles???
#i think yes??? especially if 3d (would make edits easier too because that would be a pain)
#yeah I should make rotations a thing
#ooooh my god but the directions change when you rotate ;-; this is hell
#

#ok but we are filling every square so we only need [dead_end, straight_ahead, turn_right, turn_left, one_wall]


func rotate_key_90(key : Array) -> Array:
	var new_key = [0,0,0,0]
	
	for i in range(0,4):
		var val = key[i]
		match val:
			UP: val = RIGHT
			RIGHT: val = DOWN
			DOWN: val = LEFT
			LEFT: val = UP
		var mi = i+ 1
		if mi > 3:
			mi = 0
		new_key[mi] = val
	
	return new_key

func generate_graphics_intersections():
	for x in range(0,width/2): #yeah 70 hand modeled options would in fact take a long time but 4 would look really bad
		for y in range(0,height/2):
			var corner_key = [ #there may be a faster way to do this but idk
				cells[x][y],
				cells[x+1][y],
				cells[x][y+1],
				cells[x+1][y+1],
			]
			if corner_lookup.has(corner_key): #just dont draw it if you dont have it
				var col = corner_lookup[corner_key]
				var r = ColorRect.new()
				r.size = Vector2(cell_spacing*2.0,cell_spacing*2.0)
				r.color = col
				r.position = Vector2(float(x*2)*cell_spacing, float(y*2)*cell_spacing)
				add_child(r)

func get_neutral_cell_or_null():
	for x in range(0,width):
		for y in range(0,height):
			if cells[x][y] == NEUTRAL: return Vector2i(x,y)
	return null #no cells left

func randi_range_from_seed(s : int, min : int, max : int) -> int:
	var rf = randf_from_seed(float(s)) #always between 0.0 and 1.0
	var size = max - min #how big we should scale this
	rf *= float(size)
	rf += float(min) #makes sure its not less than min
	var val = int(rf)
	val = clamp(val,min,max) #just in case
	return val
	#return randi_range(min,max) #temp

func randf_from_seed(s: float): #between 0.0 and 1.0
	s = s*17.234
	return (0.5 - sin((s+3.5)*129.23+sin((s+7.235)*43.894+sin((s+12.5)*13.243)*24.53)*7.213)*0.5)

func is_in_bounds(pos : Vector2i) -> bool:
	return !((pos.x < 0) or (pos.x > width-1) or (pos.y < 0) or (pos.y > height-1))

