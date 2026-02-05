@tool
extends Node3D
@export var target_pos = Vector3.ZERO

func _process(delta):
	update_graphics(target_pos)

@onready var graphics = $electricity_graphics_mesh
func update_graphics(dif : Vector3) -> void:
	graphics.position = global_position
	#graphics.rotation.z = atan2(dif.y,dif.x)-PI*0.5
	#graphics.rotation.x = -atan2(dif.y,dif.z)+PI*0.5
	graphics.rotation.y = atan2(dif.x,dif.z)
	var h_l = Vector2(dif.x,dif.z).length()
	graphics.rotation.x = atan2(h_l,dif.y)
	var dis = dif.length()
	graphics.scale.y = dis





