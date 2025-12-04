@tool
extends Node3D

@onready var bone_paths = [
	
	
	
]

var bone_rot_velocities = []

func _ready():
	generate_tail()
	pass

@export var number_of_segments := 3
@export var dimensions = Vector3(0.06,0.2,0.06)
func generate_tail():
	for n in $root.get_children(false):
		n.queue_free()
	var segment_dimensions = Vector3(dimensions.x,dimensions.y/number_of_segments,dimensions.z)
	
	var last_bone = $root
	var first = true
	for i in range(0, number_of_segments):
		var b = Node3D.new()
		b.name = "spine" + str(i)
		if !first:
			b.position.y = segment_dimensions.y
		else:
			first = false
		var g = MeshInstance3D.new()
		g.mesh = BoxMesh.new()
		g.mesh.size = segment_dimensions
		g.position.y = segment_dimensions.y * 0.5
		last_bone.add_child(b,true)
		b.add_child(g,true)
		bone_paths += [b]
		last_bone = b
		b.owner = self
		g.owner = self
		bone_rot_velocities += [Vector2.ZERO]
		pass
	
	pass

var last_rotation = Vector3.ZERO
var rotational_vel = Vector3.ZERO
var last_pos = Vector3.ZERO
var speed = 0.0
@export var damp = 0.9
@export var damp_joint_effect = 0.0
@export var spring = 1.0

@export var sway_amplitude = 1.0
@export var sway_speed = 1.0
@export var sway_joint_offset = 0.0
@export var sway_frequency = 1.0
var time = 0.0
func _process(delta):
	
	speed += (global_position - last_pos).length()*delta*25.0
	$root.rotation.x = -2.68 + remap(clamp(speed,0.0,6.0), 0.0, 6.0, 0.0, PI)
	speed -= speed*delta*damp*25.0
	
	time += delta * sway_speed * remap(clamp(speed,0.0,6.0),0.0,6.0,1.0,4.0)
	if time > 64*PI:
		time -= 64*PI
	for i in range(0,bone_paths.size()):
		var b = bone_paths[i]
		var vel = bone_rot_velocities[i]
		var dif = (last_rotation - global_rotation)*0.5
		#lag_behind_rotation
		b.rotation.x += dif.x
		b.rotation.z += dif.y
		
		var desired_rot = Vector3(0.0,0.0,sin(time*sway_frequency-(PI*i*sway_joint_offset))*sway_amplitude)#Vector3.ZERO
		var des_dif = desired_rot - b.rotation
		
		#decide_vel
		vel.x += des_dif.x * delta * spring
		vel.y += des_dif.z * delta * spring
		
		
		
		#apply vel and damp
		b.rotation.x += vel.x * delta
		b.rotation.z += vel.y * delta
		vel.x -= vel.x * (damp - (i*damp_joint_effect)) * delta
		vel.y -= vel.y * (damp - (i*damp_joint_effect)) * delta
		
	
	last_pos = global_position
	last_rotation = global_rotation
	pass
