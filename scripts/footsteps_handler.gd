extends Node3D

enum {
	stone,
	concrete,
	wood,
	water,
	grass,
	dirt,
	brush,
	snow
}

const sound_lookup = {
	stone : ["res://assets/sounds/footsteps/stone/footstepStone1.wav",
	"res://assets/sounds/footsteps/stone/footstepStone2.wav",
	"res://assets/sounds/footsteps/stone/footstepStone4.wav",
	"res://assets/sounds/footsteps/stone/soundEffects3.wav"
	],
	concrete : [
		"res://assets/sounds/footsteps/concrete/footstepConcrete1.wav"
	],
	wood : [
		"res://assets/sounds/footsteps/wood/footstepWood1.wav",
		"res://assets/sounds/footsteps/wood/footstepWood2.wav",
		"res://assets/sounds/footsteps/wood/footstepWood3.wav",
		"res://assets/sounds/footsteps/wood/footstepWood4.wav",
		"res://assets/sounds/footsteps/wood/footstepWood5.wav",
		"res://assets/sounds/footsteps/wood/footstepWood6.wav"
	],
	water : ["res://assets/sounds/footsteps/water/footstepConcrete2.wav",
	"res://assets/sounds/footsteps/water/footstepWater1.wav"
	],
	grass : [
		"res://assets/sounds/footsteps/grassFootsteps/grassFootstep.ogg",
		"res://assets/sounds/footsteps/grassFootsteps/grassFootstep11.ogg",
		"res://assets/sounds/footsteps/grassFootsteps/grassFootstep10.ogg",
		"res://assets/sounds/footsteps/grassFootsteps/grassFootstep7.ogg",
		"res://assets/sounds/footsteps/grassFootsteps/grassFootstep5.ogg",
		"res://assets/sounds/footsteps/grassFootsteps/grassFootstep3.ogg",
	],
	dirt : [
		"res://assets/sounds/footsteps/dirt/footstepDirt1.wav",
		"res://assets/sounds/footsteps/dirt/footstepStone2.wav"
	],
	brush : [
		"res://assets/sounds/footsteps/grassFootsteps/grassFootstep2.ogg",
		"res://assets/sounds/footsteps/grassFootsteps/grassFootstep4.ogg",
		"res://assets/sounds/footsteps/grassFootsteps/grassFootstep6.ogg",
		"res://assets/sounds/footsteps/grassFootsteps/grassFootstep8.ogg",
		"res://assets/sounds/footsteps/grassFootsteps/grassFootstep12.ogg"
	],
	snow : [
		"res://assets/sounds/footsteps/snow/snow1.wav",
		"res://assets/sounds/footsteps/snow/snow2.wav",
		"res://assets/sounds/footsteps/snow/snow3.wav",
		"res://assets/sounds/footsteps/snow/snow4.wav",
		"res://assets/sounds/footsteps/snow/snow5.wav",
		"res://assets/sounds/footsteps/snow/snow6.wav"
	]
	
}


func play():
	var k = stone
	if $groundFinder.is_colliding():
		var g = $groundFinder.get_collider().get_groups()
		if !g.is_empty():
			match g[0]:
				"stone_s" : k = stone
				"concrete_s" : k = concrete
				"wood_s" : k = wood
				"water_s" : k = water
				"grass_s" : k = grass
				"dirt_s" : k = dirt
				"brush_s" : k = brush
				"snow_s" : k = snow
	var s = load(sound_lookup[k].pick_random())
	$AudioStreamPlayer3D.stream = s
	$AudioStreamPlayer3D.pitch_scale = randf_range(0.9,1.1)
	$AudioStreamPlayer3D.play()
	pass
