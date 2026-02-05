extends Node
@export var room_count := 0 #should be auto set by rooms_handler

## NOTE -> this node needs to be below all of the door nodes in tree so they have time to connect to siblings

func _ready():
	#ladder but grouped in room population
	var room_ladders = [] #indes is room id, data is ladder_indx
	#doors
	var room_doors = [] #index is room id, data is [ all "door_indx"s in room ]
	var room_internal_doors = [] #same as room_doors but list only includes doors that end up in same room
	var doors_val = [] #index is door_indx (door number in group "doorway"), data is [Location, output_location, output room_id]
	var doors = get_tree().get_nodes_in_group("doorway")
	#create arrays for all of the rooms
	for _x in range(0,room_count):
		room_doors += [[]] #adds array to store door indexs in for each room
		room_internal_doors += [[]] #adds array to store internal_door indexs in for each room
		room_ladders += [[]] #adds array to store ladder indexes in for each room
	for i in range(0,doors.size()):
		var door = doors[i] #[Location, output_location, output room_id, own_room_id]
		door.set_index_graphics(i) #makes the door change its visuals based on its index
		var d_p = door.get_transforms(0.0)[0]
		var data = [d_p, door.desired_pos, door.local_room_id, door.assigned_room_id]
		doors_val += [data] #adds data to doors_val_list
		var a_r_id = door.assigned_room_id
		if a_r_id > room_count:
			printerr("error setting up door with index " + str(i) + ", cause: assigned door index was higher than expected room count")
		else:
			match door.visual_type:
				door.type.sub_room: #this is the only sub_room type at the moment
					room_internal_doors[a_r_id] += [i]#adds index to rooms list of internal_doors
				_:
					room_doors[a_r_id] += [i] #adds index to rooms list of doors
	
	
	#apply changes to global
	Global.room_doors = room_doors
	Global.doors_val = doors_val
	Global.room_internal_doors = room_internal_doors
	
	#ladders
	var ladders_val = [] #index is ladder_indx, data, is [position,height,rot]
	
	var ladders = get_tree().get_nodes_in_group("climb_area")
	for l_i in range(0,ladders.size()):
		var ladder = ladders[l_i] #index is ladder_indx, data, is [position,height,rot]
		var data = [ladder.pos,ladder.height,ladder.facing_rot]
		ladders_val += [data] #adds data to ladders_val list
		var a_r_id = ladder.assigned_room_id
		if a_r_id > room_count:
			printerr("error setting up ladder with index " + str(l_i) + ", cause: assigned_room_id was higher than expected room count")
		else:
			room_ladders[a_r_id] += [l_i] #adds index to rooms list of doors
	
	#apply changes to global
	Global.room_ladders = room_ladders
	Global.ladders_val = ladders_val
