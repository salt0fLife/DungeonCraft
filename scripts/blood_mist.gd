extends CharacterBody3D

var gravity = 9.8
var life_time = 4.0
var vel1 = Vector3.ZERO
var vel2 = Vector3.ZERO
var vel3 = Vector3.ZERO
var vel4 = Vector3.ZERO
var damp = 0.75

func _ready():
	vel1 = Vector3(randf_range(-0.5,0.5),randf_range(-0.5,0.5),randf_range(-0.5,0.5))
	vel2 = Vector3(randf_range(-0.5,0.5),randf_range(-0.5,0.5),randf_range(-0.5,0.5))
	vel3 = Vector3(randf_range(-0.5,0.5),randf_range(-0.5,0.5),randf_range(-0.5,0.5))
	vel4 = Vector3(randf_range(-0.5,0.5),randf_range(-0.5,0.5),randf_range(-0.5,0.5))


func _physics_process(delta):
	velocity.y -= gravity * delta
	velocity -= velocity * delta * damp
	
	var col = move_and_collide(velocity)
	if col:
		var norm = col.get_normal(0)
		var decal = load("res://assets/effects/blood_decal.tscn").instantiate()
		decal.position = position + norm * 0.11
		get_parent().add_child(decal)
		#decal.look_at(position+norm)
		var rot_y = atan2(norm.x,norm.z)
		var rot_x = atan2(sqrt(pow(norm.x,2.0)+pow(norm.x,2.0)),norm.y)
		decal.rotation.y = rot_y
		decal.rotation.x = rot_x
		queue_free()
	
	$MeshInstance3D.position += vel1 * delta
	$MeshInstance3D2.position += vel2 * delta
	$MeshInstance3D3.position += vel3 * delta
	$MeshInstance3D4.position += vel4 * delta
	
	life_time -= delta
	if life_time < 0.0:
		queue_free()
	
	pass
