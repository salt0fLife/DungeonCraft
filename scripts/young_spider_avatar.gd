@tool
extends Node3D
@onready var bone_paths = [
	$root, #0
	$root/body, #1
	$root/body/torso, #2
	$root/body/abdomen, #3
	$root/body/head, #4
	
	#legs
	$root/body/torso/leg_base/leg, #1  #5
	$root/body/torso/leg_base2/leg5, #2
	$root/body/torso/leg_base3/leg6, #3
	$root/body/torso/leg_base4/leg7, #4 
	$root/body/torso/leg_base5/leg8, #5
	$root/body/torso/leg_base6/leg2, #6
	$root/body/torso/leg_base7/leg3, #7
	$root/body/torso/leg_base8/leg4, #8
	
	#knees1
	$root/body/torso/leg_base/leg/knee, #1 #13
	$root/body/torso/leg_base2/leg5/knee, #2 
	$root/body/torso/leg_base3/leg6/knee,#3
	$root/body/torso/leg_base4/leg7/knee, #4
	$root/body/torso/leg_base5/leg8/knee, #5
	$root/body/torso/leg_base6/leg2/knee, #6
	$root/body/torso/leg_base7/leg3/knee, #7
	$root/body/torso/leg_base8/leg4/knee, #8
	
	#knees2
	$root/body/torso/leg_base/leg/knee/knee2, #1 #21
	$root/body/torso/leg_base2/leg5/knee/knee2, #2
	$root/body/torso/leg_base3/leg6/knee/knee2, #3
	$root/body/torso/leg_base4/leg7/knee/knee2, #4
	$root/body/torso/leg_base5/leg8/knee/knee2, #5
	$root/body/torso/leg_base6/leg2/knee/knee2, #6
	$root/body/torso/leg_base7/leg3/knee/knee2, #7
	$root/body/torso/leg_base8/leg4/knee/knee2, #8
]



@export var animated = true
@export var animation_state = "walk"

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if !animated:
		return
	match animation_state:
		"walk": walk(delta)
		"RESET" : reset()
	pass

@export var leg_angle = 0.0
@export var step_height = 1.0
@export var joint_angle = 0.0
@export var leg_individuality = 0.0
@export var stand = 0.0
@export var bounce_strength = 0.0
@export var joint_step_mult = 0.0
@export var joint_delay = 0.0
@export var lean = 0.0
@export var mult = 1.0
@export var speed = 1.0
var time = 0.0
func walk(delta):
	time += delta * speed
	if time > PI*64.0:
		time -= PI*64.0
	var height = stand + sin(time*4.0)*bounce_strength* (mult*0.75+0.25)
	var tilt = lean * sin(time*3.0)*bounce_strength + sin(time*22.0)*0.015
	bone_paths[1].position.y = height + 0.2*mult + 0.2
	bone_paths[4].rotation.y = sin(time*8.0)*bounce_strength* (mult*0.75+0.25)
	bone_paths[3].rotation.y = sin(time*8.0+PI*0.9)*bounce_strength*0.75* (mult*0.75+0.25)
	bone_paths[3].rotation.x = sin(time*4.0+PI*0.25)*bounce_strength*0.75 - PI*0.1
	bone_paths[1].rotation.z = tilt
	for i in range(0,8):
		var offset = 0.0
		if (i+1)%2 == 0:
			offset = PI
		var invert = i > 3
		bone_paths[i+5].rotation.z = sin(time*8.0+offset+i*PI*leg_individuality)*0.5*step_height*mult + leg_angle + height*PI
		bone_paths[i+13].rotation.z = sin(time*8.0+offset+i*PI*leg_individuality-PI*joint_delay)*0.5*joint_step_mult*mult + PI * joint_angle - height*0.5*PI
		bone_paths[i+21].rotation.z = sin(time*8.0+offset+i*PI*leg_individuality-PI*joint_delay*2.0)*0.5*joint_step_mult*mult + PI * joint_angle - height*0.5*PI
		if invert:
			bone_paths[i+5].rotation.y = sin(time*8.0+offset-PI*0.5+i*PI*leg_individuality)*0.5*mult
			bone_paths[i+5].rotation.z -= tilt
		else:
			bone_paths[i+5].rotation.y = sin(time*8.0+offset+PI*0.5+i*PI*leg_individuality)*0.5*mult + PI
			bone_paths[i+5].rotation.z += tilt
		bone_paths[i+5].rotation.y += sin(time*33.0 + i*5.0)*0.05 * mult
		bone_paths[i+5].rotation.z += sin(time*40.0 + i*5.0)*0.025 * mult
	pass

func reset():
	for i in range(0,8):
		var offset = 0.0
		if (i+1)%2 == 0:
			offset = PI
		var invert = i > 3
		bone_paths[i+5].rotation.z = 0.0
		if invert:
			bone_paths[i+5].rotation.y = 0.0
		else:
			bone_paths[i+5].rotation.y = PI
	pass

@onready var meshes = [
	$root/body/torso/MeshInstance3D,
	$root/body/torso/leg_base/leg/knee/MeshInstance3D2,
	$root/body/abdomen/MeshInstance3D,
	$root/body/head/MeshInstance3D,
	$root/body/head/MeshInstance3D2
	
	
]

var skin_path = "res://assets/materials/generic_entity_mat.tres"
var mat = null
var fire_mat = null
func _ready():
	mat = load(skin_path).duplicate()
	for n in meshes:
		n.set_surface_override_material(0,mat)
	fire_mat = $fire.get_active_material(0).duplicate()
	$fire.set_surface_override_material(0,fire_mat)

func set_ghost(val: bool) -> void:
	if !val:
		mat.set("shader_parameter/ghostly", 0.0)
	else:
		mat.set("shader_parameter/ghostly", 1.0)
	pass

func set_burning(val : bool,col := Color.ORANGE_RED) -> void:
	mat.set("shader_parameter/burning", val)
	mat.set("shader_parameter/fire_col", col)
	$fire.visible = val
	fire_mat.set("shader_parameter/fire_col", col)
	$fire_light.visible = val
	$fire_light.light_color = col

func set_poisoned(val) -> void:
	mat.set("shader_parameter/poisoned", val)
	$"poison particles".emitting = val
	pass

func set_cursed(val) -> void:
	mat.set("shader_parameter/cursed", val)
	pass

func set_blessed(val: bool) -> void:
	mat.set("shader_parameter/blessed", val)
	$holyParticles.emitting = val
	$aura.visible = val

