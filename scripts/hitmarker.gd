extends Label3D

var velocity = Vector3.ZERO
const max_vel = 0.5
const damp = 0.2
const gravity = Vector3(0.0,-0.5,0.0)
var val = 0
var lifetime = 1.0

func _ready():
	velocity = Vector3(randf_range(-max_vel,max_vel), randf_range(-max_vel,max_vel),randf_range(-max_vel,max_vel))
	if val > 0:
		text = "+" + str(val)
	else:
		text = "-" + str(val)

func _physics_process(delta):
	velocity += gravity * delta
	velocity -= velocity * damp * delta
	position += velocity * delta
	lifetime -= delta
	if lifetime < 0.0:
		queue_free()
