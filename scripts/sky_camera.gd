extends Camera3D

#
#func _ready():
	#await RenderingServer.frame_post_draw
	#$"../..".set("sky/sky_material/shader_parameter/source_panorama", $"..".get_texture())

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	global_transform = Global.camera_transform
	position = position / (255.0*2.41)
	pass
