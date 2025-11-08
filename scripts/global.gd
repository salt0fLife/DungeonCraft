extends Node
var display_name = ""
var is_host = false

signal spawnCreature
signal change_world
signal set_post_param
signal spawn_projectile
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
