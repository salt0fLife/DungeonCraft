extends Node3D
@export var life_time = 30.0
@export var unlimited_life_time = false


func _ready():
	var paths = [
		"res://assets/textures/decals/RB_generic.png",
		"res://assets/textures/decals/RB_impact.png",
		"res://assets/textures/decals/RB_impactDirectional.png",
		"res://assets/textures/decals/RB_puddle1.png",
		"res://assets/textures/decals/RB_puddle2.png",
		"res://assets/textures/decals/RB_smear1.png",
		"res://assets/textures/decals/RB_smear2.png"
	]
	#var s = 1.0 / get_parent().scale.x
	#scale = Vector3(s,s,s)
	var s2 = randf_range(0.5,2.0)
	$Decal.scale = Vector3(s2,s2,s2)
	$Decal.rotation.y = randf_range(0.0,PI*2.0)
	$Decal.texture_albedo = load(paths.pick_random())
	#await get_tree().process_frame
	#if abs(rotation.x) < PI*0.25: #is on ground
		#$Decal.texture_albedo = load("res://assets/textures/decals/RB_mist.png")
		#$Decal.rotation.y = randf_range(0.0,PI*2.0)
	#else: #is on wall
		#$Decal.texture_albedo = load("res://assets/textures/decals/RB_mistWall.png")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if unlimited_life_time:
		return
	life_time -= delta
	if life_time < 0.0:
		queue_free()
