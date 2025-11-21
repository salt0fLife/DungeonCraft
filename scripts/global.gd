extends Node
var display_name = ""
var is_host = false

signal spawnCreature
signal change_world
signal set_post_param
signal spawn_projectile
signal camera_impact
var inside = 1.0

var skin = [64,64,false,0,[]]

var snout = 0
var ears = 0
var tail = 0
var slim = false
var eyeColor = [Color.BLACK, Color.DARK_RED, Color.RED, Color.WHITE, Color.BLACK]
var eyeLashes = 1.0
var mouthData = [0.0,0.0,0.0,0.0,0.0,Color.BLACK, Color.BROWN, Color.RED, Color.WHITE]
var fangs = 0.0
var pointy_teeth = 0.0

var time = 0.0

func data_to_image(data) -> ImageTexture:
	return ImageTexture.create_from_image(Image.create_from_data(data[0],data[1],data[2],data[3], data[4]))

var disable_avatar = false
var camera_transform = Transform3D(Vector3.ZERO,Vector3.ZERO,Vector3.ZERO,Vector3.ZERO)

##changed to keep it from cluttering up the main folder while debugging
#var savePath = OS.get_executable_path().get_base_dir() + "/"#"res://"#"user://"#"res://tempSaveFolder/"#OS.get_executable_path().get_base_dir() + "/"#"res://"#"user://"
var savePath = "res://tempSaveFolder/"#OS.get_executable_path().get_base_dir() + "/"#"res://"#"user://"

func get_skin_list():
	if DirAccess.dir_exists_absolute(savePath+"/skins"):
		var skins = DirAccess.get_files_at(savePath+"/skins")
		return skins
	else:
		return []

func _process(delta):
	time += delta

func create_camera_impact(pos,power):
	emit_signal("camera_impact",pos,power)

func _input(event):
	if Input.is_action_just_pressed("debugRenderOff"):
		get_viewport().debug_draw = Viewport.DEBUG_DRAW_DISABLED
	if Input.is_action_just_pressed("debugRenderOverdraw"):
		get_viewport().debug_draw = Viewport.DEBUG_DRAW_OVERDRAW
	if Input.is_action_just_pressed("debugRenderUnshaded"):
		get_viewport().debug_draw = Viewport.DEBUG_DRAW_UNSHADED
	if Input.is_action_just_pressed("debugRenderLighting"):
		get_viewport().debug_draw = Viewport.DEBUG_DRAW_LIGHTING

func vec3_rot_lerp(rot1: Vector3, rot2: Vector3, val: float):
	var x = lerp_angle(rot2.x, rot1.x, val)
	var y = lerp_angle(rot2.y, rot1.y, val)
	var z = lerp_angle(rot2.z, rot1.z, val)
	return Vector3(x,y,z)
