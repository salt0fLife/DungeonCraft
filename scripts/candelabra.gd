@tool
extends Node3D
@export var heads :int = 1
@export var lit_count :int = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	update_graphics()
	pass # Replace with function body.

var gap = 0.2
func update_graphics():
	for old in $heads.get_children(false):
		old.queue_free()
	if heads < 1:
		heads = 1 #because yeah
	
	var fire_mat = load("res://assets/materials/fire_mat.tres").duplicate()
	fire_mat.set("shader_parameter/size",0.1)
	
	if lit_count == heads:
		fire_mat.set("shader_parameter/fire_col",Color.AQUA)
	else:
		fire_mat.set("shader_parameter/fire_col",Color.ORANGE)
	
	var dis = heads*gap - gap
	$cross.scale.x = dis + gap*0.5
	var starting_pos = -dis*0.5
	for i in range(0,heads):
		var weight = (float(i)+0.5) / float(heads)
		var fancy_height = sin(weight*PI) * (float(heads)/32.0)
		var candle = MeshInstance3D.new()
		candle.mesh = BoxMesh.new()
		candle.mesh.size = Vector3(0.05,0.5,0.05)
		candle.mesh.size.y += fancy_height
		candle.position.y = 0.25 + fancy_height*0.5
		candle.position.x = (gap * i)+starting_pos
		$heads.add_child(candle)
		if i < lit_count:
			var light = MeshInstance3D.new()
			light.mesh = PlaneMesh.new()
			light.mesh.orientation = 2
			light.mesh.size = Vector2(0.075,0.325)
			light.set_surface_override_material(0,fire_mat)
			light.position.y = 0.676 + fancy_height
			light.position.x = candle.position.x
			$heads.add_child(light)


