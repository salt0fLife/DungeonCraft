extends Node3D

func activate(key = "", force = Vector3.ZERO, extraForce = Vector3.ZERO):
	$head.apply_central_impulse(-$head.linear_velocity)
	$torso.apply_central_impulse(-$torso.linear_velocity)
	$arm1L.apply_central_impulse(-$arm1L.linear_velocity)
	$arm1L2.apply_central_impulse(-$arm1L2.linear_velocity)
	$arm1R.apply_central_impulse(-$arm1R.linear_velocity)
	$arm1R2.apply_central_impulse(-$arm1R2.linear_velocity)
	$legR.apply_central_impulse(-$legR.linear_velocity)
	$legR2.apply_central_impulse(-$legR2.linear_velocity)
	$legL.apply_central_impulse(-$legL.linear_velocity)
	$legL2.apply_central_impulse(-$legL2.linear_velocity)
	
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
	
	match key:
		"":
			$torso.apply_central_impulse(extraForce)
		"headshot":
			$head.apply_central_impulse(extraForce)
	
	
	pass
