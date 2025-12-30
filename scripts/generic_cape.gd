@tool
extends Node3D


var estimated_vel = Vector3.ZERO
var pos_last_frame = Vector3.ZERO
var last_est_vel = Vector3.ZERO
var cape_vel = Vector3.ZERO
var damp = 5.0
@export var max_speed = 10.0
@onready var mat = $Node3D/fabric.get_active_material(0).duplicate()
var flapping = 0.0

func _ready():
	$Node3D/fabric.set_surface_override_material(0,mat)
	pass

func _physics_process(delta):
	var estimated_vel = (($Node3D.global_position - pos_last_frame) + last_est_vel)*0.5
	cape_vel += estimated_vel*delta
	#$Node3D.rotation = cape_vel * 100.0
	
	
	$Node3D.rotation.x = cape_vel.z * 50.0 * cos(-global_rotation.y) * cos(-global_rotation.x)
	$Node3D.rotation.x += cape_vel.x * 50.0 * sin(global_rotation.y) * cos(-global_rotation.x)
	$Node3D.rotation.x += -cape_vel.y * 100.0 * sin(global_rotation.x)
	
	$Node3D.rotation.z = cape_vel.x * 15.0 * cos(-global_rotation.y)
	$Node3D.rotation.z += cape_vel.z * 15.0 * sin(global_rotation.y)
	
	#$Node3D.rotation.x = clamp($Node3D.rotation.x,-0.04, 2.84)
	$Node3D.rotation.x = clamp($Node3D.rotation.x,-0.04, PI*0.5)
	$Node3D.rotation.z = clamp($Node3D.rotation.z,-0.38, 0.38)
	
	var speed = remap(cape_vel.length(), 0.0, max_speed, 0.0, 2.0)
	flapping += speed * delta*4.0
	flapping = clamp(speed,0.0,2.0)
	flapping -= flapping * delta*2.0
	
	mat.set("shader_parameter/wind", flapping)
	
	
	cape_vel -= cape_vel*delta * damp
	pos_last_frame = $Node3D.global_position
	last_est_vel = estimated_vel

