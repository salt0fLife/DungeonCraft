extends Node3D
var life_time = 30.0
var activated = false

func _process(delta):
	if activated:
		life_time -= delta
		if life_time < 0.0:
			queue_free()
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
