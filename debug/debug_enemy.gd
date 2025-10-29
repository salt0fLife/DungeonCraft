extends CharacterBody3D

var speed = 3.0
@export var life_time = 20.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")


var time_between_decisions = 5.0
var decision_timer = 0.0
var goal = Vector3.ZERO
func _physics_process(delta):
	if !is_multiplayer_authority():
		return
	decision_timer += delta
	if decision_timer > time_between_decisions:
		decision_timer = 0.0
		goal = Vector3(randf_range(-200.0,200.0),0,randf_range(-200.0,200.0))
	life_time -= delta
	if life_time < 0.0:
		die.rpc()
		die()
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	#var goal = get_tree().get_first_node_in_group("player").global_position
	var vec = (goal - global_position).normalized()
	velocity.x = lerp(velocity.x, vec.x*speed, delta*4.0)
	velocity.z = lerp(velocity.z, vec.z*speed, delta*4.0)
	sync.rpc(position, rotation)
	move_and_slide()

@rpc("any_peer", "unreliable")
func sync(pos, rot):
	position = pos
	rotation = rot

@rpc("any_peer", "reliable")
func die():
	queue_free()
