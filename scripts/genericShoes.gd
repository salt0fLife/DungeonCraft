extends Node3D
@onready var avatar = $"../../genericAvatar"
@onready var player = avatar.get_parent().get_parent()
@onready var footL = $footL
@onready var footR = $footR

func _process(delta):
	footL.global_transform = avatar.bone_paths[2].global_transform
	footR.global_transform = avatar.bone_paths[4].global_transform

func damage(amount, id, owned_by):
	player.damage(amount, id, owned_by)
