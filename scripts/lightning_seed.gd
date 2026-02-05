extends CharacterBody3D
var dir = Vector3.ZERO
var owned_by = ""
var speed = 0.1


func _physics_process(delta):
	$MeshInstance3D.rotation.x += delta
	$MeshInstance3D.rotation.z += delta*1.5
	$MeshInstance3D.rotation.y += delta*1.25
	velocity.y -= delta*9.8*0.01
	if move_and_collide(velocity):
		die()


func die():
	Global.instance_projectile("lightning", position, Vector3.UP, owned_by)
	call_deferred("queue_free")
