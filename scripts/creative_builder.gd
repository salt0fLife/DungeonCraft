extends Node3D
@export var speed = 20.0
var velocity = Vector3.ZERO
var drag = 12.0
var MouseSensitivity = 2.5
var sprinting = false

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta):
	if Input.is_action_just_pressed("sprint"):
		if sprinting:
			speed = 120.0
		else:
			speed = 40.0
		sprinting = !sprinting
	var input_dir = Input.get_vector("left", "right", "up", "down")
	var dir = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	velocity += dir*speed*delta
	
	if Input.is_action_pressed("jump"):
		velocity.y += speed*delta
	if Input.is_action_pressed("crouch"):
		velocity.y -= speed*delta
	
	position += velocity * delta
	velocity -= velocity*delta*drag
	pass

func _input(event):
	if event is InputEventMouseMotion:
		var TempRotation = rotation.x - event.relative.y /1000 * MouseSensitivity
		$cameraHandler.rotation.x += TempRotation
		$cameraHandler.rotation.x = clamp($cameraHandler.rotation.x, -1.5, 1.5)
		rotation.y -= event.relative.x /1000 * MouseSensitivity
	if Input.is_action_just_pressed("third_person"):
		emit_signal("final_build")

var block = 1
func _process(delta):
	if $cameraHandler/RayCast3D.is_colliding():
		var poi = $cameraHandler/RayCast3D.get_collision_point()
		var coord = Vector3i.ZERO
		var norm = $cameraHandler/RayCast3D.get_collision_normal()
		poi += norm*0.3
		poi = poi*2.5
		coord = Vector3i(poi.x,poi.y,poi.z)
		poi = Vector3(coord.x*0.4,coord.y*0.4,coord.z*0.4)
		$cameraHandler/RayCast3D/MeshInstance3D.position = poi + Vector3(0.2,0.2,0.2)
		$cameraHandler/RayCast3D/MeshInstance3D.visible = true
		if Input.is_action_just_pressed("lm"):
			emit_signal("place",coord.x,coord.y,coord.z,block)
			print(coord)
		pass
	else:
		$cameraHandler/RayCast3D/MeshInstance3D.visible = false

signal place
signal final_build
