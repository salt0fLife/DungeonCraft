extends Node3D
@onready var avatar = $"../../genericAvatar"
@onready var player = avatar.get_parent().get_parent()
@onready var head = $headTrack

func _process(delta):
	head.global_transform = avatar.bone_paths[5].global_transform

func damage(amount, id, owned_by):
	player.damage(amount, id, owned_by)
