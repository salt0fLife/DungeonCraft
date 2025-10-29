extends Node3D
@onready var avatar = $"../../genericAvatar"
@onready var player = avatar.get_parent().get_parent()
@onready var handL = $handLtrack
@onready var handR = $handRtrack
@onready var armL = $armLtrack
@onready var armR = $armRtrack

func _process(delta):
	armL.global_transform = avatar.bone_paths[6].global_transform
	armR.global_transform = avatar.bone_paths[8].global_transform
	handL.global_transform = avatar.bone_paths[7].global_transform
	handR.global_transform = avatar.bone_paths[9].global_transform

func damage(amount, id, owned_by):
	player.damage(amount, id, owned_by)


