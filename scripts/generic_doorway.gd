@tool
extends StaticBody3D
var tool_tip = "enter"
var tool_tip_color = Color.BLUE
var interact_time = 0.75
#@export var desired_rot: float = 0.0
#@export var desired_pos = Vector3.ZERO
@export var sibling_door_path : NodePath
@export var visual_type : type
@export var assigned_room_id : int = 0
var local_room_id = 0
enum type {
	sub_room,
	new_room,
	new_room_external,
	new_room_shelter,
}

var sibling_door = null
var rot_add = 0.0
var desired_pos = Vector3.ZERO

func _ready():
	if Engine.is_editor_hint():
		update_graphics()
		return
	#connect to sibling
	sibling_door = get_node_or_null(sibling_door_path)
	assert(sibling_door != null, "sibling_door_path is invalid on startup")
	var output_transforms = sibling_door.get_transforms(rotation.y)
	desired_pos = output_transforms[0]
	rot_add = output_transforms[1] + PI #if they are aiming the same way player must turn around
	local_room_id = sibling_door.assigned_room_id
	#update graphics
	update_graphics()

func update_graphics():
	var dt = ""
	var dc = Color.WHITE
	var mat = $MeshInstance3D.get_active_material(0).duplicate()
	match visual_type:
		type.sub_room:
			dt = "SB"
			dc = Color.PALE_GREEN
		type.new_room:
			dt = "NR"
			dc = Color.LIME_GREEN
		_:
			dc = Color.INDIAN_RED
			dt = "visual_type not implemented"
	mat.albedo_color = dc
	$Label3D.text = dt
	$MeshInstance3D.set_surface_override_material(0,mat)
	tool_tip_color = dc
	tool_tip = "enter " + dt + " door"

func interact():
	#assert(sibling_door != null, "sibling door path has become invalid")
	return [Lookup.interact_return_code.is_doorway, [desired_pos,rot_add,local_room_id]]

func get_transforms(initial_rot : float) -> Array:
	var rot = rotation.y - initial_rot
	var pos = $output_pos.global_position
	return [pos,rot]

func set_index_graphics(indx : int) -> void:
	$Label3D2.text = str(indx)
	pass
