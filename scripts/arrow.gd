extends CharacterBody3D
const damage = 5
const penetration = 2

var owned_by = ""
var dir = Vector3(0.0,0.0,0.0)
const speed = 1.0
var lifetime = 10.0
var dead = false
var dead_target = null
var dead_life_time = 20.0
var dead_offset = Vector3.ZERO
var dead_rotation = Vector3.ZERO
var graphics_spinning = false
var soft_death = false

func _physics_process(delta):
	if graphics_spinning:
		if dead or soft_death:
			graphics_spinning = false
		$graphics.rotation.x += delta*PI*16.0
	if !is_multiplayer_authority():
		return
	if soft_death:
		dead_life_time -= delta
		if dead_life_time < 0.0:
			queue_free()
		return
	if dead:
		dead_life_time -= delta
		if dead_life_time < 0.0:
			queue_free()
		if dead_target != null:
			#rotation = dead_rotation * dead_target.global_transform
			#position = dead_offset * dead_target.global_transform
			#rotation = dead_rotation# * dead_target.global_transform.basis
			#rotation = dead_rotation * dead_target.global_transform.basis
			#position = dead_offset * dead_target.global_transform.basis
			#global_transform = dead_target.global_transform * transform
			
			#global_transform = dead_target.global_transform
			#position += dead_offset
			
			global_transform = dead_target.global_transform
			$graphics.position = dead_offset
			$graphics.rotation = dead_rotation
			
			#translate_object_local(dead_offset)
			#rotation += dead_rotation - dead_target.global_rotation
			#$graphics.rotation = dead_rotation + dead_target.global_rotation
			##I may be stupid
#			rotation.y += dead_rotation.y - dead_target.global_rotation.y
#			rotation.x += dead_rotation.x - dead_target.global_rotation.x
			#rotate_object_local(dead_target.global_transform.basis.x, dead_rotation.x)
			#rotate_object_local(dead_target.global_transform.basis.y, dead_rotation.y)
			#rotate_object_local(dead_target.global_transform.basis.z, dead_rotation.z)
			#position += dead_offset# * dead_target.global_transform.basis
			#rotation += dead_rotation# * dead_target.global_transform.basis
			#rotation = dead_rotation# * dead_target.global_transform.basis
			#global_transform.basis = dead_target.global_transform.basis
		else:
			queue_free()
		sync_dead.rpc(position, rotation, $graphics.position, $graphics.rotation)
		return
	look_at(global_position + velocity)
	lifetime -= delta
	if lifetime < 0.0:
		queue_free()
	velocity.y -= delta*0.25
	var col = move_and_collide(velocity)
	if col != null:
		var hit = col.get_collider(0)
		var poi = col.get_position(0)
		var norm = col.get_normal(0)
		if hit.has_method("take_damage"):
			if hit.hardness >= penetration:
				var speed = velocity.length()
				var dot = velocity.normalized().dot(norm)
				print(dot)
				if -dot > 0.85:
					#hit dead on
					if hit.hardness == penetration:
						#penetrates anyway
						hit.take_damage.rpc(5.0, poi, owned_by, velocity)
						die(hit, 30.0)
					else:
						#snap/spin
						velocity = speed*norm*(1.0+dot*0.75)*0.5
						velocity *= 0.5
						velocity.y += 0.05
						set_spinny()
						set_spinny.rpc()
				else:
					#ricochet
					velocity = norm*speed*(1.0+dot*0.75)*0.5
					#velocity.bounce(-norm)
			else:
				hit.take_damage.rpc(5.0, poi, owned_by, velocity)
				die(hit, 30.0)
		else:
			die(null)
			die.rpc(null)
	sync.rpc(position, rotation)

@rpc("any_peer","unreliable")
func sync(pos, rot):
	position = pos
	rotation = rot

@rpc("any_peer","unreliable")
func sync_dead(pos, rot, graph_pos, graph_rot):
	position = pos
	rotation = rot
	$graphics.position = graph_pos
	$graphics.rotation = graph_rot

@rpc("any_peer","unreliable")
func die(hit_path, dead_life_time_addition = 0.0):
	dead_life_time += dead_life_time_addition
	var hit = hit_path
	if hit == null:
		soft_death = true
		return
	dead_offset = (global_position - hit.global_position) * hit.global_transform.basis
	dead_rotation = rotation - hit.global_rotation
	dead_target = hit
	dead = true
	dead_target.connect("remove_shrapnel", queue_free)

@rpc("any_peer","reliable")
func set_spinny():
	graphics_spinning = true
	pass
