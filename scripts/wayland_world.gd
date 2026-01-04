@tool
extends Node3D
@export var world_noise = FastNoiseLite.new()
@export var world_noise_2 = FastNoiseLite.new()
@export var plains_noise = FastNoiseLite.new()
@export var tree_noise = FastNoiseLite.new()
var world_size = Vector3i(500.0,500.0,20.0) #width,depth,height
var world_scale = 16.0
@export var spider_count := 20
var height = []
var hm = HeightMapShape3D.new()
@onready var chunks = $chunkHandler.get_children(false)

func _ready():
	var img = world_noise.get_image(int(world_size.x),int(world_size.y))
	var img2 = world_noise_2.get_image(int(world_size.x),int(world_size.y))
	var plains = plains_noise.get_image(int(world_size.x),int(world_size.y))
	settup_collision(img,img2,plains)
	settup_mat(img,img2,plains)
	$ground_handler.scale = Vector3(world_scale,world_scale,world_scale)
	print("spawn_height = " + str(get_height_from_pos(Vector2(0.0,0.0))))
	for i in range(0,chunks.size()):
		var c = chunks[i]
		c.update_from_pos(Vector2i(i,0))
	pass

func settup_collision(img,img2,plains):
	hm = HeightMapShape3D.new()
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

func get_height_from_pos(pos : Vector2) -> float:
	var og_pos = pos
	pos = pos / world_scale #make applicable
	pos = pos - Vector2(world_size.x,world_size.y)*0.5
	pos = Vector2i(int(pos.x),int(pos.y))
	var w_n = world_noise.get_noise_2d(pos.x,pos.y)
	var w_n_2 = world_noise_2.get_noise_2d(pos.x,pos.y)
	var p_n = plains_noise.get_noise_2d(pos.x,pos.y)
	var height = 0
	height = w_n
	height -= 0.5
	height = lerp(height,0.0,p_n)
	height -= p_n
	height *= world_size.z
	return height * world_scale

func get_rounded_height_from_pos(pos : Vector2) -> float:
	var og_pos = pos
	pos = pos / world_scale #make applicable
	pos = pos - Vector2(world_size.x,world_size.y)*0.5
	if pos.x > float(world_size.x):
		return 0.0
	elif pos.y > float(world_size.y):
		return 0.0
	var i = int(pos.x) + (int(pos.y)*world_size.x) #returns closest point, in future maybe lerp between two closest points for better accuracy
	#assert(i < hm.map_data.size() and i > -1, "i is valid index")
	var x_d = abs(og_pos.x - int(og_pos.x))
	var y_d = abs(og_pos.y - int(og_pos.y))
	var height = hm.map_data[i]*world_scale
	if x_d > 0.0:
		var height_x_2 = hm.map_data[i+1]*world_scale
		#height = lerp(height,height_x_2,1.0)
		height -= lerp(0.0,abs(height-height_x_2),x_d) #interpolates for fraction if applicable
	if x_d > 0.0:
		var height_y_2 = hm.map_data[i+world_size.x]*world_scale
		#height = lerp(height,height_y_2,1.0)
		height -= lerp(0.0,abs(height-height_y_2),y_d) #interpolates for fraction if applicable
	return height

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
	mat.set("shader_parameter/terrain_scale",world_scale)
	pass

@export var camera_chunk = Vector2i.ZERO
func _process(delta):
	#var cam_pos = (get_viewport().get_camera_3d().global_position/ world_scale)*0.015625
	#var cam_chunk = Vector2i(int(cam_pos.x),(cam_pos.y))
	
	
	pass
