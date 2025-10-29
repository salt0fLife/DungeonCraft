extends CharacterBody3D

@export var MouseSensitivity = 2.5
@onready var cameraHandler = $playerAvatar/cameraHandler
@onready var graphics = $playerAvatar
@onready var avatar = $playerAvatar/genericAvatar
@onready var camera = $playerAvatar/cameraHandler/bobbingHandler/Camera3D
@onready var body = $playerAvatar/genericAvatar/root
@onready var voip = $playerAvatar/cameraHandler/voip
@onready var AG_handler = $playerAvatar/accesories

var sprinting = false
var crouching = false
var flying = false
var display_name = ""

## accessories and weapons
var attributes = {
	"speed" : 3.0,
	"flying_speed" : 3.0,
	"max_health" : 10,
	"jump_velocity" : 6.0,
	"can_fly" : false
}
const base_attributes = {
	"speed" : 3.0,
	"flying_speed" : 5.0,
	"max_health" : 10,
	"jump_velocity" : 6.0,
	"can_fly" : false
}
var accessories = {
	"cape" : "",
	"shirt" : "",
	"hat" : "",
	"pants" : "",
	"gloves" : "",
	"shoes" : ""
}
var accessories_paths = {
}

func update_accessories():
	update_stats_from_accessories()
	update_accessories_graphics()
	update_accessories_graphics.rpc(accessories)

func update_stats_from_accessories():
	set_stats_to_default()
	for i in accessories.keys():
		var val = accessories[i]
		if val != "":
			var data = Lookup.Accessories[val]
			for k in data[1].keys():
				if attributes.has(k):
					if typeof(data[1][k]) == TYPE_BOOL:
						attributes[k] = data[1][k]
					else:
						attributes[k] += data[1][k]
	pass

@rpc("any_peer", "reliable")
func update_accessories_graphics(a = accessories):
	for k in a.keys():
		var val = a[k]
		if accessories_paths.has(k):
			if accessories_paths[k] != null:
				accessories_paths[k].queue_free()
				accessories_paths[k] = null
		if val != "":
			var s = load(Lookup.Accessories[val][0]).instantiate()
			AG_handler.add_child(s)
			accessories_paths[k] = s
			pass

func set_stats_to_default():
	attributes = base_attributes.duplicate(true)

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity") * 1.5
@export var speed_multipler = 1.0

var health = 0
func _ready():
	health = attributes["max_health"]
	#voip.settup_audio(get_multiplayer_authority())
	var emat = avatar.eyes.get_active_material(0).duplicate()
	avatar.eyes.set_surface_override_material(0, emat)
	var mmat = avatar.mouth.get_active_material(0).duplicate()
	avatar.mouth.set_surface_override_material(0, mmat)
	if !is_multiplayer_authority():
		request_cosmetics.rpc()
		return
	display_name = Global.display_name
	update_stats_from_accessories()
	update_accessories_graphics()
	update_accessories_graphics.rpc(accessories)
	position.y += 0.1
	$spawnSounds.play()
	$UI.show()
	avatar.name_tag.hide()
	sync_cosmetics(Global.skin, [Global.ears, Global.tail, Global.snout, Global.slim, Global.eyeColor, Global.mouthData, Global.fangs, Global.pointy_teeth], Global.display_name)
	sync_cosmetics.rpc(Global.skin, [Global.ears, Global.tail, Global.snout, Global.slim, Global.eyeColor, Global.mouthData, Global.fangs, Global.pointy_teeth], Global.display_name)
	camera.make_current()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	#avatar.set_invisible()
	avatar.set_visibility_layer(1,false)
	avatar.set_visibility_layer(2,true)
	AG_handler.visible = false

var jump_buffer = 0.0
func _input(event):
	if !is_multiplayer_authority() or Global.disable_avatar:
		return
	if Input.is_action_just_pressed("interact"):
		attempt_to_interact()
	if Input.is_action_just_pressed("lm"):
		_on_left_mouse()
	if Input.is_action_just_pressed("push_to_talk"):
		voip.enabled = !voip.enabled
	#if Input.is_action_just_released("push_to_talk"):
		#voip.enabled = false
	if Input.is_action_just_pressed("blink"):
		blink_funny()
		blink_funny.rpc()
	if Input.is_action_just_pressed("third_person"):
		if camera.position.z == 0.0:
			camera.position.z = 2.0
			avatar.set_visibility_layer(1, true)
			AG_handler.visible = true
		elif camera.position.z == 2.0:
			camera.position.z = -2.0
			camera.rotation.y = PI
		else:
			camera.rotation.y = 0.0
			avatar.set_visibility_layer(1, false)
			AG_handler.visible = false
			camera.position.z = 0.0
	if Input.is_action_just_pressed("sprint") and Input.is_action_pressed("up"):
		sprinting = true
	if Input.is_action_just_pressed("up") and Input.is_action_pressed("sprint"):
		sprinting = true
	if Input.is_action_just_released("sprint"):
		sprinting = false
	if Input.is_action_just_released("up"):
		sprinting = false
	if Input.is_action_just_pressed("crouch"):
		crouching = true
	if Input.is_action_just_released("crouch"):
		crouching = false
	if Input.is_action_just_pressed("jump"):
		if is_on_floor() or _snapped_to_stairs_last_frame:
			jump()
		else:
			if flying:
				if jump_buffer > 0.0:
					flying = false
				else:
					jump_buffer = 0.5
			elif attributes["can_fly"]:
				flying = true
			else:
				jump_buffer = 0.1
	if event is InputEventMouseMotion and is_multiplayer_authority():
		var TempRotation = rotation.x - event.relative.y /1000 * MouseSensitivity
		cameraHandler.rotation.x += TempRotation
		cameraHandler.rotation.x = clamp(cameraHandler.rotation.x, -1.5, 1.5)
		graphics.rotation.y -= event.relative.x /1000 * MouseSensitivity
		avatar.head_angle.x = -cameraHandler.rotation.x
		body.rotation.y += event.relative.x /1000 * MouseSensitivity
		body.rotation.y = clamp(body.rotation.y, -1.5, 1.5)
		avatar.head_angle.y = -body.rotation.y

func jump():
	velocity.y = attributes["jump_velocity"]
	avatar.walk_tilt = 0.0
	avatar.animation_speed = 4.0

var airborn = false
var last_y_velocity = 0.0
func _physics_process(delta):
	if !is_multiplayer_authority():
		return
	
	if position.y < -200.0:
		position = Vector3.ZERO
	# Add the gravity.
	if not is_on_floor():
		avatar.animation_speed = lerp(avatar.animation_speed, 0.25*speed_multipler, delta*40.0)
		last_y_velocity = velocity.y
		airborn = true
		if !flying:
			velocity.y -= gravity * delta
			avatar.falling = lerp(avatar.falling, 1.0, delta*4.0)
		elif !attributes["can_fly"]:
			flying = false
		if jump_buffer != 0.0:
			jump_buffer -= delta
			if jump_buffer < 0.0:
				jump_buffer = 0.0
	else:
		flying = false
		if jump_buffer > 0.0:
			jump()
		avatar.animation_speed = 1.0*speed_multipler
		avatar.falling = 0.0
		if airborn:
			airborn = false
			avatar.crouching += abs(last_y_velocity/9.8)*0.25
			#avatar.walk_tilt += abs(last_y_velocity/9.8)*0.25
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("left", "right", "up", "down")
	var direction = (graphics.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if flying:
		avatar.animation_state = "fly"
		var input_vertical = Input.get_vector("crouch", "jump", "down", "up")
		if sprinting:
			velocity.y = lerp(velocity.y, input_vertical.x * attributes["flying_speed"]*2.2*speed_multipler, delta*8.0)
		else:
			velocity.y = lerp(velocity.y, input_vertical.x * attributes["flying_speed"]*speed_multipler, delta*8.0)
		if direction:
			body.rotation.y = lerp(body.rotation.y, 0.0, delta*4.0)
			avatar.head_angle.y = body.rotation.y
			if sprinting:
				velocity.x = lerp(velocity.x, direction.x * attributes["flying_speed"]*2.2*speed_multipler, delta*8.0)
				velocity.z = lerp(velocity.z, direction.z * attributes["flying_speed"]*2.2*speed_multipler, delta*8.0)
			else:
				velocity.x = lerp(velocity.x, direction.x * attributes["flying_speed"]*speed_multipler, delta*8.0)
				velocity.z = lerp(velocity.z, direction.z * attributes["flying_speed"]*speed_multipler, delta*8.0)
		else:
			if avatar.walk_angle != 0.0:
				body.rotation.y = avatar.walk_angle
				avatar.head_angle.y = -avatar.walk_angle
				avatar.walk_angle = 0.0
			velocity.x = lerp(velocity.x, 0.0, 4.0*delta)
			velocity.z = lerp(velocity.z, 0.0, 4.0*delta)
		pass
	elif direction:
		avatar.animation_state = "walk"
		body.rotation.y = lerp(body.rotation.y, 0.0, delta*4.0)
		avatar.head_angle.y = body.rotation.y
		if !airborn:
			if sprinting and !crouching:
				velocity.x = lerp(velocity.x, direction.x * attributes["speed"]*2.2*speed_multipler, delta*8.0)
				velocity.z = lerp(velocity.z, direction.z * attributes["speed"]*2.2*speed_multipler, delta*8.0)
			elif crouching:
				velocity.x = lerp(velocity.x, direction.x * attributes["speed"]*0.75*speed_multipler, delta*8.0)
				velocity.z = lerp(velocity.z, direction.z * attributes["speed"]*0.75*speed_multipler, delta*8.0)
			else:
				velocity.x = lerp(velocity.x, direction.x * attributes["speed"]*speed_multipler, delta*8.0)
				velocity.z = lerp(velocity.z, direction.z * attributes["speed"]*speed_multipler, delta*8.0)
		else:
			velocity = update_velocity_air(direction, velocity, delta)
	else:
		if avatar.walk_angle != 0.0:
			body.rotation.y = avatar.walk_angle
			avatar.head_angle.y = -avatar.walk_angle
			avatar.walk_angle = 0.0
		avatar.animation_state = "idle"
		if !airborn:
			velocity.x = lerp(velocity.x, 0.0, 16.0*delta)
			velocity.z = lerp(velocity.z, 0.0, 16.0*delta)
	
	var true_speed = sqrt(pow(velocity.x,2) + pow(velocity.z,2))/(attributes["speed"]*speed_multipler)
	#if direction:
		#true_speed = 1.0
		#if sprinting:
			#true_speed = 1.75
	#else:
		#true_speed = 0.0
	var a = (dir_to_angle(input_dir))
	if direction:
#		print(a)
		if a < 4.7123 and a > 1.5708:
			a += PI
			true_speed = - true_speed
		avatar.walk_angle = lerp_angle(avatar.walk_angle,a,delta*4)
	if crouching:
		avatar.crouching = lerp(avatar.crouching, 0.25, delta*12.0)
		#avatar.crouching = 0.25
		cameraHandler.position.y = lerp(cameraHandler.position.y, 1.0, delta*8.0)
	else:
		avatar.crouching = lerp(avatar.crouching, 0.0, delta*12.0)
		#avatar.crouching = 0.0
		cameraHandler.position.y = lerp(cameraHandler.position.y, 1.233, delta*8.0)
	avatar.walk_speed = true_speed #lerp(avatar.walk_speed, true_speed, delta*4.0)
	avatar.walk_tilt = lerp(avatar.walk_tilt, 0.15, delta*8.0)
	bobbing(delta, true_speed, input_dir)
	if not snap_up_to_stairs_check(delta):
		move_and_slide()
		snap_down_to_stairs_check()
	sync_information.rpc(position, graphics.rotation.y, body.rotation.y,avatar.animation_state, avatar.walk_speed, avatar.animation_speed, avatar.crouching, avatar.head_angle, avatar.falling, avatar.walk_angle, avatar.walk_tilt)

func dir_to_angle(dir):
	if dir.y == 0.0 and dir.x == 0.0:
		return 0.0
	return -atan2(-dir.y, -dir.x)+PI*0.5

@onready var bobHandler = $playerAvatar/cameraHandler/bobbingHandler
var time = 0.0
var cameraTiltAdd = 0.0
func bobbing(delta, mult, dir):
	if airborn:
		time += delta * 0.25
	else:
		time += delta
	bobHandler.position.x = sin(time*16-PI*0.5)*0.002*mult*2.0
	bobHandler.position.y = sin(time*16)*0.006*mult*2.0
	bobHandler.rotation.x = sin(time*16+PI*0.5)*0.001*mult*2.0
	cameraTiltAdd = lerp(cameraTiltAdd, -dir.x * 0.015 * mult, delta*4.0)
	bobHandler.rotation.z = sin(time*8)*0.001*mult + cameraTiltAdd

var maxSpeed = attributes["speed"]
var acceleration = maxSpeed * 10.0

func update_velocity_air(wishdir : Vector3, vel : Vector3, frame_time : float) -> Vector3:
	#apply friction
	vel.x -= vel.x/4 * frame_time
	vel.y -= vel.y/4 * frame_time
	vel.z -= vel.z/4 * frame_time
	
	#var current_speed = vel.dot(wishdir)
	
	#var current_speed = abs(sqrt(((vel.x * vel.x) + (vel.z * vel.z))))
	var current_speed = Vector2(vel.x, vel.z).dot(Vector2(wishdir.x, wishdir.z))
	
	var add_speed = (maxSpeed - current_speed)
	if add_speed < 0:
		add_speed = 0
	elif add_speed > acceleration/4 * frame_time:
		add_speed = acceleration/4 * frame_time
	return vel + add_speed * wishdir

#stepping
var last_frame_was_on_floor = 0
var _snapped_to_stairs_last_frame = false
var MAX_STEP_HEIGHT = 0.4
#

func is_surface_to_steep(normal : Vector3) -> bool:
	return normal.angle_to(Vector3.UP) > self.floor_max_angle

func run_body_test_motion(from: Transform3D, motion: Vector3, result = null) -> bool:
	if !result:
		result = PhysicsTestMotionResult3D.new()
	var params = PhysicsTestMotionParameters3D.new()
	params.from = from
	params.motion = motion
	return PhysicsServer3D.body_test_motion(self.get_rid(), params, result)

func snap_down_to_stairs_check() -> void:
	var did_snap := false
	var floor_below : bool = $stepDownCheckRaycast.is_colliding() and not is_surface_to_steep($stepDownCheckRaycast.get_collision_normal())
	var was_on_floor_last_frame = Engine.get_physics_frames() - last_frame_was_on_floor == 1
	if not is_on_floor() and velocity.y <= 0 and (was_on_floor_last_frame or _snapped_to_stairs_last_frame) and floor_below:
		var body_test_result = PhysicsTestMotionResult3D.new()
		if run_body_test_motion(self.global_transform, Vector3(0, -MAX_STEP_HEIGHT, 0), body_test_result):
			var translate_y = body_test_result.get_travel().y
			self.position.y += translate_y
			apply_floor_snap()
			did_snap = true
	_snapped_to_stairs_last_frame = did_snap

func snap_up_to_stairs_check(delta) -> bool:
	if not is_on_floor() and not _snapped_to_stairs_last_frame: return false
	var expected_move_motion = self.velocity * Vector3(1, 0, 1) * delta
	var step_pos_with_clearance = self.global_transform.translated(expected_move_motion + Vector3(0, MAX_STEP_HEIGHT * 2, 0))
	###
	var down_check_result = PhysicsTestMotionResult3D.new()
	if (run_body_test_motion(step_pos_with_clearance, Vector3(0, -MAX_STEP_HEIGHT * 2, 0), down_check_result)
	and (down_check_result.get_collider().is_class("StaticBody3D") or down_check_result.get_collider().is_class("CSGShape3D"))):
		var step_height = ((step_pos_with_clearance.origin + down_check_result.get_travel()) - self.global_position).y
		###
		if step_height > MAX_STEP_HEIGHT or step_height <= 0.01 or (down_check_result.get_collision_point() - self.global_position).y > MAX_STEP_HEIGHT: return false
		$stairsAheadRaycast.global_position = down_check_result.get_collision_point() + Vector3(0, MAX_STEP_HEIGHT, 0) + expected_move_motion.normalized() * 0.1
		$stairsAheadRaycast.force_raycast_update()
		if $stairsAheadRaycast.is_colliding() and not is_surface_to_steep($stairsAheadRaycast.get_collision_normal()):
			self.global_position = step_pos_with_clearance.origin + down_check_result.get_travel()
			apply_floor_snap()
			_snapped_to_stairs_last_frame = true
			return true
	return false

@rpc("any_peer", "unreliable")
func sync_information(pos: Vector3, rot: float, rotB: float, anim_state: String, WalkS: float, AnimS: float, C: float, HA: Vector2, F:float, A: float, T: float):
	position = pos
	graphics.rotation.y = rot
	body.rotation.y = rotB
	avatar.animation_state = anim_state
	avatar.walk_speed = WalkS
	avatar.animation_speed = AnimS
	avatar.crouching = C
	avatar.head_angle = HA
	avatar.falling = F
	avatar.walk_angle = A
	avatar.walk_tilt = T
	pass

@rpc("any_peer", "reliable")
func sync_cosmetics(skin, t: Array, dn: String):
	avatar.set_display_name(dn)
	display_name = dn
	avatar.load_skin(Global.data_to_image(skin), t[0],t[1],t[2],t[3],t[4],t[5])

@rpc("any_peer","reliable")
func request_cosmetics() -> void:
	if is_multiplayer_authority():
		sync_cosmetics.rpc(Global.skin, [Global.ears, Global.tail, Global.snout, Global.slim, Global.eyeColor, Global.mouthData], Global.display_name)
		update_accessories_graphics.rpc(accessories)

@rpc("any_peer","unreliable")
func blink_funny() -> void:
	avatar.force_blink()

func update_all_cosmetics():
	for p in get_tree().get_nodes_in_group("player"):
		p.request_cosmetics.rpc()

@rpc("any_peer","reliable")
func despawn():
	visible = false
	$spawnSounds.play()
	await $spawnSounds.finished
	queue_free()

@rpc("any_peer","reliable")
func tp(pos, rot = graphics.rotation.y):
	global_position = pos
	graphics.rotation.y = rot

func damage(amount, id, attacker):
	print(attacker + " hit " + display_name + " with " + str(amount) + " damage in the " + id)
	health -= amount
	if health <= 0:
		var key = ""
		if id == "head":
			key = "headshot"
		die(attacker, key)

signal died
@onready var corpse = preload("res://entities/ragdolls/player_corpse.tscn")
func die(attacker = "", key = ""):
	emit_signal("died")
	health = attributes["max_health"]
	var c = corpse.instantiate()
	var pos = position
	await get_tree().physics_frame
	c.rotation.y = graphics.rotation.y
	c.position = pos
	get_parent().add_child(c)
	c.activate("", velocity, Vector3(0.0,5.0,0.0))
	match key:
		"headshot" : 
			print(display_name + " was headshot by " + attacker)
			return
	print(display_name + " was killed by " + attacker)

func _on_left_mouse():
	Global.emit_signal("spawn_projectile", "arrow", look_reference.global_position, get_look_dir(), display_name)
	pass

@onready var look_reference = $playerAvatar/cameraHandler/lookReference
func get_look_dir():
	return (look_reference.global_position - cameraHandler.global_position).normalized()
	#listen man if it works it works


##items and interacting
enum interact_return_code {
	dont_do_anything, #returns null
	is_item, #returns item_key that should be picked up
	print, #returns a string that should be printed
}
#interact returns should be formatted like so
@onready var look = $playerAvatar/cameraHandler/bobbingHandler/look
func attempt_to_interact():
	if look.is_colliding():
		var hit = look.get_collider()
		if hit.is_in_group("interact"):
			var ret = hit.interact()
			print(ret)
			return
	print("invalid interact")







