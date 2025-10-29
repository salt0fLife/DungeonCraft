extends Node3D

@onready var avatar = get_parent().get_parent().get_child(0)
@onready var chest = avatar.bone_paths[0]
@onready var bone_paths =[
	$base,
	$base/arm1R,
	$base/arm1R/arm2R,
	$base/arm1R/arm2R/arm3R,
	$base/arm1R/arm2R/arm3R/arm4R,
	$base/arm1R/arm2R/arm3R2,
	$base/arm1R/arm2R/arm3R3,
	$base/arm1R2,
	$base/arm1R2/arm2R,
	$base/arm1R2/arm2R/arm3R,
	$base/arm1R2/arm2R/arm3R/arm4R,
	$base/arm1R2/arm2R/arm3R2,
	$base/arm1R2/arm2R/arm3R3
]
var animation_state = "idle"
var time = 0.0
@export var animated = true
@export var animation_speed = 1.0
@export var open = 0.0
@export var flapping = 0.0
@export var flapping_speed = 1.0
@export var base_rot = Vector3.ZERO

func _process(delta):
	if time > 64.0 * PI:
		time -= 64.0*PI
	global_position = chest.global_position
	rotation = chest.rotation * Vector3(-1.0,1.0,-1.0) + Vector3(0.0, chest.get_parent().rotation.y,0.0)
	open = avatar.falling*0.5
	flapping = avatar.walk_speed * 0.1
	animation_speed = avatar.walk_speed*0.15+0.75
	if avatar.animation_state == "fly":
		flapping = 1.0 - avatar.crouching*2.0
		open = 1.2
	if animated:
		match animation_state:
			"idle": idle(delta)

func idle(delta):
	var con_open = open
	var con_rot = base_rot
	if con_open > 1.0:
		con_rot.z -= (1.0-con_open)*0.5
		con_open = 1.0
	time += delta * animation_speed
	bone_paths[1].rotation = Vector3(0.0, sin(time)*0.05, cos(time)*0.025+con_open) + con_rot  + Vector3(0.0,cos(time*flapping_speed*8.0)*flapping*0.5-flapping*0.2,cos(time*flapping_speed*8.0-PI)*PI*flapping*0.25+flapping*0.05)#Vector3(cos(time*flapping_speed*8.0+PI*flapping)*PI*flapping*0.5-flapping*2.0,-cos(time*flapping_speed*8.0+PI*flapping)*PI*flapping*4.0-flapping*7.0,cos(time*flapping_speed*8.0+PI*2.0)*PI*flapping*4.0+flapping)
	bone_paths[2].rotation = Vector3(0.0, sin(time-PI*0.5)*0.05, cos(time-PI*0.5)*0.025-con_open*1.5) + Vector3(0.0,0.0,cos(time*flapping_speed*8.0-PI*1.75)*PI*flapping*0.25+flapping*0.25)#Vector3(cos(time*flapping_speed*8.0+PI*flapping)*PI*flapping*4.0-flapping*7.0,flapping*7.0,cos(time*flapping_speed*8.0+PI*1.5)*PI*flapping*2.0+flapping)
	bone_paths[3].rotation = Vector3(0.0, sin(time-PI*0.75)*0.05, cos(time-PI*0.75)*0.025+con_open*1.25) + Vector3(0.0,0.0,cos(time*flapping_speed*8.0-PI*1.7)*PI*flapping*0.2+flapping*0.05)
	bone_paths[4].rotation = Vector3(0.0, sin(time-PI)*0.05, cos(time-PI)*0.025+con_open*0.5) + Vector3(0.0,0.0,cos(time*flapping_speed*8.0-PI*1.68)*PI*flapping*0.05+flapping*0.05)
	bone_paths[5].rotation = bone_paths[3].rotation*0.6
	bone_paths[6].rotation = bone_paths[3].rotation*0.3
	
	bone_paths[7].rotation = -Vector3(0.0, sin(time)*0.05, cos(time)*0.025+con_open) - con_rot  - Vector3(0.0,cos(time*flapping_speed*8.0)*flapping*0.5-flapping*0.2,cos(time*flapping_speed*8.0-PI)*PI*flapping*0.25+flapping*0.05)#Vector3(cos(time*flapping_speed*8.0+PI*flapping)*PI*flapping*0.5-flapping*2.0,-cos(time*flapping_speed*8.0+PI*flapping)*PI*flapping*4.0-flapping*7.0,cos(time*flapping_speed*8.0+PI*2.0)*PI*flapping*4.0+flapping)
	bone_paths[8].rotation = -Vector3(0.0, sin(time-PI*0.5)*0.05, cos(time-PI*0.5)*0.025-con_open*1.5) - Vector3(0.0,0.0,cos(time*flapping_speed*8.0-PI*1.75)*PI*flapping*0.25+flapping*0.25)#Vector3(cos(time*flapping_speed*8.0+PI*flapping)*PI*flapping*4.0-flapping*7.0,flapping*7.0,cos(time*flapping_speed*8.0+PI*1.5)*PI*flapping*2.0+flapping)
	bone_paths[9].rotation = -Vector3(0.0, sin(time-PI*0.75)*0.05, cos(time-PI*0.75)*0.025+con_open*1.25) - Vector3(0.0,0.0,cos(time*flapping_speed*8.0-PI*1.7)*PI*flapping*0.2+flapping*0.05)
	bone_paths[10].rotation = -Vector3(0.0, sin(time-PI)*0.05, cos(time-PI)*0.025+con_open*0.5) - Vector3(0.0,0.0,cos(time*flapping_speed*8.0-PI*1.68)*PI*flapping*0.05+flapping*0.05)
	bone_paths[11].rotation = -bone_paths[3].rotation*0.6
	bone_paths[12].rotation = -bone_paths[3].rotation*0.3
	pass
