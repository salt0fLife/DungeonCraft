extends Node3D
@onready var avatar = $"../../genericAvatar"
@onready var player = avatar.get_parent().get_parent()
@onready var torso = $torsoTrack
@onready var legL = $legLtrack
@onready var legR = $legRtrack

func _process(delta):
	torso.global_transform = avatar.bone_paths[0].global_transform
	legL.global_transform = avatar.bone_paths[1].global_transform
	legR.global_transform = avatar.bone_paths[3].global_transform

func damage(amount, id, owned_by):
	player.damage(amount, id, owned_by)
