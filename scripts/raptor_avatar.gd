@tool
extends Node3D

@export var animation_key = "walk"
@export var animated = true
@onready var bone_paths = [
	$graphics/root, #0
	$graphics/root/body,
	$graphics/root/body/neck1, #2
	$graphics/root/body/neck1/head,
	$graphics/root/body/neck1/head, #changed bone structure but didnt want to rewrite indexes so made a dupe entry :]
	$graphics/root/body/spine1, #5
	$graphics/root/body/spine1/spine2,
	$graphics/root/body/spine1/spine2/spine3,
	$graphics/root/body/spine1/spine2/spine3/spine4,
	$graphics/root/body/spine1/spine2/spine3/spine4/spine5,
	$graphics/root/body/spine1/spine2/spine3/spine4/spine5/spine6,
	$graphics/root/body/spine1/spine2/spine3/spine4/spine5/spine6/spine7, #1
	$graphics/root/body/spine1/legL,
	$graphics/root/body/spine1/legL/legL2,
	$graphics/root/body/spine1/legL/legL2/legL3,
	$graphics/root/body/spine1/legR,
	$graphics/root/body/spine1/legR/legR2,
	$graphics/root/body/spine1/legR/legR2/legR3,
	$graphics/root/body/armL,
	$graphics/root/body/armL/armL2,
	$graphics/root/body/armL/armL2/armL3,
	$graphics/root/body/armR,
	$graphics/root/body/armR/armR2,
	$graphics/root/body/armR/armR2/armR3
]

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@export var tail_rot = Vector2.ZERO
@export var mult = 1.0
@export var tail_delay = 0.5
@export var crouching = 0.0
var time = 0.0
func _physics_process(delta):
	if time > 64.0*PI:
		time -= 64.0*PI
	if animated:
		match animation_key:
			"walk": walk(delta, mult, tail_rot, tail_delay, crouching)
			"idle": idle(delta, mult, tail_rot, tail_delay, crouching)
	#move_and_slide()

func walk(delta, mult = 1.0, tail_rot = Vector2.ZERO, tail_delay = 0.5, crouching = 0.0, tail_strength = 1.0):
	#bone_paths[0].position.y = sin(time)*0.05*mult
	time += delta * mult
	var bob = sin(time*24.0-PI*0.5)*0.1*mult
	bone_paths[0].position.y = -crouching + bob# + sin(time*16.0)*0.05*mult
	var tail_speed = 1.0#mult
	tail_delay -= mult*0.1
	tail_strength = (2.5 - mult*1.5)*0.25
	
	#body
	bone_paths[5].rotation.y = sin(time*12.0-PI*0.75)*0.1
	bone_paths[5].rotation.x = sin(time*24.0-PI*0.75)*0.2
	bone_paths[1].rotation.y = -sin(time*12.0-PI*0.75)*0.1
	bone_paths[1].rotation.x = -sin(time*24.0-PI*0.75)*0.1
	
	#head
	bone_paths[2].rotation.y = sin(time*12.0-PI*0.75)*0.05
	bone_paths[4].rotation.y = sin(time*12.0-PI*0.75)*0.05
	bone_paths[2].rotation.x = sin(time*24.0-PI*0.75)*0.05 - 1.0
	bone_paths[4].rotation.x = sin(time*24.0-PI*0.75)*0.05 + 1.0
	
	#tail
#	bone_paths[6].rotation.x = sin(time*24.0*tail_speed-PI*0.75-tail_delay*0.1)*0.1*tail_strength
	bone_paths[6].rotation.x = sin(time*24.0*tail_speed+PI*0.5)*0.2*tail_strength
	bone_paths[7].rotation.x = sin(time*24.0*tail_speed+PI*0.5-tail_delay)*0.2*tail_strength
	bone_paths[8].rotation.x = sin(time*24.0*tail_speed+PI*0.5-tail_delay*2.0)*0.2*tail_strength
	bone_paths[9].rotation.x = sin(time*24.0*tail_speed+PI*0.5-tail_delay*3.0)*0.2*tail_strength*1.1
	bone_paths[10].rotation.x = sin(time*24.0*tail_speed+PI*0.5-tail_delay*4.0)*0.2*tail_strength*1.25
	bone_paths[11].rotation.x = sin(time*24.0*tail_speed+PI*0.5-tail_delay*5.0)*0.2*tail_strength*1.5
	
	bone_paths[6].rotation.y = sin(time*12.0*tail_speed-PI*0.5)*0.3*tail_strength
	bone_paths[7].rotation.y = sin(time*12.0*tail_speed-PI*0.5)*0.3*tail_strength
	bone_paths[8].rotation.y = sin(time*12.0*tail_speed-PI*0.75)*0.3*tail_strength
	bone_paths[9].rotation.y = sin(time*12.0*tail_speed-PI)*0.3*tail_strength
	bone_paths[10].rotation.y = sin(time*12.0*tail_speed-PI*1.25)*0.3*tail_strength*1.25
	bone_paths[11].rotation.y = sin(time*12.0*tail_speed-PI*1.5)*0.3*tail_strength*1.5
	
	#idle legs
	bone_paths[12].rotation.x = -0.628319 - (sin(time*tail_speed) * 0.1 + tail_rot.y) + bob*0.5 - crouching*0.5*1.25
	bone_paths[12].rotation.y = (sin(time*tail_speed) * 0.1 + tail_rot.x)*0.2
	bone_paths[12].rotation.z = (sin(time) * 0.1 + tail_rot.x)*0.25#(sin(time*tail_speed) * 0.1 + tail_rot.x)*0.2
	
	bone_paths[13].rotation.x = crouching*1.25 + 0.366519 - bob
	bone_paths[14].rotation.x = -crouching*0.5*1.25 - 0.3228859 + bob * 0.5
	
	
	bone_paths[15].rotation.x = -0.628319 - (sin(time*tail_speed) * 0.1 + tail_rot.y) + bob*0.5 - crouching*0.5*1.25
	bone_paths[15].rotation.y = (sin(time*tail_speed) * 0.1 + tail_rot.x)*0.2
	bone_paths[15].rotation.z = (sin(time) * 0.1 + tail_rot.x)*0.25
	
	bone_paths[16].rotation.x = crouching*1.25 + 0.366519 - bob
	bone_paths[17].rotation.x = -crouching*0.5*1.25 - 0.3228859 + bob * 0.5
	
	#walking legs
	bone_paths[12].rotation.x += (sin(time*12.0-PI*0.5)*0.75+0.25)*mult+0.25
	bone_paths[12].position.y = (sin(time*12.0-PI*1.25)*0.75+0.25)*0.15
	bone_paths[13].rotation.x += (sin(time*12.0-PI)*0.5)*mult
	bone_paths[14].rotation.x += (sin(time*12.0-PI*0.25)*0.5)*mult
	
	
	bone_paths[15].rotation.x += (sin(time*12.0+PI*0.5)*0.75+0.25)*mult+0.25
	bone_paths[15].position.y = (sin(time*12.0-PI*0.25)*0.75+0.25)*0.15
	bone_paths[16].rotation.x += (sin(time*12.0-PI*0.25)*0.5)*mult
	bone_paths[17].rotation.x += (sin(time*12.0+PI*0.5)*0.5)*mult
	
	#bone_paths[15].rotation.x += (sin(time*12.0+PI*0.5)*0.75+0.25)*mult
	#bone_paths[15].position.y = (sin(time*12.0+PI*1.25)*0.75+0.25)*0.15
	#bone_paths[16].rotation.x += (sin(time*12.0+PI*0.25)*0.5)*mult
	#bone_paths[17].rotation.x += (sin(time*12.0+PI*0.5)*0.5)*mult
	
	
	
	#walking arms
	bone_paths[18].rotation.x = (sin(time*12.0+PI*0.5)*0.75+0.25)*mult+0.174533
	bone_paths[19].rotation.x = -(sin(time*12.0+PI*0.5)*0.75+0.25)*mult*0.75+0.296706 +(sin(time*12.0+PI*0.75)*0.3+0.25)-0.2
	bone_paths[20].rotation.x = (sin(time*12.0+PI*0.55)*0.75+0.25)*mult*0.2-0.593412
	
	bone_paths[21].rotation.x = (sin(time*12.0-PI*0.5)*0.75+0.25)*mult+0.174533
	bone_paths[22].rotation.x = -(sin(time*12.0-PI*0.5)*0.75+0.25)*mult*0.75+0.296706 -(sin(time*12.0+PI*0.75)*0.3+0.25)+0.2
	bone_paths[23].rotation.x = (sin(time*12.0-PI*0.55)*0.75+0.25)*mult*0.2-0.593412
	
	#stabalize legs and arms
	bone_paths[18].rotation.x += sin(time*24.0-PI*0.75)*0.1
	bone_paths[21].rotation.x += sin(time*24.0-PI*0.75)*0.1
	bone_paths[12].rotation.x += -sin(time*24.0-PI*0.75)*0.2
	bone_paths[15].rotation.x += -sin(time*24.0-PI*0.75)*0.2
	
	bone_paths[2].rotation.x += mult*0.5
	bone_paths[3].rotation.x -= mult*0.5
	
	pass

func idle(delta, mult = 1.0, tail_rot = Vector2.ZERO, tail_delay = 0.5, crouching = 0.0, tail_strength = 1.0):
	time += delta*mult
	#bone_paths[0].position.y = sin(time)*0.05*mult
	var bob = sin(time*1.0)*0.1 - sin(time*2.0)*mult*0.05
	bone_paths[0].position.y = -crouching + bob# + sin(time*16.0)*0.05*mult
	var tail_speed = 1.0#+mult*3.0
	
	bone_paths[5].rotation.y = 0.0
	bone_paths[5].rotation.x = 0.0
	bone_paths[1].rotation.y = 0.0
	bone_paths[1].rotation.x = 0.0
	
	bone_paths[5].rotation.y = sin(time*tail_speed) * 0.1*tail_strength + tail_rot.x
	bone_paths[6].rotation.y = sin(time*2.0*tail_speed-tail_delay*0.0) * 0.1*tail_strength + tail_rot.x
	bone_paths[7].rotation.y = sin(time*2.0*tail_speed-tail_delay*1.0) * 0.1*tail_strength + tail_rot.x
	bone_paths[8].rotation.y = sin(time*2.0*tail_speed-tail_delay*2.0) * 0.1*tail_strength + tail_rot.x
	bone_paths[9].rotation.y = sin(time*2.0*tail_speed-tail_delay*4.0) * 0.1*tail_strength + tail_rot.x
	bone_paths[10].rotation.y = sin(time*2.0*tail_speed-tail_delay*4.0) * 0.1*tail_strength + tail_rot.x
	bone_paths[11].rotation.y = sin(time*2.0*tail_speed-tail_delay*5.0) * 0.1*tail_strength + tail_rot.x
	
	bone_paths[5].rotation.x = sin(time*tail_speed) * 0.1*tail_strength + tail_rot.y
	bone_paths[6].rotation.x = sin(time*1.5*tail_speed-tail_delay*0.0) * 0.1*tail_strength + tail_rot.y
	bone_paths[7].rotation.x = sin(time*1.5*tail_speed-tail_delay*1.0) * 0.1*tail_strength + tail_rot.y
	bone_paths[8].rotation.x = sin(time*1.5*tail_speed-tail_delay*2.0) * 0.1*tail_strength + tail_rot.y
	bone_paths[9].rotation.x = sin(time*1.5*tail_speed-tail_delay*3.0) * 0.1*tail_strength + tail_rot.y
	bone_paths[10].rotation.x = sin(time*1.5*tail_speed-tail_delay*4.0) * 0.1*tail_strength + tail_rot.y
	bone_paths[11].rotation.x = sin(time*1.5*tail_speed-tail_delay*5.0) * 0.1*tail_strength + tail_rot.y
	
	#idle legs
	bone_paths[12].rotation.x = -0.628319 - (sin(time*tail_speed) * 0.1 + tail_rot.y) + bob*0.5 - crouching*0.5*1.25
	bone_paths[12].rotation.y = (sin(time*tail_speed) * 0.1 + tail_rot.x)*0.2
	bone_paths[12].rotation.z = (sin(time) * 0.1 + tail_rot.x)*0.25#(sin(time*tail_speed) * 0.1 + tail_rot.x)*0.2
	
	bone_paths[13].rotation.x = crouching*1.25 + 0.366519 - bob
	bone_paths[14].rotation.x = -crouching*0.5*1.25 - 0.3228859 + bob * 0.5
	
	
	bone_paths[15].rotation.x = -0.628319 - (sin(time*tail_speed) * 0.1 + tail_rot.y) + bob*0.5 - crouching*0.5*1.25
	bone_paths[15].rotation.y = (sin(time*tail_speed) * 0.1 + tail_rot.x)*0.2
	bone_paths[15].rotation.z = (sin(time) * 0.1 + tail_rot.x)*0.25
	
	bone_paths[16].rotation.x = crouching*1.25 + 0.366519 - bob
	bone_paths[17].rotation.x = -crouching*0.5*1.25 - 0.3228859 + bob * 0.5
