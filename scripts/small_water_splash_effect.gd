extends Node3D

func _ready():
	$MeshInstance3D.scale = Vector3.ZERO

var life_time = 1.0
func _process(delta):
	life_time -= delta*4.0
	$MeshInstance3D.scale = (Vector3(1.0,1.0,1.0) - Vector3(life_time,life_time,life_time)) #yeah yeah i know
	
	if life_time < 0.0:
		queue_free()
