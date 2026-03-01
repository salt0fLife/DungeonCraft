extends Node3D
var world_seed = 0
var generated = false

# Called when the node enters the scene tree for the first time.
func _ready():
	if is_multiplayer_authority() or Engine.is_editor_hint():
		world_seed = randi()
		generate_world_from_seed(world_seed)
		#generated = true
		#print("world seed : " + str(world_seed))
		#$mazeGenerator.create_from_seed(world_seed)
	else:
		print("rpc before")
		print(rpc_id(1,"request_seed"))
		print("rpc after")
		#print("recieved : " + str(world_seed))
		pass
	


@rpc("any_peer","reliable")
func request_seed():
	if is_multiplayer_authority():
		print("sent world of ( " + str(world_seed) + " ), as : " + str(get_multiplayer_authority()))
		generate_world_from_seed.rpc(world_seed)

@rpc("authority","reliable",)
func generate_world_from_seed(seed:int):
	if generated:
		return #dont want to do that twice
	print("generating world from")
	world_seed = seed
	generated = true
	$mazeGenerator.create_from_seed(world_seed)
	
	$VoxelGI.bake()
