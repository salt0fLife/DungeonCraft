extends Node3D

@rpc("any_peer")
func respawn_effect():
	$respawnEffect.emitting = true


func set_ghost(val : bool):
	$ghostParticles.emitting = val
	pass
