extends Node
var display_name = ""
var is_host = false

signal spawnCreature
signal change_world
signal set_post_param
signal spawn_projectile
signal camera_impact
signal player_death
signal chat
signal update_skin
signal create_item
signal thunder_from_point
signal update_health_graphics
signal update_mana_graphics
signal update_attributes
signal enter_room #called with an id when moving using doors for hiding unused rooms
signal signal_play_sound #needs (pos,filepath)
var inside = 0.0

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
	if Input.is_action_just_pressed("toggle_visible_combat_boxes"):
		Settings.show_combat_boxes = !Settings.show_combat_boxes
		Settings.emit_signal("update_combat_boxes")

func vec3_rot_lerp(rot1: Vector3, rot2: Vector3, val: float):
	var x = lerp_angle(rot2.x, rot1.x, val)
	var y = lerp_angle(rot2.y, rot1.y, val)
	var z = lerp_angle(rot2.z, rot1.z, val)
	return Vector3(x,y,z)

func send_chat(text, dead = false):
	var col = eyeColor[2]
	var txt = "[color=blue][player][/color][color=#" + str(int(col.r*9.0))+ str(int(col.g*9.0))+ str(int(col.b*9.0)) + "]" + display_name + ": [/color][color=gray]" + text + "[/color]"
	_on_chat(txt)
	_on_chat.rpc(txt)
	

func print_chat(text, col = "white"):
	var txt = "[color=" + col +"]" + text + "[/color]"
	_on_chat(txt)
	_on_chat.rpc(txt)

@rpc("any_peer","reliable")
func _on_chat(text):
	emit_signal("chat", text)

func create_loose_item(key, position):
	emit_signal("create_item", key, position)

const bone_names = [
	"torso",
	"hip_L",
	"knee_L",
	"hip_R",
	"knee_R",
	"neck",
	"shoulder_L",
	"elbowL",
	"shoulder_R",
	"elbowR",
	"tail",
	"tail_001",
	"tail_002",
	"eyebrows_L",
	"eyebrows_R"
]

const avatar_profiles = {
	"normal" : [
	"res://assets/avatar/avatarProfiles/normal/torso_norm.tscn",
	"res://assets/avatar/avatarProfiles/normal/left_leg_1_norm.tscn",
	"res://assets/avatar/avatarProfiles/normal/left_foot_norm.tscn",
	"res://assets/avatar/avatarProfiles/normal/right_leg_1_norm.tscn",
	"res://assets/avatar/avatarProfiles/normal/right_foot_norm.tscn",
	"res://assets/avatar/avatarProfiles/head/head_norm.tscn",
	"res://assets/avatar/avatarProfiles/normal/left_arm_1_norm.tscn",
	"res://assets/avatar/avatarProfiles/normal/left_arm_2_norm.tscn",
	"res://assets/avatar/avatarProfiles/normal/right_arm_1_norm.tscn",
	"res://assets/avatar/avatarProfiles/normal/right_arm_2_norm.tscn",
	],
	"slim" : [
	"res://assets/avatar/avatarProfiles/slim/torso_slim.tscn",
	"res://assets/avatar/avatarProfiles/slim/left_leg_1_slim.tscn",
	"res://assets/avatar/avatarProfiles/slim/left_foot_slim.tscn",
	"res://assets/avatar/avatarProfiles/slim/right_leg_1_slim.tscn",
	"res://assets/avatar/avatarProfiles/slim/right_foot_slim.tscn",
	"res://assets/avatar/avatarProfiles/head/head_norm.tscn",
	"res://assets/avatar/avatarProfiles/slim/left_arm_1_slim.tscn",
	"res://assets/avatar/avatarProfiles/slim/left_arm_2_slim.tscn",
	"res://assets/avatar/avatarProfiles/slim/right_arm_1_slim.tscn",
	"res://assets/avatar/avatarProfiles/slim/right_arm_2_slim.tscn",
	],
	"nice" : [
	"res://assets/avatar/avatarProfiles/nice/torso_slim_001.tscn",
	"res://assets/avatar/avatarProfiles/nice/left_leg_1_slim_001.tscn",
	"res://assets/avatar/avatarProfiles/nice/left_foot_slim_001.tscn",
	"res://assets/avatar/avatarProfiles/nice/right_leg_1_slim_001.tscn",
	"res://assets/avatar/avatarProfiles/nice/right_foot_slim_001.tscn",
	"res://assets/avatar/avatarProfiles/head/head_norm.tscn",
	"res://assets/avatar/avatarProfiles/nice/left_arm_1_slim_001.tscn",
	"res://assets/avatar/avatarProfiles/nice/left_arm_2_slim_001.tscn",
	"res://assets/avatar/avatarProfiles/nice/right_arm_1_slim_001.tscn",
	"res://assets/avatar/avatarProfiles/nice/right_arm_2_slim_001.tscn",
	],
	"bitMuch" : [
	"res://assets/avatar/avatarProfiles/aBitMuch/a_bit_much_body.tscn",
	"res://assets/avatar/avatarProfiles/nice/left_leg_1_slim_001.tscn",
	"res://assets/avatar/avatarProfiles/nice/left_foot_slim_001.tscn",
	"res://assets/avatar/avatarProfiles/nice/right_leg_1_slim_001.tscn",
	"res://assets/avatar/avatarProfiles/nice/right_foot_slim_001.tscn",
	"res://assets/avatar/avatarProfiles/head/head_norm.tscn",
	"res://assets/avatar/avatarProfiles/nice/left_arm_1_slim_001.tscn",
	"res://assets/avatar/avatarProfiles/nice/left_arm_2_slim_001.tscn",
	"res://assets/avatar/avatarProfiles/nice/right_arm_1_slim_001.tscn",
	"res://assets/avatar/avatarProfiles/nice/right_arm_2_slim_001.tscn",
	]
}

func instance_creature(key: String,location : Vector3,modifiers = {}):
	emit_signal("spawnCreature",key,location,modifiers)

func instance_projectile(key : String, pos : Vector3, dir : Vector3, owned_by : String) -> void:
	emit_signal("spawn_projectile", key,pos,dir,owned_by)

func set_post(key,val):
	emit_signal("set_post_param",key,val)

var room_doors = [] #index is room id, data is door_indx
var room_internal_doors = [] #index is room id, data is door_indx
var doors_val = [] #index is door_indx (door number in group "doorway"), data is [Location, output_location, output room_id]

var room_ladders = [] #indes is room id, data is ladder_indx
var ladders_val = [] #index is ladder_indx, data, is [position,height,rot]

func play_sound(pos : Vector3, file_path : String) -> void:
	emit_signal("signal_play_sound", pos, file_path)
