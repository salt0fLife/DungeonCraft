extends Node3D


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	global_position = get_viewport().get_camera_3d().global_position
