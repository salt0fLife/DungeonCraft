extends CharacterBody3D

@onready var speed = 2.5
@onready var jump_strength = 6.0
@onready var distance_till_jump = 3.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var target = null

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
	if target == null:
		move_idle(delta)
	else:
		move_track(delta)
	move_and_slide()


func move_track(delta):
	
	pass

func move_attack(delta):
	
	pass

func lunge():
	
	pass

func move_idle(delta):
	
	pass
