extends Node3D
var life_time = 30.0
var activated = false
var blood_cooldown = 0.0
var blood_charges = 4

@onready var meshes = [
	$head/head, #0
	$head/headOutsideP,
	$torso/torsoN,
	$torso/torsoNOL,
	$torso/torsoS, #4
	$torso/torsoSOL, #5
	$arm1L/leftArm1N,
	$arm1L/leftArm1NOL,
	$arm1L/leftArm1S, #8
	$arm1L/leftArm1SOL, #9
	$arm1L2/leftArm2N,
	$arm1L2/leftArm2NOL,
	$arm1L2/leftArm2S, #12
	$arm1L2/leftArm2SOL, #13
	$arm1R/rightArm1N,
	$arm1R/rightArm1NOL,
	$arm1R/rightArm1S, #16
	$arm1R/rightArm1SOL,#17
	$arm1R2/rightArm2N,
	$arm1R2/rightArm2NOL,
	$arm1R2/rightArm2S, #20
	$arm1R2/rightArm2SOL,#21
	$legR/rightLeg1N,
	$legR/rightLeg1NOL,
	$legR/rightLeg1S, #24
	$legR/rightLeg1SOL, #25
	$legR2/rightFootN,
	$legR2/rightFootNOL,
	$legR2/rightFootS, #28
	$legR2/rightFootSOL, #29
	$legL/leftLeg1N,
	$legL/leftLeg1NOL,
	$legL/leftLeg1S, #32
	$legL/leftLeg1SOL, #33
	$legL2/leftFootN,
	$legL2/leftFootNOL,
	$legL2/leftFootS, #36
	$legL2/leftFootSOL #37
]

const slim_i = [
	4,5,8,9,12,13,16,17,20,21,24,25,28,29,32,33,36,37
	
]

func _process(delta):
	if activated:
		life_time -= delta
		if life_time < 0.0:
			queue_free()
	
	if blood_charges > 0: #i know it can go negative but it does not matter too much
		if $torso/RayCast3D.is_colliding():
			var hit = $torso/RayCast3D.get_collider()
			var poi = $torso/RayCast3D.get_collision_point()
			var norm = $torso/RayCast3D.get_collision_normal()
			var b = preload("res://assets/effects/blood_decal.tscn").instantiate()
			hit.add_child(b)
			b.global_position = poi + norm*0.01
			var rot_y = atan2(norm.x,norm.z)
			var rot_x = atan2(sqrt(pow(norm.x,2.0)+pow(norm.x,2.0)),norm.y)
			b.rotation.y = rot_y
			b.rotation.x = rot_x
			blood_charges -= 1
		if $torso/RayCast3D2.is_colliding():
			var hit = $torso/RayCast3D2.get_collider()
			var poi = $torso/RayCast3D2.get_collision_point()
			var norm = $torso/RayCast3D2.get_collision_normal()
			var b = preload("res://assets/effects/blood_decal.tscn").instantiate()
			hit.add_child(b)
			b.global_position = poi + norm*0.01
			var rot_y = atan2(norm.x,norm.z)
			var rot_x = atan2(sqrt(pow(norm.x,2.0)+pow(norm.x,2.0)),norm.y)
			b.rotation.y = rot_y
			b.rotation.x = rot_x
			blood_charges -= 1
	if blood_cooldown < 0.0:
		blood_cooldown = 5.0
		blood_charges += 1
	else:
		blood_cooldown -= delta
	
	pass

func activate(key = "", force = Vector3.ZERO, extraForce = Vector3.ZERO):
	activated = true
	
	$head.freeze = false
	$torso.freeze = false
	$arm1L.freeze = false
	$arm1L2.freeze = false
	$arm1R.freeze = false
	$arm1R2.freeze = false
	$legR.freeze = false
	$legR2.freeze = false
	$legL.freeze = false
	$legL2.freeze = false
	
	await  get_tree().physics_frame
	
	$head.apply_central_impulse(force)
	$torso.apply_central_impulse(force)
	$arm1L.apply_central_impulse(force)
	$arm1L2.apply_central_impulse(force)
	$arm1R.apply_central_impulse(force)
	$arm1R2.apply_central_impulse(force)
	$legR.apply_central_impulse(force)
	$legR2.apply_central_impulse(force)
	$legL.apply_central_impulse(force)
	$legL2.apply_central_impulse(force)
	
	
	match key:
		"":
			$torso.apply_central_impulse(extraForce)
		"headshot":
			$head.apply_central_impulse(extraForce)
		_:
			$torso.apply_central_impulse(extraForce)
	#RigidBody3D.new().apply_central_impulse(force)
	
	pass

func load_skin(skin_mat,slim):
	for m in meshes:
		m.visible = !slim
		m.set_surface_override_material(0,skin_mat)
	for i in slim_i:
		meshes[i].visible = slim

