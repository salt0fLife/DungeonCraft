extends Node3D
@export var doorway_loader := Node

# Called when the node enters the scene tree for the first time.
func _ready():
	Global.connect("enter_room",update_rooms_for_id)
	update_rooms_for_id(0) #until i get saving system working
	doorway_loader.room_count = get_child_count(false)



func update_rooms_for_id(id):
	for i in range(0,get_child_count(false)):
		get_child(i).visible = (i==id) #only visible if is active id
