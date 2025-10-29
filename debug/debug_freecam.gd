extends CharacterBody3D


const SPEED = 10.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var MouseSensitivity = 2.5
var paused = false

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event):
	if Input.is_action_just_pressed("pause"):
		if paused:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			paused = false
		else:
			paused = true
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if event is InputEventMouseMotion:
		var TempRotation = rotation.x - event.relative.y /1000 * MouseSensitivity
		$graphics/camerahandler.rotation.x += TempRotation
		$graphics/camerahandler.rotation.x = clamp($graphics/camerahandler.rotation.x, -1.5, 1.5)
		$graphics.rotation.y -= event.relative.x /1000 * MouseSensitivity

func _physics_process(delta):
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("left", "right", "up", "down")
	var direction = ($graphics.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	if Input.is_action_pressed("crouch"):
		velocity.y = -SPEED
	elif Input.is_action_pressed("jump"):
		velocity.y = SPEED
	else:
		velocity.y = 0.0

	move_and_slide()
