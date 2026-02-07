extends Node2D
@export var height : int = 4
@export var width : int = 4
@export var starting_pos = Vector2i.ZERO
@export var ending_pos = Vector2i.ZERO
@export var seed : int = 0
var cell_spacing = 25.0

func _ready():
	generate_maze()
	generate_graphics_rectangles() #for base_layer
	generate_graphics_intersections()
	calculate_unique_intersections()
	pass

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

enum {
	UP,
	DOWN,
	LEFT,
	RIGHT,
	NEUTRAL, #unset
	OPEN,
}

func generate_maze() -> void:
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
	
	var cell_coords : Vector2i = starting_pos
	var last_set_val = UP #starting val does not really matter
	var finished: bool = false
	var max_iterrations: int = 4096
	cells[starting_pos.x][starting_pos.y] = OPEN
	while !finished: #loops until you stop it
		var options = [ #up down left right
			#cell_coords + Vector2i(0,1),
			#cell_coords + Vector2i(0,-1),
			#cell_coords + Vector2i(1,0),
			#cell_coords + Vector2i(-1,0),
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
		if valid_options.is_empty():
			#print("no valid cell options")
			#finished = true
			cells[cell_coords.x][cell_coords.y] = last_set_val
			var next_cell = get_neutral_cell_or_null()
			if next_cell == null:
				print("no more neutral cells")
				finished = true
			else:
				#hit end moving elsewhere
				cell_coords = next_cell
		else:
			var option = valid_options.pick_random() #we will make this less random later
			cells[cell_coords.x][cell_coords.y] = option.z #sets current cell to direction taken
			cell_coords = Vector2i(option.x,option.y) #sets next cell coords
			last_set_val = option.z #for reference when there is no valid option
		
		
		#i am naturally weary of while loops
		max_iterrations -= 1
		if max_iterrations < 0:
			print("max maze iterations reached")
			finished = true

func generate_graphics_rectangles():
	for x in range(0,width):
		for y in range(0,height):
			var val = cells[x][y]
			var col = Color.BLACK
			match val:
				NEUTRAL: 
					col = Color(float(x)/float(width),float(y)/float(height),0.0,1.0)
				UP:
					col = Color(0.0,1.0,0.5,1.0)
				DOWN:
					col = Color(0.0,0.0,0.5,1.0)
				LEFT:
					col = Color(0.0,0.0,0.5,1.0)
				RIGHT:
					col = Color(1.0,0.0,0.5,1.0)
			var r = ColorRect.new()
			r.size = Vector2(cell_spacing,cell_spacing)
			r.color = col
			r.position = Vector2(float(x)*cell_spacing, float(y)*cell_spacing)
			add_child(r)

const corner_lookup = { #cut in half and stacked, not clockwise
	#god there are so many permutations
	[UP,UP,UP,UP] : Color.BLUE, #unique 1
	[DOWN,DOWN,DOWN,DOWN] : Color.BLUE, #2
	[LEFT,LEFT,LEFT,LEFT] : Color.BLUE, #3
	[RIGHT,RIGHT,RIGHT,RIGHT] : Color.BLUE, #4
	
	[DOWN,UP,UP,UP] : Color.RED, #unique 5
	[DOWN,DOWN,DOWN,DOWN] : Color.RED, #6
	[LEFT,LEFT,LEFT,LEFT] : Color.RED, #7
	[RIGHT,RIGHT,RIGHT,RIGHT] : Color.RED,  #8
	
	
	
}

#ok so permutations time
#there are like 256 unique intersection options or something but some are rotations
#is it worth rotating the tiles???
#i think yes??? especially if 3d (would make edits easier too because that would be a pain)
#yeah I should make rotations a thing
#ooooh my god but the directions change when you rotate ;-; this is hell
#

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

func randi_range_from_seed(s : int, max : int, min : int) -> int:
	if max < min:
		max = min # just because
	
	
	
	return 0

func is_in_bounds(pos : Vector2i) -> bool:
	return !((pos.x < 0) or (pos.x > width-1) or (pos.y < 0) or (pos.y > height-1))

