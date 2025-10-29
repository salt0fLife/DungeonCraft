@tool
extends Sprite3D
#@onready var cam = EditorInterface.get_editor_viewport_3d(0).get_camera_3d()
var cam = null

func _process(delta):
	if cam == null:
		if Engine.is_editor_hint():
			cam = EditorInterface.get_editor_viewport_3d(0).get_camera_3d()
		else:
			cam = get_viewport().get_camera_3d()
	var dif = (cam.global_position*get_parent().global_transform) - position
	var rot_y = atan2(dif.x,dif.z)
	var dis = sqrt(pow(dif.x,2.0) + pow(dif.z,2.0))
	var rot_x = atan2(dis,dif.y)+PI*0.5
	rotation.x = rot_x
	rotation.y = rot_y
	var f = remap(rotation_degrees.x, 90.0, 270.0, -1.0, 1.0)
	f = remap(abs(f), 0.0, 1.0, 0.0, 6.0)
	f = int(f)
	frame = f
	pass
