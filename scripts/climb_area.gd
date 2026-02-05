@tool
extends StaticBody3D
var pos = Vector2.ZERO
var height = Vector2.ZERO
@export var desired_height = 3.0
@export var assigned_room_id := 0
var tool_tip = "climb"
var tool_tip_color = Color.YELLOW
var facing_rot = 0.0
var interact_time = -1.0 #instant kinda

func _ready():
	var shape = BoxShape3D.new()
	shape.size = Vector3(1.0,desired_height,0.3)
	$CollisionShape3D.shape = shape
	$CollisionShape3D.position.y = desired_height*0.5
	$CollisionShape3D.position.z = -0.1
	pos = Vector2(position.x,position.z)
	height = Vector2(position.y, position.y + desired_height)
	facing_rot = rotation.y
	settup_graphics()

func settup_graphics():
	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color.YELLOW
	for old in $graphics_handler.get_children(false):
		old.queue_free()
	var distance = int(height.y - height.x)
	for i in range(0,distance*4.0):
		var g = MeshInstance3D.new()
		g.mesh = BoxMesh.new()
		g.mesh.size = Vector3(1.0,0.1,0.1)
		g.position.y = i*0.25
		$graphics_handler.add_child(g)
		g.set_surface_override_material(0,mat)

func interact():
	return [Lookup.interact_return_code.is_ladder, [pos,height,facing_rot]]
