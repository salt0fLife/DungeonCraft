extends Node3D
@export var life_time = 30.0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	life_time -= delta
	if life_time < 0.0:
		queue_free()
