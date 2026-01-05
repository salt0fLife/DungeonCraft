extends Node3D
@export var life_time = 30.0

func _ready():
	var s = 1.0 / get_parent().scale.x
	scale = Vector3(s,s,s)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	life_time -= delta
	if life_time < 0.0:
		queue_free()
