@tool
extends Node3D
@onready var bone_paths = [
	$root/chestBase,
	$root/chestBase/hip_L, #1
	$root/chestBase/hip_L/knee_L, #2
	$root/chestBase/hip_R, #3
	$root/chestBase/hip_R/knee_R, #4
	$root/chestBase/neck,
	$root/chestBase/shoulder_L, #6
	$root/chestBase/shoulder_L/elbowL, #7
	$root/chestBase/shoulder_R, #8
	$root/chestBase/shoulder_R/elbowR, #9
	$root/chestBase/tailBase,
	$root/chestBase/tailBase/tailMiddle,
	$root/chestBase/tailBase/tailMiddle/tailLast,
	$root/chestBase/neck/eyeBrows_L,
	$root/chestBase/neck/eyeBrows_R
	#$root/chestBase/torso,
	#$root/chestBase/torso/hip_L,
	#$root/chestBase/torso/hip_L/leftLeg1/knee_L, #2
	#$root/chestBase/torso/hip_R,
	#$root/chestBase/torso/hip_R/rightLeg1/knee_R, #4
	#$root/chestBase/torso/neck, #5
	#$root/chestBase/torso/shoulder_L,
	#$root/chestBase/torso/shoulder_L/leftArm1/elbowL, #7
	#$root/chestBase/torso/shoulder_R,
	#$root/chestBase/torso/shoulder_R/rightArm1/elbowR, #9
	#$root/chestBase/torso/tailBase, #10
	#$root/chestBase/torso/tailBase/tail/tailMiddle, # 11
	#$root/chestBase/torso/tailBase/tail/tailMiddle/tail_001/tailLast #12
]

const bone_names = [
	"torso",
	"hip_L",
	"knee_L",
	"hip_R",
	"knee_R",
	"neck",
	"shoulder_L",
	"elbowL",
	"shoulder_R",
	"elbowR",
	"tail",
	"tail_001",
	"tail_002",
	"eyebrows_L",
	"eyebrows_R"
]

const x_y_rot_only = [
	5, 11, 12
]

const x_rot_only = [
	2, 4, 7, 9
]

const pos_and_rot_only = [
	0, 1, 3, 6, 8, 10
]

@onready var a_pose = load_file("player_poses/", "a_pose.dat")
@onready var arm_test = load_file("player_poses/", "test.dat")
#const default_pose = 

# Called when the node enters the scene tree for the first time.
func _ready():
	#save_pose_transforms()
	#apply_pose(arm_test)
	pass # Replace with function body.

@export var save_pose = false
@export var pose_name = "pose001"
@export var folder_name = "poseTesting"
@export var apply_load_pose = false

func save_pose_transforms():
	var pose = {}
	for pr in pos_and_rot_only:
		var bone = bone_paths[pr]
		var t = [bone.position, bone.rotation]
		pose[bone_names[pr]] = t
	for rxy in x_y_rot_only:
		var bone = bone_paths[rxy]
		var r = Vector2(bone.rotation.x, bone.rotation.y)
		pose[bone_names[rxy]] = r
	for rx in x_rot_only:
		var bone = bone_paths[rx]
		var r = bone.rotation.x
		pose[bone_names[rx]] = r
	save_file("player_poses/" + folder_name + "/", pose_name + ".dat", pose)

func apply_pose(pose):
	for i in range(0, bone_names.size()):
		var k = bone_names[i]
		if pose.has(k):
			var a = 10
			match typeof(pose[k]):
				TYPE_FLOAT: 
					bone_paths[i].rotation.x = pose[k]
					print(k + " x rot set too " + str(pose[k]))
				TYPE_VECTOR2:
					var rot = pose[k]
					bone_paths[i].rotation.x = rot.x
					bone_paths[i].rotation.y = rot.y
					print(k + " x and y rot set too " + str(pose[k]))
				TYPE_ARRAY:
					var t = pose[k]
					bone_paths[i].position = t[0]
					bone_paths[i].rotation = t[1]
					print(k + " pos and rot set too " + str(pose[k]))
	print("applied " + str(pose))

@export var animation_state = "idle"
@export var animated = true
@export var walk_speed = 1.0
@export var animation_speed = 1.0
@export var walk_angle = 0.0
@export var walk_tilt = 0.0
@export var crouching = 0.0
@export var head_angle = Vector2(0.0,0.0)
@export var idle_energy = 1.0
@export var falling = 0.0

@export var eye_lids = Vector2(0.5,0.5)
@export var eye_pos = Vector2(0.0,0.0)
@export var eye_taper = 0.0
@export var eye_scale = 1.0
@export var blink = 0.0
@export var time_between_blinks = 10.0
@export var blink_speed = 20.0

var eye_rot = Vector2.ZERO

# Called every frame. 'delta' is the elapsed time since the previous frame.
var time = 0.0
var blink_time = 0.0
func _process(delta):
	if time > 64.0 * PI:
		time -= 64.0*PI
	if animated:
		match animation_state:
			"walk":
				walk(delta, walk_speed, animation_speed, walk_angle, walk_tilt, crouching, head_angle, falling, stride_mult)
			"idle":
				idle(delta, idle_energy, walk_tilt, crouching, head_angle, falling)
			"fly":
				fly(delta, animation_speed, crouching, head_angle, walk_angle, walk_speed)
				pass
		handle_arm_anims(delta)
	if save_pose:
		save_pose_transforms()
		save_pose = false
	if apply_load_pose:
		var pose = load_file("player_poses/" + folder_name + "/", pose_name + ".dat")
		if pose != null:
			apply_pose(pose)
		apply_load_pose = false
	pass

func idle(delta, energy, tilt, crouch, head_angle, fall):
	tilt += crouch*6.0 * 3.1 * (2.0/3.0)
	if head_angle.x > 0.0:
		tilt += head_angle.x
		eye_lids = Vector2(1.05, 0.32)
	else:
		eye_lids = Vector2(1.05+head_angle.x*0.35, 0.32)
		tilt += head_angle.x * 0.1
	time += delta * (energy + fall*4.0)
	bone_paths[0].position.y = sin(time*2.0)*0.01*energy-0.01*energy - abs(tilt*0.05) - crouch * 0.25 + fall*0.1
	bone_paths[0].position.x = sin(time*1.0+PI*0.5)*0.005*energy
	bone_paths[0].rotation.x = tilt * 0.25
	bone_paths[0].rotation.y = head_angle.y * (1.0/3.0)
	bone_paths[0].rotation.z = 0.0
	bone_paths[1].rotation.x = -tilt*0.5*energy + sin(time*2.0)*0.03*energy-0.03 - head_angle.y * 0.05 - falling*0.5
	bone_paths[1].rotation.y = energy*0.1 - head_angle.y * 0.1 + falling*0.5
	bone_paths[1].rotation.z = abs(tilt * head_angle.y)*0.03
	bone_paths[1].position = Vector3(0.075, -0.282, -0.001)
	bone_paths[2].rotation.x = tilt*0.25*energy - sin(time*2.0)*0.03*energy-0.03 + energy * 0.1 + abs(head_angle.y * 0.05) + falling*0.75
	bone_paths[3].rotation.x = -tilt*0.5*energy + sin(time*2.0)*0.03*energy-0.03 + head_angle.y * 0.05 - falling * 0.2
	bone_paths[3].rotation.y =  -energy*0.1 - head_angle.y * 0.1 - falling * 0.25
	bone_paths[3].rotation.z = -abs(tilt * head_angle.y)*0.03
	bone_paths[3].position = Vector3(-0.075, -0.282, -0.001)
	bone_paths[4].rotation.x = tilt*0.25*energy - sin(time*2.0)*0.03*energy-0.03 + energy * 0.1 + abs(head_angle.y * 0.05) + falling*0.3
	bone_paths[5].rotation.x = -tilt * 0.25 + head_angle.x * (2.0/3.0) + abs((head_angle.y * crouch))
	bone_paths[5].rotation.y = head_angle.y * (2.0/3.0) * 0.5 ## edited for eyes
	bone_paths[6].rotation.y = -sin(time*1.0)*0.005*energy + falling*0.5
	bone_paths[6].rotation.z = -sin(time*1.0)*0.025*energy + 0.03* (energy + falling*20.0)
	bone_paths[6].rotation.x = sin(time*2.0)*0.025*energy - 0.03*(energy + falling*10.0)
	bone_paths[7].rotation.x = -sin(time*2.0+PI*0.5)*0.04*energy - 0.06*(energy + falling*20.0)
	bone_paths[8].rotation.y = sin(time*1.0)*0.005*energy - falling*0.5
	bone_paths[8].rotation.z = sin(time*1.0)*0.025*energy - 0.03*(energy + falling*20.0)
	bone_paths[8].rotation.x = sin(time*2.0)*0.025*energy - 0.03*(energy + falling*10.0)
	bone_paths[9].rotation.x = -sin(time*2.0+PI*0.5)*0.04*energy - 0.06*(energy + falling*20.0)
	bone_paths[10].rotation.x = sin(time*1.5)*0.1 - 1.06465
	bone_paths[10].rotation.y = sin(time*1.5)*0.5* (energy + (1.0-energy)*0.5) + head_angle.y * 0.25
	bone_paths[11].rotation.y = -sin(time*1.5+PI*0.33)*0.33*(energy + (1.0-energy)*0.5)
	bone_paths[12].rotation.y = -sin(time*1.5+PI*0.33)*0.25*(energy + (1.0-energy)*0.5)
	## eyes
	eye_pos.y = head_angle.x * 0.5
	eye_pos.x = head_angle.y * 0.5
	blink_time += delta * blink_speed
	if blink_time > time_between_blinks*blink_speed:
		blink_time -= time_between_blinks * blink_speed
	if blink_time < PI:
		blink = sin(blink_time)
	else:
		blink = 0.0
	eye_rot = eye_pos
	eye_lids = lerp(eye_lids, Vector2(2.0,0.0), blink)
	set_eye_param("shader_parameter/eyePos", eye_pos)
	set_eye_param("shader_parameter/eyeLids", eye_lids)
	set_eye_param("shader_parameter/eyeTaper", eye_taper)
	set_eye_param("shader_parameter/eyeScale", eye_scale)
	##
	pass


##arm_overide_animations
@export var arm_override_anim = ""
@export var arm_anim_speed = 1.0
var arm_anim_time = 0.0

func handle_arm_anims(delta):
	match arm_override_anim:
		"":
			arm_anim_time = 1.0
		"punch":
			arm_punch(delta)
		"wave":
			arm_wave(delta)
		"point":
			arm_point(delta)
	pass

func play_arm_anim(key : String) -> void:
	arm_anim_time = 1.0
	arm_override_anim = key

func arm_point(delta):
	bone_paths[8].rotation.x = head_angle.x -1.5
	bone_paths[6].rotation.z += abs(head_angle.x)*0.2
	bone_paths[1].rotation.z += clamp(abs(head_angle.x)*0.15,0.0,0.1)
	bone_paths[3].rotation.z -= clamp(abs(head_angle.x)*0.15,0.0,0.1)
	bone_paths[0].rotation.y += 0.2
	bone_paths[1].rotation.y -= 0.2
	bone_paths[3].rotation.y -= 0.2
	bone_paths[5].rotation.y -= 0.2
	if !animation_state == "walk":
		bone_paths[8].rotation.y = head_angle.y*0.75 -0.2
	else:
		bone_paths[8].rotation.y = -head_angle.y*0.75 - walk_angle*0.5 -0.2
	bone_paths[9].rotation.x *= 0.1
	pass

func arm_wave(delta):
	arm_anim_time -= delta*0.65
	if arm_anim_time < 0.0:
		arm_anim_time += 1.0
	bone_paths[8].rotation.x = PI+(sin(arm_anim_time*PI*2.0)+1.0)*0.1
	bone_paths[9].rotation.x = -0.1-(sin(arm_anim_time*PI*2.0+1.1)+1.0)*0.1
	bone_paths[8].rotation.z = sin(arm_anim_time*PI*4.0)*0.5-0.2
	bone_paths[0].rotation.z += -sin(arm_anim_time*PI*2.0)*0.025-0.1
	bone_paths[0].position.x = sin(arm_anim_time*PI*2.0)*0.01+0.005
	bone_paths[1].rotation.z += sin(arm_anim_time*PI*2.0)*0.025+0.1
	bone_paths[3].rotation.z += sin(arm_anim_time*PI*2.0)*0.025+0.1
	bone_paths[6].rotation.z += sin(arm_anim_time*PI*2.0)*0.025+0.1
	pass

func arm_punch(delta):
	arm_anim_time -= delta * 4.0 * arm_anim_speed
	bone_paths[8].rotation.x += -sin(arm_anim_time*PI)*1.25
	bone_paths[8].rotation.y += -sin(arm_anim_time*PI-PI*0.5)*0.34-0.1
	bone_paths[9].rotation.x += -sin(arm_anim_time*PI-PI*0.25)*0.25-0.25
	if arm_anim_time < 0.0:
		arm_override_anim = ""
		arm_anim_time = 1.0
## end of arm_anims


func force_blink():
	blink_time = 0.0
	pass

signal step

var right_stepped = false
#var leg_bones = [1,2,3,4]
@export var stride_mult = 1.0
func walk_old(delta, mult = 1.0, speed = 1.0, angle = 0.0, tilt_in = 0.0, crouching = 0.0, head_angle = Vector2(0.0,0.0), fall = 0.0):
	time += delta * (mult + (1.0-mult)*0.9) * speed
	if mult > 3.0:
		mult = 3.0
	head_angle.x = head_angle.x * 0.8
	var tilt = tilt_in * mult + sin(time*16+0.1)*0.05*(abs(mult)-0.8) + 0.05*(abs(mult)-0.8)
	bone_paths[0].position.z = sin(time*16-PI*0.5)*0.002*mult - crouching*0.5
	bone_paths[0].position.y = sin(time*16)*0.006*pow(mult+crouching,2) - 0.2*abs(tilt) - crouching*1.1 - abs(head_angle.x * 0.025) + falling*0.1
	bone_paths[0].rotation.x = tilt + crouching * 3.0 + head_angle.x*(1.0/3.0)
	bone_paths[0].rotation.y = (angle-head_angle.y) * 0.5 + sin(time*8)*0.05
	angle = head_angle.y + angle
	bone_paths[0].rotation.z = -((angle) * tilt_in)*(walk_speed-0.5)
	bone_paths[1].rotation.x = sin(time*8)*0.5*mult - tilt - (crouching * 8.0) - head_angle.x*(1.0/3.0)
	bone_paths[1].rotation.y = angle*0.5 - sin(time*8)*0.05 + crouching
	bone_paths[1].rotation.z = sin(time*8-PI*0.5)*0.025*mult+0.0125 - crouching*angle*3.0
	bone_paths[3].rotation.x = -sin(time*8)*0.5*mult - tilt - (crouching * 8.0)  - head_angle.x*(1.0/3.0)
	bone_paths[3].rotation.y = angle*0.5 - sin(time*8*mult)*0.05 - crouching
	bone_paths[3].rotation.z = -sin(time*8-PI*0.5)*0.025*mult+0.0125 - crouching*angle*3.0
	bone_paths[5].rotation.y = -angle*0.5*0.5 - sin(time*8+0.1)*0.05 ##edited for eyes
	bone_paths[5].rotation.x = -(tilt*0.8)+(abs(angle) * tilt)*0.5 + sin(time*16-PI*0.5)*0.01*mult - crouching * 2.0 + head_angle.x*(2.0/3.0)
	bone_paths[2].rotation.x = -sin(time*8+PI*(0.5*clamp(mult, -1.0, 1.0)))*0.3*mult+PI*(0.09+crouching*0.5) + pow(mult,3)*0.025 + (crouching * 4.0)
	bone_paths[4].rotation.x = sin(time*8+PI*(0.5*clamp(mult, -1.0, 1.0)))*0.3*mult+PI*(0.09+crouching*0.5) + pow(mult,3)*0.025 + (crouching * 4.0)
	bone_paths[10].rotation_degrees.x = -61.5 + ((abs((abs(mult) + (1.0-abs(mult))*0.3))-1.0) * 30) - abs((tilt/PI * 180) * 0.5) - ((crouching/PI)*180)*2.0 - (head_angle.x*(1.0/3.0)/PI * 180)
	bone_paths[10].position.z = -0.088 + crouching*0.1
	bone_paths[11].rotation_degrees.x = 10.5 - ((mult-1.0) * 10 / mult)
	bone_paths[12].rotation_degrees.x = 16.5 - ((mult-1.0) * 16 / mult)
	bone_paths[10].rotation.y = sin(time*8)*0.5* (mult + (1.0-mult)*0.5) + angle * 0.5
	bone_paths[11].rotation.y = -sin(time*8+PI*0.33)*0.33*(mult + (1.0-mult)*0.5)
	bone_paths[12].rotation.y = -sin(time*8+PI*0.33)*0.25*(mult + (1.0-mult)*0.5)
	bone_paths[6].rotation.x = -sin(time*8)*0.25*mult+PI*0.03 - tilt*0.5 - crouching*2.0  + falling*0.5
	bone_paths[6].rotation.y = angle*0.25  + falling*0.5
	bone_paths[7].rotation.x = -sin(time*8+(0.3*mult))*0.2*mult-PI*0.07-abs(tilt) - falling
	bone_paths[8].rotation.x = sin(time*8)*0.25*mult+PI*0.03 - tilt*0.5 - crouching*2.0  + falling*0.5
	bone_paths[8].rotation.y = angle*0.25  - falling*0.5
	bone_paths[9].rotation.x = sin(time*8+(0.3*mult))*0.2*mult-PI*0.07-abs(tilt)  - falling
	
	bone_paths[6].rotation.z = abs(mult/1.0)*0.075  + falling*0.5
	bone_paths[8].rotation.z = -abs(mult/1.0)*0.075  - falling*0.5
	
	#bounce
	bone_paths[1].position.y = sin(time*8-PI*0.5)*0.025*abs(mult) - 0.282 + 0.025*abs(mult)
	bone_paths[3].position.y = sin(time*8+PI*0.5)*0.025*abs(mult) - 0.282 + 0.025*abs(mult)
	#Vector3(-0.075, -0.282,0.001)
	bone_paths[6].position.y = sin(time*8+PI*0.5)*0.01*mult + 0.241 - 0.01*mult*0.5
	bone_paths[8].position.y = sin(time*8-PI*0.5)*0.01*mult + 0.241 - 0.01*mult*0.5
	#Vector3(0.15,0.241,-0.001)
	
	##eyes
	eye_pos.y = head_angle.x * 0.25
	eye_pos.x = -head_angle.y * 0.25
	blink_time += delta * blink_speed * 0.8
	if blink_time > time_between_blinks*blink_speed:
		blink_time -= time_between_blinks * blink_speed
	if blink_time < PI:
		blink = sin(blink_time)
	else:
		blink = 0.0
	eye_rot = eye_pos
	eye_lids = lerp(Vector2(1.05,0.32), Vector2(2.0,0.0), blink)
	set_eye_param("shader_parameter/eyePos", eye_pos)
	set_eye_param("shader_parameter/eyeLids", eye_lids)
	set_eye_param("shader_parameter/eyeTaper", eye_taper)
	set_eye_param("shader_parameter/eyeScale", eye_scale)
	##
	
	
	##stepping
	if sin(time*8)*pow(mult,2) > 0.0 and right_stepped:
		right_stepped = false
		emit_signal("step")
	elif sin(time*8)*pow(mult,2) < 0.0 and !right_stepped:
		right_stepped = true
		emit_signal("step")
	
	pass

func walk(delta, mult = 1.0, speed = 1.0, angle = 0.0, tilt_in = 0.0, crouching = 0.0, head_angle = Vector2(0.0,0.0), fall = 0.0, stride = 1.0):
	time += delta * (mult + (1.0-mult)*0.9) * (speed + (abs(mult)-3.0)*0.125)
	if mult > 3.0:
		mult = 3.0
	stride = stride - abs(mult)*0.5 + 0.5
	if stride < 1.0:
		stride = 1.0
	head_angle.x = head_angle.x * 0.8
	var tilt = tilt_in * mult + sin(time*16+0.1)*0.05*(abs(mult)-0.8) + 0.05*(abs(mult)-0.8)
	bone_paths[0].position.z = sin(time*16-PI*0.5)*0.002*mult - crouching*0.5
	bone_paths[0].position.y = sin(time*16+PI*0.05)*0.008*pow(mult+crouching,2) - 0.2*abs(tilt) - crouching*1.1 - abs(head_angle.x * 0.025) + falling*0.1 + sin(time*16.0+PI*0.4)*(stride-1.0)*0.05-stride*0.01
	bone_paths[0].rotation.x = tilt + crouching * 3.0 + head_angle.x*(1.0/3.0)
	bone_paths[0].rotation.y = (angle-head_angle.y) * 0.5 + sin(time*8)*0.05
	angle = head_angle.y + angle
	bone_paths[0].rotation.z = -((angle) * tilt_in)*(walk_speed-0.5)
	bone_paths[1].rotation.x = sin(time*8)*0.5*mult*stride+(1.0-stride)*0.25 - tilt - (crouching * 8.0) - head_angle.x*(1.0/3.0)
	bone_paths[1].rotation.y = angle*0.5 - sin(time*8)*0.05 + crouching
	bone_paths[1].rotation.z = sin(time*8-PI*0.5)*0.025*mult+0.0125 - crouching*angle*3.0
	bone_paths[3].rotation.x = -sin(time*8)*0.5*mult*stride+(1.0-stride)*0.25 - tilt - (crouching * 8.0)  - head_angle.x*(1.0/3.0)
	bone_paths[3].rotation.y = angle*0.5 - sin(time*8*mult)*0.05 - crouching
	bone_paths[3].rotation.z = -sin(time*8-PI*0.5)*0.025*mult+0.0125 - crouching*angle*3.0
	bone_paths[5].rotation.y = -angle*0.5*0.5 - sin(time*8+0.1)*0.05 ##edited for eyes
	bone_paths[5].rotation.x = -(tilt*0.8)+(abs(angle) * tilt)*0.5 + sin(time*16-PI*0.5)*0.01*mult - crouching * 2.0 + head_angle.x*(2.0/3.0)
	bone_paths[2].rotation.x = -sin(time*8+PI*(0.5*clamp(mult, -1.0, 1.0)))*0.3*mult*stride-(1.0-stride)*0.25+PI*(0.09+crouching*0.5) + pow(mult,3)*0.025 + (crouching * 4.0)
	bone_paths[4].rotation.x = sin(time*8+PI*(0.5*clamp(mult, -1.0, 1.0)))*0.3*mult*stride-(1.0-stride)*0.25+PI*(0.09+crouching*0.5) + pow(mult,3)*0.025 + (crouching * 4.0)
	bone_paths[10].rotation_degrees.x = -61.5 + ((abs((abs(mult) + (1.0-abs(mult))*0.3))-1.0) * 30) - abs((tilt/PI * 180) * 0.5) - ((crouching/PI)*180)*2.0 - (head_angle.x*(1.0/3.0)/PI * 180)
	bone_paths[10].position.z = -0.088 + crouching*0.1
	bone_paths[11].rotation_degrees.x = 10.5 - ((mult-1.0) * 10 / mult)
	bone_paths[12].rotation_degrees.x = 16.5 - ((mult-1.0) * 16 / mult)
	bone_paths[10].rotation.y = sin(time*8)*0.5* (mult + (1.0-mult)*0.5) + angle * 0.5
	bone_paths[11].rotation.y = -sin(time*8+PI*0.33)*0.33*(mult + (1.0-mult)*0.5)
	bone_paths[12].rotation.y = -sin(time*8+PI*0.33)*0.25*(mult + (1.0-mult)*0.5)
	bone_paths[6].rotation.x = -sin(time*8)*0.25*mult+PI*0.03 - tilt*0.5 - crouching*2.0  + falling*0.5
	bone_paths[6].rotation.y = angle*0.25  + falling*0.5
	bone_paths[7].rotation.x = -sin(time*8+(0.3*mult))*0.2*mult-PI*0.07-abs(tilt) - falling
	bone_paths[8].rotation.x = sin(time*8)*0.25*mult+PI*0.03 - tilt*0.5 - crouching*2.0  + falling*0.5
	bone_paths[8].rotation.y = angle*0.25  - falling*0.5
	bone_paths[9].rotation.x = sin(time*8+(0.3*mult))*0.2*mult-PI*0.07-abs(tilt)  - falling
	
	bone_paths[6].rotation.z = abs(mult/1.0)*0.075  + falling*0.5
	bone_paths[8].rotation.z = -abs(mult/1.0)*0.075  - falling*0.5
	
	#bounce
	bone_paths[1].position.y = sin(time*8-PI*0.5)*0.025*abs(mult) - 0.282 + 0.025*abs(mult)
	bone_paths[3].position.y = sin(time*8+PI*0.5)*0.025*abs(mult) - 0.282 + 0.025*abs(mult)
	#Vector3(-0.075, -0.282,0.001)
	bone_paths[6].position.y = sin(time*8+PI*0.5)*0.01*mult + 0.241 - 0.01*mult*0.5
	bone_paths[8].position.y = sin(time*8-PI*0.5)*0.01*mult + 0.241 - 0.01*mult*0.5
	#Vector3(0.15,0.241,-0.001)
	
	##eyes
	eye_pos.y = head_angle.x * 0.25
	eye_pos.x = -head_angle.y * 0.25
	blink_time += delta * blink_speed * 0.8
	if blink_time > time_between_blinks*blink_speed:
		blink_time -= time_between_blinks * blink_speed
	if blink_time < PI:
		blink = sin(blink_time)
	else:
		blink = 0.0
	eye_rot = eye_pos
	eye_lids = lerp(Vector2(1.05,0.32), Vector2(2.0,0.0), blink)
	set_eye_param("shader_parameter/eyePos", eye_pos)
	set_eye_param("shader_parameter/eyeLids", eye_lids)
	set_eye_param("shader_parameter/eyeTaper", eye_taper)
	set_eye_param("shader_parameter/eyeScale", eye_scale)
	##
	
	
	##stepping
	if sin(time*8+PI*0.1)*pow(mult,2) > 0.0 and right_stepped:
		right_stepped = false
		emit_signal("step")
	elif sin(time*8+PI*0.1)*pow(mult,2) < 0.0 and !right_stepped:
		right_stepped = true
		emit_signal("step")
	
	pass

func fly(delta, speed = 1.0, crouching = 0.0, head_angle = Vector2(0.0,0.0), angle = 0.0, mult = 0.0):
	speed += mult
	time += delta * speed
	if mult < -3.7:
		mult = -3.7
	mult = mult*0.5
	if mult > 2.3:
		mult = 2.3
	bone_paths[0].position.z = sin(time*2.0-PI*0.5)*0.03*mult+0.1
	bone_paths[0].position.y = sin(time*2.0)*0.1+0.1
	bone_paths[0].rotation.x = head_angle.x*0.25 + mult*0.5
	#head_angle.x -= mult*0.9
	head_angle.y += angle*0.75
	head_angle.x -= mult*0.25
	bone_paths[0].rotation.y = angle*0.75 + head_angle.y*0.25 + angle*0.2
	bone_paths[0].rotation.z = 0.0
	bone_paths[1].rotation.x = sin(time)*0.1-0.15 - head_angle.x*0.5
	bone_paths[1].rotation.y = -sin(time-PI*0.25)*0.1+0.15
	bone_paths[1].rotation.z = 0.0
	bone_paths[3].rotation.x = sin(time+PI*0.25)*0.1-0.15-0.5 - head_angle.x*0.5
	bone_paths[3].rotation.y = -sin(time+PI*0.25)*0.1-0.3
	bone_paths[3].rotation.z = 0.0
	bone_paths[5].rotation.y = head_angle.y*0.5 - angle
	bone_paths[5].rotation.x = head_angle.x*0.75 - mult*0.25
	bone_paths[2].rotation.x = -sin(time+PI*0.2)*0.25+0.25 - head_angle.x*0.1 -0.25*mult*0.2
	bone_paths[4].rotation.x = -sin(time+PI*0.5)*0.1+0.8 - head_angle.x*0.1 - 0.8*mult*0.2
	bone_paths[6].rotation.x = sin(time+PI)*0.05+0.1
	bone_paths[6].rotation.y = 0.0
	bone_paths[7].rotation.x = -sin(time+PI*0.8)*0.05 -0.15 - head_angle.x*0.05
	bone_paths[8].rotation.x = sin(time+PI)*0.05+0.1 - head_angle.x*0.05
	bone_paths[8].rotation.y = 0.0
	bone_paths[9].rotation.x = -sin(time+PI*0.8)*0.05-0.15
	
	bone_paths[6].rotation.z = -sin(time+PI*0.5)*0.05+0.1
	bone_paths[8].rotation.z = sin(time+PI*0.55)*0.05-0.1
	
	#bounce
	bone_paths[1].position.y =  - 0.282
	bone_paths[3].position.y =  - 0.282
	#Vector3(-0.075, -0.282,0.001)
	bone_paths[6].position.y = 0.241
	bone_paths[8].position.y = 0.241
	#Vector3(0.15,0.241,-0.001)
	
	##eyes
	if head_angle.x > 0.0:
		eye_lids = Vector2(1.05, 0.32)
	else:
		eye_lids = Vector2(1.05+head_angle.x*0.2, 0.32)
	eye_pos.y = head_angle.x * 0.25
	eye_pos.x = head_angle.y * 0.25
	blink_time += delta * blink_speed * 0.8
	if blink_time > time_between_blinks*blink_speed:
		blink_time -= time_between_blinks * blink_speed
	if blink_time < PI:
		blink = sin(blink_time)
	else:
		blink = 0.0
	eye_rot = eye_pos
	eye_lids = lerp(eye_lids, Vector2(2.0,0.0), blink)
	set_eye_param("shader_parameter/eyePos", eye_pos)
	set_eye_param("shader_parameter/eyeLids", eye_lids)
	set_eye_param("shader_parameter/eyeTaper", eye_taper)
	set_eye_param("shader_parameter/eyeScale", eye_scale)
	##
	pass

func blank_anim(delta, mult = 1.0, speed = 1.0, angle = 0.0, tilt_in = 0.0, crouching = 0.0, head_angle = Vector2(0.0,0.0), fall = 0.0):
	time += delta * (mult + (1.0-mult)*0.9) * speed
	head_angle.x = head_angle.x * 0.8
	var tilt = tilt_in * mult + sin(time*16+0.1)*0.05*(abs(mult)-0.8) + 0.05*(abs(mult)-0.8)
	bone_paths[0].position.z = 0.0
	bone_paths[0].position.y = 0.0
	bone_paths[0].rotation.x = 0.0
	bone_paths[0].rotation.y = 0.0
	angle = head_angle.y + angle
	bone_paths[0].rotation.z = 0.0
	bone_paths[1].rotation.x = 0.0
	bone_paths[1].rotation.y = 0.0
	bone_paths[1].rotation.z = 0.0
	bone_paths[3].rotation.x = 0.0
	bone_paths[3].rotation.y = 0.0
	bone_paths[3].rotation.z = 0.0
	bone_paths[5].rotation.y = 0.0
	bone_paths[5].rotation.x = 0.0
	bone_paths[2].rotation.x = 0.0
	bone_paths[4].rotation.x = 0.0
	bone_paths[10].rotation_degrees.x = -61.5 + ((abs((abs(mult) + (1.0-abs(mult))*0.3))-1.0) * 30) - abs((tilt/PI * 180) * 0.5) - ((crouching/PI)*180)*2.0 - (head_angle.x*(1.0/3.0)/PI * 180)
	bone_paths[10].position.z = -0.088 + crouching*0.1
	bone_paths[11].rotation_degrees.x = 10.5 - ((mult-1.0) * 10 / mult)
	bone_paths[12].rotation_degrees.x = 16.5 - ((mult-1.0) * 16 / mult)
	bone_paths[10].rotation.y = 0.0
	bone_paths[11].rotation.y = 0.0
	bone_paths[12].rotation.y = 0.0
	bone_paths[6].rotation.x = 0.0
	bone_paths[6].rotation.y = 0.0
	bone_paths[7].rotation.x = 0.0
	bone_paths[8].rotation.x = 0.0
	bone_paths[8].rotation.y = 0.0
	bone_paths[9].rotation.x = 0.0
	
	bone_paths[6].rotation.z = abs(mult/1.0)*0.075  + falling*0.5
	bone_paths[8].rotation.z = -abs(mult/1.0)*0.075  - falling*0.5
	
	#bounce
	bone_paths[1].position.y =  - 0.282
	bone_paths[3].position.y =  - 0.282
	#Vector3(-0.075, -0.282,0.001)
	bone_paths[6].position.y = 0.241
	bone_paths[8].position.y = 0.241
	#Vector3(0.15,0.241,-0.001)
	
	##eyes
	eye_pos.y = head_angle.x * 0.25
	eye_pos.x = -head_angle.y * 0.25
	blink_time += delta * blink_speed * 0.8
	if blink_time > time_between_blinks*blink_speed:
		blink_time -= time_between_blinks * blink_speed
	if blink_time < PI:
		blink = sin(blink_time)
	else:
		blink = 0.0
	eye_rot = eye_pos
	eye_lids = lerp(Vector2(1.05,0.32), Vector2(2.0,0.0), blink)
	set_eye_param("shader_parameter/eyePos", eye_pos)
	set_eye_param("shader_parameter/eyeLids", eye_lids)
	set_eye_param("shader_parameter/eyeTaper", eye_taper)
	set_eye_param("shader_parameter/eyeScale", eye_scale)
	##
	pass

##for eyes
@onready var eyes = $root/chestBase/neck/eyes
func set_eye_param(key, value):
	eyes.get_active_material(0).set(key, value)

@onready var mouth = $root/chestBase/neck/mouth
func set_mouth_param(key, value):
	mouth.get_active_material(0).set(key, value)

##    for saving
const savePath = "res://tempSaveFolder/save1/"
func save_file(subFolder : String, fileName : String, data) -> void:
	if !DirAccess.dir_exists_absolute(savePath+subFolder):
		DirAccess.make_dir_recursive_absolute(savePath+subFolder)
	var path = savePath+subFolder+fileName
	var file = FileAccess.open(path, FileAccess.WRITE)
	file.store_var(data)
	file.close()
	print("saved " + fileName)
func load_file(subFolder : String, fileName : String):
	var path = savePath+subFolder+fileName
	if !DirAccess.dir_exists_absolute(savePath+subFolder):
		printerr("tried to load from nonexistant directory")
		return null
	if FileAccess.file_exists(path):
		var file = FileAccess.open(path, FileAccess.READ)
		var data = file.get_var()
		file.close()
		print("loaded " + fileName)
		return data
	else:
		printerr("tried to load nonexistant file")
		return null
## 

@onready var meshes = [
	$root/chestBase/hip_L/leftLeg1N, #0
	$root/chestBase/hip_L/leftLeg1NOL, #1
	$root/chestBase/hip_L/leftLeg1S,
	$root/chestBase/hip_L/leftLeg1SOL,
	$root/chestBase/hip_L/knee_L/leftFootN, #4
	$root/chestBase/hip_L/knee_L/leftFootNOL, #5
	$root/chestBase/hip_L/knee_L/leftFootS,
	$root/chestBase/hip_L/knee_L/leftFootSOL,
	$root/chestBase/hip_R/rightLeg1N, #8
	$root/chestBase/hip_R/rightLeg1NOL, #9
	$root/chestBase/hip_R/rightLeg1S,
	$root/chestBase/hip_R/rightLeg1SOL,
	$root/chestBase/hip_R/knee_R/rightFootN, #12
	$root/chestBase/hip_R/knee_R/rightFootNOL, #13
	$root/chestBase/hip_R/knee_R/rightFootS,
	$root/chestBase/hip_R/knee_R/rightFootSOL,
	$root/chestBase/neck/head,
	#$root/chestBase/neck/headOutside,
	$root/chestBase/neck/headOutsideP,
	$root/chestBase/shoulder_L/leftArm1N, #18
	$root/chestBase/shoulder_L/leftArm1NOL, #19
	$root/chestBase/shoulder_L/leftArm1S,
	$root/chestBase/shoulder_L/leftArm1SOL,
	$root/chestBase/shoulder_L/elbowL/leftArm2N, #22
	$root/chestBase/shoulder_L/elbowL/leftArm2NOL, #23
	$root/chestBase/shoulder_L/elbowL/leftArm2S,
	$root/chestBase/shoulder_L/elbowL/leftArm2SOL,
	$root/chestBase/shoulder_R/rightArm1N, #26
	$root/chestBase/shoulder_R/rightArm1NOL, #27
	$root/chestBase/shoulder_R/rightArm1S,
	$root/chestBase/shoulder_R/rightArm1SOL,
	$root/chestBase/shoulder_R/elbowR/rightArm2N, #30
	$root/chestBase/shoulder_R/elbowR/rightArm2NOL, #31
	$root/chestBase/shoulder_R/elbowR/rightArm2S,
	$root/chestBase/shoulder_R/elbowR/rightArm2SOL,
	$root/chestBase/torsoN, #34
	$root/chestBase/torsoNOL, #35
	$root/chestBase/torsoS,
	$root/chestBase/torsoSOL
]

var normal = [
	0,1,4,5,8,9,12,13,18,19,22,23,26,27,30,31,34,35
]

var slim = [
	2,3,6,7,10,11,14,15,20,21,24,25,28,29,32,33,36,37
	
]

@onready var transparent = [
	$root/chestBase/hip_L/leftLeg1NOL,
	$root/chestBase/hip_L/leftLeg1SOL,
	$root/chestBase/hip_L/knee_L/leftFootNOL,
	$root/chestBase/hip_L/knee_L/leftFootSOL,
	$root/chestBase/hip_R/rightLeg1NOL,
	$root/chestBase/hip_R/rightLeg1SOL,
	$root/chestBase/hip_R/knee_R/rightFootNOL,
	$root/chestBase/hip_R/knee_R/rightFootSOL,
	$root/chestBase/neck/headOutside,
	$root/chestBase/shoulder_L/leftArm1NOL,
	$root/chestBase/shoulder_L/leftArm1SOL,
	$root/chestBase/shoulder_L/elbowL/leftArm2NOL,
	$root/chestBase/shoulder_L/elbowL/leftArm2SOL,
	$root/chestBase/shoulder_R/rightArm1NOL,
	$root/chestBase/shoulder_R/rightArm1SOL,
	$root/chestBase/shoulder_R/elbowR/rightArm2NOL,
	$root/chestBase/shoulder_R/elbowR/rightArm2SOL,
	$root/chestBase/torsoNOL,
	$root/chestBase/torsoSOL
]

@onready var non_skin_meshes = [
	$root/chestBase/neck/eyes,
	$root/chestBase/neck/eyeBrows_L,
	$root/chestBase/neck/eyeBrows_R,
	$root/chestBase/neck/mouth
]

func set_visibility_layer(layer_id, value = true):
	for m in meshes:
		m.set_layer_mask_value(layer_id, value)
	for o_m in non_skin_meshes:
		o_m.set_layer_mask_value(layer_id, value)
	pass

func set_cosmetic_visibility(ears, tail, snout):
	#$root/chestBase/torso/tail.visible = tail
	#$root/chestBase/torso/tailBase.visible = tail
	#$root/chestBase/torso/neck/head/ear1.visible = ears
	#$root/chestBase/torso/neck/head/ear2.visible = ears
	#$root/chestBase/torso/neck/head/snout.visible = snout
	pass

func load_skin(img, ears, tail, snout, is_slim, eColors, mData):
	#img = ImageTexture.create_from_image(Image.load_from_file("res://assets/glb/playerAvatar002_dapper128Secondary.png"))
	#var meshes = avatar.meshes
	var mat = meshes[0].get_active_material(0).duplicate()
	mat.albedo_texture = img
	set_cosmetic_visibility(ears, tail, snout)
	for m in meshes:
		m.set_surface_override_material(0, mat)
	var tran = mat.duplicate()
	tran.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR
	#$root/chestBase/torso/neck/head/ear1.set_surface_override_material(0, tran)
	#$root/chestBase/torso/neck/head/ear2.set_surface_override_material(0, tran)
	for t in transparent:
		t.set_surface_override_material(0, tran)
	for n in normal:
		meshes[n].visible = !is_slim
	for s in slim:
		meshes[s].visible = is_slim
	set_eye_param("shader_parameter/pupilColor", eColors[0])
	set_eye_param("shader_parameter/eyeColor2", eColors[1])
	set_eye_param("shader_parameter/eyeColor", eColors[2])
	set_eye_param("shader_parameter/whitesColor", eColors[3])
	set_eye_param("shader_parameter/eyelashCol", eColors[4])
	#[pointy_teeth, fangs, owo, standin1, standin2, colOutline, colInternal, colTongue, colTeeth]
	#set_mouth_param("shader_parameter/smile", mInfo[0])
	set_mouth_param("shader_parameter/fangs", mData[0])
	set_mouth_param("shader_parameter/pointy_teeth", mData[1] * 0.1)
	set_mouth_param("shader_parameter/owo", mData[2])
	set_mouth_param("shader_parameter/col_outline", mData[5])
	set_mouth_param("shader_parameter/col_internal", mData[6])
	set_mouth_param("shader_parameter/col_tongue", mData[7])

@onready var name_tag = $root/chestBase/neck/nameTag
func set_display_name(text):
	name_tag.text = text
	pass

#const VU_COUNT = 28
#const HEIGHT = 60
#@export var FREQ_MAX = 11050.0
#@export var MIN_DB = 60
var u = 0.0
var o = 0.0
var a = 0.0
var i = 0.0
var high = 0.0
var hiss = 0.0
func spectrum_to_mouth(spectrum, delta = 1.0):
	u = lerp(u,clamp((60 + linear_to_db(spectrum.get_magnitude_for_frequency_range(0,1122).length()))/60,0.0,1.0),delta*32.0)
	o = lerp(o,clamp((60 + linear_to_db(spectrum.get_magnitude_for_frequency_range(900,1035).length()))/60,0.0,1.0),delta*32.0)
	a = lerp(a,clamp((60 + linear_to_db(spectrum.get_magnitude_for_frequency_range(1000,1500).length()))/60,0.0,1.0),delta*32.0)
	i = lerp(i, clamp((60 + linear_to_db(spectrum.get_magnitude_for_frequency_range(1333,2089).length()))/60,0.0,1.0),delta*32.0)
	high = lerp(high, clamp((60 + linear_to_db(spectrum.get_magnitude_for_frequency_range(1900,2761).length()))/60,0.0,1.0), delta*32.0)
	hiss = lerp(high, clamp((60 + linear_to_db(spectrum.get_magnitude_for_frequency_range(3000,5000).length()))/60,0.0,1.0), delta*32.0)
	var open = 0.0
	var wide = 0.1
	var smile = 0.0
	var teeth = 0.1
	var pos = Vector2.ZERO
	open = lerp(open, 0.45, a)
	open = lerp(open, 0.25, u)
	open = lerp(open, 0.24, o)
	open = lerp(open, 0.72, high)
	open = lerp(open, 0.5, hiss)
	wide = lerp(wide, 0.25, i)
	wide = lerp(wide, 0.08, u)
	wide = lerp(wide, 0.08, o)
	wide = lerp(wide, 0.2, a)
	smile = lerp(smile, -0.045, u)
	smile = lerp(smile, 0.06, a)
	smile = lerp(smile, 0.08, high)
	pos.y = lerp(pos.y, -0.25, high)
	pos.y = lerp(pos.y, -0.25, i)
	pos.y = lerp(pos.y, 0.215 - open*0.5, u)
	pos.y = lerp(pos.y, 0.0, a)
	teeth = lerp(teeth, 0.0, o)
	teeth = lerp(teeth, 0.05, high)
	teeth = lerp(teeth, 0.0, u)
	teeth = lerp(teeth, 0.2, a)
	teeth = lerp(teeth, 0.1, i)
	teeth = lerp(teeth, 0.305, hiss)
	#pos.x = -o*0.01
	
	set_mouth_param("shader_parameter/open", open)
	set_mouth_param("shader_parameter/smile", smile)
	set_mouth_param("shader_parameter/mouth_size", Vector2(wide, 0.04))
	set_mouth_param("shader_parameter/mouthPos", pos)
	set_mouth_param("shader_parameter/teeth", teeth)
	#var prev_hz = 0
	#for i in range(1,VU_COUNT+1):   
		#var hz = i * FREQ_MAX / VU_COUNT;
		#var f = spectrum.get_magnitude_for_frequency_range(prev_hz,hz)
		#var energy = clamp((MIN_DB + linear_to_db(f.length()))/MIN_DB,0,1)
		#var height = energy * HEIGHT
		#prev_hz = hz
