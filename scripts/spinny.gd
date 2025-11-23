@tool
extends Node3D

@export var speed = 1.0
@export var center_point = Vector3.ZERO
@export var offset = 2.0
var rot = 0.0
@export var spin = false
@export var float_intensity = 0.0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	rot += delta * speed
	if rot>PI*2.0:
		rot -= PI*2.0
	position.x = sin(rot)*offset + center_point.x
	position.z = cos(rot)*offset + center_point.z
	position.y = sin(rot)*float_intensity + center_point.y
	if spin:
		rotation.y = rot
	pass
