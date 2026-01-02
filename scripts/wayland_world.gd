@tool
extends Node3D
@export var world_noise = FastNoiseLite.new()
@export var world_noise_2 = FastNoiseLite.new()
@export var plains_noise = FastNoiseLite.new()
var world_size = Vector3i(500.0,500.0,20.0) #width,depth,height
var world_scale = 4.0

func _ready():
	var img = world_noise.get_image(int(world_size.x),int(world_size.y))
	var img2 = world_noise_2.get_image(int(world_size.x),int(world_size.y))
	var plains = plains_noise.get_image(int(world_size.x),int(world_size.y))
	settup_collision(img,img2,plains)
	settup_mat(img,img2,plains)
	$ground_handler.scale = Vector3(world_scale,world_scale,world_scale)
	pass

func settup_collision(img,img2,plains):
	var hm = HeightMapShape3D.new()
	img.convert(Image.FORMAT_RF)
	img2.convert(Image.FORMAT_RF)
	plains.convert(Image.FORMAT_RF)
	hm.map_width = img.get_width()
	hm.map_depth = img.get_height()
	var data = img.get_data().to_float32_array()
	var data2 = img2.get_data().to_float32_array()
	var plains_data = plains.get_data().to_float32_array()
	for i in range(0,data.size()):
		data[i] += data2[i]
		data[i] -= 1.0
		data[i] = lerp(data[i],0.0,plains_data[i])
		data[i] -= plains_data[i]
		data[i] *= world_size.z
	hm.map_data = data
	$ground_handler/StaticBody3D/CollisionShape3D.shape = hm

func settup_mat(img,img2,plains):
	var mat = $ground_handler/MeshInstance3D.get_active_material(0)
	#var img = world_noise.get_image(int(world_size.x),int(world_size.y))
	var tex = ImageTexture.create_from_image(img)
	var tex2 = ImageTexture.create_from_image(img2)
	var plains_tex = ImageTexture.create_from_image(plains)
	mat.set("shader_parameter/height_map",tex)
	mat.set("shader_parameter/height_map_2",tex2)
	mat.set("shader_parameter/plains_map",plains_tex)
	mat.set("shader_parameter/height_strength",world_size.z)
	pass
