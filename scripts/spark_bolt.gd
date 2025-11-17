extends CharacterBody3D
const damage = 20
const penetration = 1

var owned_by = ""
var dir = Vector3(0.0,0.0,0.0)
const speed = 0.25
var lifetime = 20.0
var exploding = false

@export var autonomy_strength = 0.1
@export var time_between_checks = 0.2
var autonomy_check_timer = 0.0
var desired_velocity = Vector3.ZERO
var explode_timer = 1.0

func _physics_process(delta):
	if exploding == true:
		var intensity = (explode_timer)
		$explosion_graphics.scale = Vector3(intensity,intensity,intensity)
		$OmniLight3D.light_energy = intensity * 4.0
		explode_timer -= delta
		if explode_timer < 0.0 and is_multiplayer_authority():
			queue_free()
		return
	if velocity == Vector3.ZERO:
		velocity.x = 1.0
		velocity.z = 1.0
	elif desired_velocity == Vector3.ZERO:
		desired_velocity = velocity
	look_at(global_position + velocity)
	if !is_multiplayer_authority():
		return
	if autonomy_check_timer < 0.0:
		desired_velocity += Vector3(randf_range(-1.0,1.0),randf_range(-1.0,1.0),randf_range(-1.0,1.0))*autonomy_strength
		autonomy_check_timer = time_between_checks
	else:
		autonomy_check_timer -= delta
	velocity = lerp(velocity,desired_velocity,delta*1.0)
	lifetime -= delta
	if lifetime < 0.0:
		queue_free()
	#velocity.y -= delta*0.25
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
						hit.take_damage.rpc(damage, poi, owned_by, velocity)
						explode(position)
						explode.rpc(position)
					else:
						#dramatic explosion
						
						pass
				else:
					#ricochet explosion
					
					pass
			else:
				hit.take_damage.rpc(damage, poi, owned_by, velocity)
				explode(position)
				explode.rpc(position)
		else:
			#environmental explosion
			explode(position)
			explode.rpc(position)
	sync.rpc(position, rotation,velocity)


@rpc("any_peer","unreliable")
func sync(pos, rot, vel):
	position = pos
	rotation = rot
	velocity = vel

@rpc("any_peer","reliable")
func explode(pos):
	$AudioStreamPlayer3D.pitch_scale = randf_range(0.8,1.2)
	$AudioStreamPlayer3D.play()
	$AudioStreamPlayer3D2.stop()
	Global.create_camera_impact(pos, 0.01)
	position = pos
	exploding = true
	$flight_graphics.visible = false
	$CPUParticles3D.emitting = false
	$explosion_graphics.visible = true
	$CPUParticles3D2.emitting = true
	pass

