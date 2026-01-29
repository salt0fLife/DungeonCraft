@tool
extends StaticBody3D
var tool_tip = "enter"
var tool_tip_color = Color.BLUE
#@export var desired_rot: float = 0.0
#@export var desired_pos = Vector3.ZERO
@export var sibling_door_path : NodePath
@export var visual_type : type
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

func interact():
	assert(sibling_door != null, "sibling door path has become invalid")
	return [Lookup.interact_return_code.is_doorway, [desired_pos,rot_add]]

func get_transforms(initial_rot : float) -> Array:
	var rot = rotation.y - initial_rot
	var pos = $output_pos.global_position
	return [pos,rot]
