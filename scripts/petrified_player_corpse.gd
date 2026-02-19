extends Node3D

@onready var avatar = $playerAvatar/genericAvatar
# Called when the node enters the scene tree for the first time.
func set_pose(pose) -> void:
	avatar.apply_pose(pose) #yeah ik set and apply but whatever

#func set_mat(mat):
	#mat.set("shader_parameter/petrified",true)
	#mat.set("shader_parameter/ghostly",0.0)
	#avatar.set_material_for_all(mat)

func load_skin(cosmetics_data):
	var skin = cosmetics_data[0]
	var t = cosmetics_data[1]
	var skin_img = Global.data_to_image(skin)
	avatar.load_skin(skin_img, t[0],t[1],t[2],t[3],t[4],t[5],t[6],t[7])
	avatar.set_body_param("shader_parameter/petrified",true)
