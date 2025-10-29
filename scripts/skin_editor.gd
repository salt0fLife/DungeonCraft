extends Control
@onready var preview = $Control/preview
var texture: ImageTexture
var image: Image
var drawing = false
@onready var avatar = $SubViewport/rotationBase/playerAvatar/genericAvatar
@onready var rotBase = $SubViewport/rotationBase
var ears = 0
var tail = 0
var snout = 0
var slim = false

var skin_key = "custom1"

func generate_base_image():
	print("created image")
	#texture = ImageTexture.create_from_image(Image.create(64, 64, true, Image.FORMAT_RGBA8))#Image.load_from_file(defaultSkin_path)
	var file = FileAccess.open("res://defaultSkinInfo.txt", FileAccess.READ)
	var skinInfo = file.get_var()
	file.close()
	texture = Global.data_to_image(skinInfo["skin"])
	image = texture.get_image()
	#image.fill(Color.BLACK)
	texture.update(image)
	#return texture

func _ready():
	skin_key = "custom" + str(Global.get_skin_list().size())
	generate_base_image()
	preview.texture = texture
	update_avatar()
	_on_color_picker_button_color_changed(Color.WHITE)

func _input(event):
	if Input.is_action_just_pressed("lm"):
		drawing = true
	if Input.is_action_just_released("lm"):
		drawing = false

@export var color_1 = Color.WHITE
func _process(delta):
	if drawing:
		var pos = get_viewport().get_mouse_position() / Vector2(5.0,5.0)
		if pos.x > 128 or pos.y > 128:
			return
		image.set_pixel(pos.x,pos.y, color_1)
		push_changes()
		pass

func push_changes():
	texture.update(image)
	pass

func _on_rotation_value_changed(value):
	rotBase.rotation.y = value
	pass # Replace with function body.

func _on_color_picker_button_color_changed(color):
	color_1 = color

func _on_walking_toggled(toggled_on):
	if toggled_on:
		avatar.animation_state = "walk"
	else:
		avatar.animation_state = "idle"
	pass # Replace with function body.

func update_avatar():
	avatar.load_skin(texture, ears, tail, snout, slim, eyeColors, mouthInfo)
	pass

func _on_save_button_down():
	save_skin_info()
	pass # Replace with function body.

func save_skin_info():
	var data = image.get_data()
	var format = image.get_format()
	var x = image.get_width()
	var y = image.get_height()
	var mip = image.has_mipmaps()
	Global.skin = [x,y,mip,format,data]
	Global.eyeColor = eyeColors
	Global.mouthInfo = mouthInfo
	Global.slim = slim
	var info = {
		"skin" : Global.skin,
		"ears" : Global.ears,
		"tail" : Global.tail,
		"snout" : Global.snout,
		"slim" : Global.slim,
		"eyeColor" : Global.eyeColor,
		"mouthInfo" : Global.mouthInfo,
		"display_name" : Global.display_name
	}
	save_file("skins/", skin_key, info)
	pass

func save_file(subFolder : String, fileName : String, data) -> void:
	if !DirAccess.dir_exists_absolute(Global.savePath+subFolder):
		DirAccess.make_dir_recursive_absolute(Global.savePath+subFolder)
	var path = Global.savePath+subFolder+fileName
	var file = FileAccess.open(path, FileAccess.WRITE)
	file.store_var(data)
	file.close()
	print("saved " + fileName)

func _on_option_button_item_selected(index):
	print("index")
	match  index:
		0: "custom1"
		1: "custom2"
		2: "custom3"
	pass # Replace with function body.

func _on_exit_button_down():
	save_skin_info()
	get_parent().update_skins()
	queue_free()

func _on_button_button_down():
	queue_free()

func _on_rotation_2_value_changed(value):
	rotBase.rotation.x = value
	pass # Replace with function body.

func _on_tail_toggled(toggled_on):
	tail = toggled_on
	update_avatar()

func _on_ears_toggled(toggled_on):
	ears = toggled_on
	update_avatar()

func _on_snout_toggled(toggled_on):
	snout = toggled_on
	update_avatar()

func _on_slim_toggled(toggled_on):
	slim = toggled_on
	update_avatar()

var eyeColors = [Color.BLACK, Color.DARK_RED, Color.RED, Color.WHITE, Color.BLACK]

func _on_set_eye_color_button_down():
	eyeColors[0] = $eyeColor1.color
	eyeColors[1] = $eyeColor2.color
	eyeColors[2] = $eyeColor3.color
	eyeColors[3] = $eyeColor4.color
	eyeColors[4] = $eyeColor5.color
	update_avatar()
	
	pass # Replace with function body.

var mouthInfo = [0.0,0.0,Color.BLACK, Color.BROWN, Color.RED]
func _on_apply_mouth_button_down():
	mouthInfo[0] = $smile.value
	mouthInfo[1] = $OWO.value
	mouthInfo[2] = $mouth1.color
	mouthInfo[3] = $mouth2.color
	mouthInfo[4] = $mouth3.color
	update_avatar()
	pass # Replace with function body.
