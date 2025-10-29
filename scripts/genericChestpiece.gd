extends Node3D
@onready var avatar = $"../../genericAvatar"
@onready var player = avatar.get_parent().get_parent()
@onready var torso = $torsoTrack
@onready var armL = $armLtrack
@onready var armR = $armRtrack

func _process(delta):
	torso.global_transform = avatar.bone_paths[0].global_transform
	armL.global_transform = avatar.bone_paths[6].global_transform
	armR.global_transform = avatar.bone_paths[8].global_transform

func damage(amount, id, owned_by):
	player.damage(amount, id, owned_by)
