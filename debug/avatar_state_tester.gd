extends Node3D

# Called when the node enters the scene tree for the first time.
func _ready():
	if !visible:
		return
	var skin_img = Global.data_to_image(Global.skin)
	var t = [Global.ears, Global.tail, Global.snout, Global.slim, Global.eyeColor, Global.mouthData, Global.fangs, Global.pointy_teeth]
	$playerAvatar.get_child(0).load_skin(skin_img, t[0],t[1],t[2],t[3],t[4],t[5])
	$playerAvatar.get_child(0).set_burning(false)
	
	$playerAvatar2.get_child(0).load_skin(skin_img, t[0],t[1],t[2],t[3],t[4],t[5])
	$playerAvatar2.get_child(0).set_burning(true,Lookup.fire_colors[0])
	$playerAvatar3.get_child(0).load_skin(skin_img, t[0],t[1],t[2],t[3],t[4],t[5])
	$playerAvatar3.get_child(0).set_burning(true,Lookup.fire_colors[1])
	$playerAvatar4.get_child(0).load_skin(skin_img, t[0],t[1],t[2],t[3],t[4],t[5])
	$playerAvatar4.get_child(0).set_burning(true,Lookup.fire_colors[2])
	$playerAvatar5.get_child(0).load_skin(skin_img, t[0],t[1],t[2],t[3],t[4],t[5])
	$playerAvatar5.get_child(0).set_burning(true,Lookup.fire_colors[3])
	$playerAvatar6.get_child(0).load_skin(skin_img, t[0],t[1],t[2],t[3],t[4],t[5])
	$playerAvatar6.get_child(0).set_ghost(true)
	$playerAvatar7.get_child(0).load_skin(skin_img, t[0],t[1],t[2],t[3],t[4],t[5])
	$playerAvatar7.get_child(0).set_burning(true,Lookup.fire_colors[4])
	$playerAvatar8.get_child(0).load_skin(skin_img, t[0],t[1],t[2],t[3],t[4],t[5])
	$playerAvatar8.get_child(0).set_poisoned(true)
	$playerAvatar9.get_child(0).load_skin(skin_img, t[0],t[1],t[2],t[3],t[4],t[5])
	$playerAvatar9.get_child(0).set_cursed(true)
	$playerAvatar10.get_child(0).load_skin(skin_img, t[0],t[1],t[2],t[3],t[4],t[5])
	$playerAvatar10.get_child(0).set_blessed(true)

