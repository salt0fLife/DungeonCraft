@tool
extends Node3D
@export var height = 0.0
@export var width = 1.0
@export var depth = 0.25
const stair_height = 0.25

# Called when the node enters the scene tree for the first time.
func _ready():
	generate_stairs()

func generate_stairs():
	for old in get_children(false):
		old.queue_free()
	var number = int(height / stair_height)
	var sb = StaticBody3D.new()
	add_child(sb)
	for i in range(0,number):
		var m = MeshInstance3D.new()
		m.mesh = BoxMesh.new()
		m.mesh.size.x = width
		m.mesh.size.z = depth*2.5
		m.mesh.size.y = stair_height
		m.position.y = i * 0.25
		m.position.z = i * depth
		add_child(m)
		var cs = CollisionShape3D.new()
		cs.shape = BoxShape3D.new()
		cs.shape.size.x = width
		cs.shape.size.z = depth*2.5
		cs.shape.size.y = stair_height
		cs.position.y = i * 0.25
		cs.position.z = i * depth
		sb.add_child(cs)



