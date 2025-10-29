extends CharacterBody3D


@export var speed = 3.0
@export var jump_velociy = 6.0
@export var distance_till_jump = 5.0
var target = null
@onready var eye_handler = $eye_rot_center
@onready var eyeL = $graphics/eye1
@onready var eyeR = $graphics/eye2
@onready var dEyeL = $eye_rot_center/desired_Leye_trans
@onready var dEyeR = $eye_rot_center/desired_Reye_trans
var eyeL_vel = Vector3.ZERO
var eyeR_vel = Vector3.ZERO
@export var eye_acceleration = 10.0
@export var eye_damp = 0.9
@onready var size = randf_range(0.5,2.0)
var grounded = true

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
@onready var mat = $graphics/MeshInstance3D.get_active_material(0).duplicate(true)
func _ready():
	scale = Vector3(size,size,size)
	target = get_tree().get_first_node_in_group("player")
	$graphics/MeshInstance3D.set_surface_override_material(0, mat)
	randomize_colors()
	pass

func randomize_colors():
	if !is_multiplayer_authority():
		request_spawn_data.rpc_id(1)
		return
	var c1 = random_col()
	var c2 = random_col()
	var c3 = random_col()
	mat.set("shader_parameter/albedo", c1)
	mat.set("shader_parameter/internal_col", c2)
	mat.set("shader_parameter/fog_col", c3)
	pass

func random_col():
	return Color(randf_range(0.2, 1.0), randf_range(0.2, 1.0),randf_range(0.2, 1.0),1.0)

func rand_num():
	return randf_range(-1.0, 1.0)

var squashed = 1.0
var eye_rot_time = 0.0
var time_between_look = 2.0
func _physics_process(delta):
	$graphics.rotation.y = -atan2(velocity.z, velocity.x) - PI*0.5
	$eye_rot_center.rotation.y = $graphics.rotation.y
	time += delta
	if time > 64.0:
		time -= 64.0
		dEyeL.rotation = Vector3.ZERO
		dEyeR.rotation = Vector3.ZERO
	eye_rot_time += delta
	if eye_rot_time > time_between_look:
		eye_rot_time = 0.0
		dEyeL.rotation += Vector3(rand_num(),rand_num(),rand_num())
		dEyeR.rotation += Vector3(rand_num(),rand_num(),rand_num())
		dEyeL.position = Vector3(randf_range(-0.1,-0.3),randf_range(-0.1,0.1), randf_range(-0.1,0.1))
		dEyeR.position = Vector3(randf_range(0.1,0.3),randf_range(-0.1,0.1), randf_range(-0.1,0.1))
	handle_eye_transform(delta)
	walk(delta)
	#idle(delta)
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
	move_and_slide()
	if !is_multiplayer_authority():
		return
	sync.rpc(position, velocity)

@rpc("any_peer","unreliable")
func sync(pos, vel):
	position = pos
	velocity = vel

@rpc("any_peer","reliable")
func spawn_sync(data):
	#var data = []
	#data = rpc_id(1, "get_spawn_info")
	size = data[0]
	scale = Vector3(size,size,size)
	mat.set("shader_parameter/albedo", data[1])
	mat.set("shader_parameter/internal_col", data[2])
	mat.set("shader_parameter/fog_col", data[3])

func get_spawn_info() -> Array:
	var c1 = mat.get("shader_parameter/albedo")
	var c2 = mat.get("shader_parameter/internal_col")
	var c3 = mat.get("shader_parameter/fog_col")
	return [size,c1,c2,c3]

@rpc("reliable", "any_peer")
func request_spawn_data():
	if !is_multiplayer_authority():
		return
	spawn_sync.rpc(get_spawn_info())

func set_mat_param(key, value) -> void:
	mat.set(key, value)

var time = randf_range(0.0,64.0)
func idle(delta) -> void:
	velocity.x = 0.0
	velocity.z = 0.0
	time_between_look = 2.0
	#squashed -= (1.0 - squashed) * delta * 0.5
	set_mat_param("shader_parameter/squash", 1.0+sin(time*2.0)*0.1)
	eye_handler.position.y = sin(time*0.5)*0.05 + 0.2
	
	pass

func handle_eye_transform(delta):
	eyeL.global_position -= velocity*0.1*delta
	eyeR.global_position -= velocity*0.1*delta
	
	var dirL = (dEyeL.global_position - eyeL.global_position)
	eyeL_vel += dirL * eye_acceleration * delta
	eyeL_vel -= eyeL_vel * delta * eye_damp
	eyeL.global_position += eyeL_vel
	#eyeL.rotation = lerp(eyeL.rotation, dEyeL.rotation, delta*eye_acceleration)
	eyeL.rotation -= (eyeL.rotation - dEyeL.rotation)*delta
	
	var dirR = (dEyeR.global_position - eyeR.global_position)
	eyeR_vel += dirR * eye_acceleration * delta
	eyeR_vel -= eyeR_vel * delta * eye_damp
	eyeR.global_position += eyeR_vel
	#eyeR.rotation = lerp(eyeR.rotation, dEyeR.rotation, delta*eye_acceleration)
	eyeR.rotation -= (eyeR.rotation - dEyeR.rotation)*delta

func walk(delta):
	time_between_look = 6.0
	if is_on_floor():
		eye_handler.scale = Vector3(1.0,1.0,1.0)
		var mult = clamp((Vector2(velocity.x, velocity.z).length() / speed + (1.0-size)*0.5),0.0,1.0)
		set_mat_param("shader_parameter/squash", 1.0)
		set_mat_param("shader_parameter/walk", 1.0*mult)
		eye_handler.rotation.x -= delta * mult*10.0
		if eye_handler.rotation.x > PI*2.0:
			eye_handler.rotation.x -= PI*2.0
	else:
		squashed = lerp(squashed, -0.275, delta*8.0)
		set_mat_param("shader_parameter/squash", squashed)
		eye_handler.scale = Vector3(0.5,0.5,0.5)
	if !is_multiplayer_authority():
		return
	if target != null:
		var dif = (target.global_position - global_position)
		var dis = dif.length()
		var dir = Vector3(dif.x,0.0,dif.z).normalized()
		if dis < distance_till_jump*size and is_on_floor():
			squashed = 1.66
			velocity.y = jump_velociy + (size-1.0)*0.5
			velocity.x = dir.x * (jump_velociy + (size-1.0)*0.5)
			velocity.z = dir.z * (jump_velociy + (size-1.0)*0.5)
			#jump
			pass
		velocity.x = lerp(velocity.x, dir.x * (speed + (size-1.0)*0.5), delta * 1.0)
		velocity.z = lerp(velocity.z, dir.z * (speed + (size-1.0)*0.5), delta * 1.0)
	else:
		velocity.x = lerp(velocity.x, 0.0, delta * 1.0)
		velocity.z = lerp(velocity.z, 0.0, delta * 1.0)
		target = get_tree().get_first_node_in_group("player")
	pass

@rpc("any_peer","reliable")
func combine(oSize, oColor1, oColor2, oColor3):
	var col1 = mat.get("shader_parameter/albedo")
	var col2 = mat.get("shader_parameter/internal_col")
	var col3 = mat.get("shader_parameter/fog_col")
	col1 = lerp(col1, oColor1, oSize/size)
	col2 = lerp(col2, oColor2, oSize/size)
	col3 = lerp(col3, oColor3, oSize/size)
	set_mat_param("shader_parameter/albedo", col1)
	set_mat_param("shader_parameter/internal_col", col2)
	set_mat_param("shader_parameter/fog_col", col3)
	size += oSize*0.25
	scale = Vector3(size,size,size)

func _on_combine_area_body_entered(body):
	if !is_multiplayer_authority():
		return
	if body.is_in_group("slime"):
		if body.size < size:
			#combine(body)
			var ocol1 = body.mat.get("shader_parameter/albedo")
			var ocol2 = body.mat.get("shader_parameter/internal_col")
			var ocol3 = body.mat.get("shader_parameter/fog_col")
			combine(body.size, ocol1, ocol2, ocol3)
			combine.rpc(body.size, ocol1, ocol2, ocol3)
			body.die()

func die():
	queue_free()
	
	pass

func damage(amount, id, attacker):
	print(attacker + " hit " + str(size) + " sized slime with " + str(amount) + " damage in the " + id)
	if size - float(amount)*0.25 < 0.25:
		if is_multiplayer_authority():
			die()
	else:
		size -= float(amount)*0.25
		scale = Vector3(size,size,size)

