extends Node3D
@export var life_time = 0.1
@export var initial_vel = Vector3.ZERO
@export var starting_fade = 0.0

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

var mat = null
func _ready():
	mat = $root/chestBase/gh/torsoNorm.get_active_material(0).duplicate()
	$root/chestBase/gh/torsoNorm.set_surface_override_material(0,mat)
	$root/chestBase/hip_L/gh/leftLeg1Norm.set_surface_override_material(0,mat)
	$root/chestBase/hip_L/knee_L/gh/leftFootNorm.set_surface_override_material(0,mat)
	$root/chestBase/hip_R/gh/rightLeg1Norm.set_surface_override_material(0,mat)
	$root/chestBase/hip_R/knee_R/gh/rightFootNorm.set_surface_override_material(0,mat)
	$root/chestBase/neck/gh/headNorm.set_surface_override_material(0,mat)
	$root/chestBase/shoulder_L/gh/leftArm1Norm.set_surface_override_material(0,mat)
	$root/chestBase/shoulder_L/elbowL/gh/leftArm2Norm.set_surface_override_material(0,mat)
	$root/chestBase/shoulder_R/gh/rightArm1Norm.set_surface_override_material(0,mat)
	$root/chestBase/shoulder_R/elbowR/gh/rightArm2Norm.set_surface_override_material(0,mat)
	starting_fade = clamp(starting_fade,0.0,1.0)
	mat.albedo_color -= mat.albedo_color*starting_fade


func _process(delta):
	position += initial_vel * delta
	initial_vel -= initial_vel*delta*4.0
	life_time -= delta
	if life_time < 0.0:
		call_thread_safe("queue_free")
	mat.albedo_color -= mat.albedo_color*delta*10.0

func apply_pose(pose):
	for i in range(0, bone_names.size()):
		var k = bone_names[i]
		if pose.has(k):
			var a = 10
			match typeof(pose[k]):
				TYPE_FLOAT: 
					bone_paths[i].rotation.x = pose[k]
					#print(k + " x rot set too " + str(pose[k]))
				TYPE_VECTOR2:
					var rot = pose[k]
					bone_paths[i].rotation.x = rot.x
					bone_paths[i].rotation.y = rot.y
					#print(k + " x and y rot set too " + str(pose[k]))
				TYPE_ARRAY:
					var t = pose[k]
					bone_paths[i].position = t[0]
					bone_paths[i].rotation = t[1]
					#print(k + " pos and rot set too " + str(pose[k]))
	#print("applied " + str(pose))
