extends Node3D
var seed = 28937456
@onready var max_room_size = 20.0
@onready var min_room_size = 5.0

# Called when the node enters the scene tree for the first time.
func _ready():
	generate_house()

var floor_plan = [
	
]
#floorplan[rooms]
#rooms[level, Vector2(pos), Vector2(size),type]

func generate_house():
	generate_floor_plan()
	visualize_floor(0)

enum { #room types
	entryway
}


func generate_floor_plan():
	var main_room = [0,Vector2.ZERO,Vector2(randf_range(min_room_size,max_room_size),randf_range(min_room_size,max_room_size)), entryway]
	floor_plan += [main_room]
	var additional_rooms = randi_range(0,8)
	for i in range(0,additional_rooms):
		
		pass
	
	pass

func create_inside():
	
	pass

func visualize_floor(floor_index = 0):
	for r in floor_plan:
		var room = ColorRect.new()
		room.position = r[1] * 10.0 + DisplayServer.screen_get_size()*0.5
		room.size = r[2] * 10.0
		room.color = Color(randf_range(0.0,1.0),randf_range(0.0,1.0),randf_range(0.0,1.0),1.0)
		add_child(room)
		pass
	pass
