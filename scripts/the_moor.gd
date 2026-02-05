extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready():
	if !Global.visited_places.has("moor"):
		Global.visited_places += ["moor"]
		$animationPlayer.play("welcome")
		$animationPlayer/AudioStreamPlayer.play()
	else:
		$animationPlayer.queue_free()
	pass # Replace with function body.
