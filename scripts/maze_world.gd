extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready():
	await get_tree().create_timer(11).timeout
	$AudioStreamPlayer.play()
	await get_tree().create_timer(10).timeout
	$AudioStreamPlayer2.play()
	pass # Replace with function body.
