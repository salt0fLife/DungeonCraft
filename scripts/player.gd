extends CharacterBody3D

@export var MouseSensitivity = 2.5
@onready var cameraHandler = $playerAvatar/cameraHandler
@onready var graphics = $playerAvatar
@onready var avatar = $playerAvatar/genericAvatar
@onready var camera = $playerAvatar/cameraHandler/bobbingHandler/Camera3D
@onready var body = $playerAvatar/genericAvatar/root
@onready var voip = $playerAvatar/cameraHandler/voip
@onready var AG_handler = $playerAvatar/accesories
@onready var hands = $playerAvatar/cameraHandler/hands

var sprinting = false
var crouching = false
var flying = false
var display_name = ""
var walk_anim_key = "walk"
var idle_anim_key = "idle"

## accessories and weapons
var attributes = {
	"speed" : 3.0,
	"flying_speed" : 3.0,
	"max_health" : 10,
	"jump_velocity" : 6.0,
	"can_fly" : false,
	"air_acceleration": 1.0,
	"strength" : 1.0
}
const base_attributes = {
	"speed" : 3.0,
	"flying_speed" : 5.0,
	"max_health" : 10,
	"jump_velocity" : 6.0,
	"can_fly" : false,
	"air_acceleration": 1.0,
	"strength" : 1.0
}
var accessories_paths = {
}

func update_accessories():
	update_stats_from_accessories()
	update_accessories_graphics()
	update_accessories_graphics.rpc(Inventory.accessories)

func update_stats_from_accessories():
	set_stats_to_default()
	for i in Inventory.accessories.keys():
		var val = Inventory.accessories[i]
		if val != "":
			var data = Lookup.items[val]
			for k in data[3][1].keys():
				if attributes.has(k):
					if typeof(data[3][1][k]) == TYPE_BOOL:
						attributes[k] = data[3][1][k]
					else:
						attributes[k] += data[3][1][k]
	update_health_graphics()
	pass

var held_item_data = []
func update_held_item():
	held_item_data = Inventory.get_held_item_data()
	if held_item_data != []:
		var mp = held_item_data[1]
		update_held_item_graphics(mp)
		update_held_item_graphics.rpc(mp)
		update_anims_from_item_type(held_item_data[2])
	else:
		update_held_item_graphics("")
		update_held_item_graphics.rpc("")
		update_anims_from_item_type(-1)
	pass

func update_anims_from_item_type(type):
	match type:
		Lookup.itemType.weapons_sword:
			walk_anim_key = "walk_weapon"
			idle_anim_key = "idle_weapon"
		_:
			walk_anim_key = "walk"
			idle_anim_key = "idle"

@onready var fp_item_handler = $playerAvatar/cameraHandler/hands/handR/fp_item_handler
@onready var tp_item_handler = $playerAvatar/genericAvatar/root/chestBase/shoulder_R/elbowR/tp_item_handler

@rpc("any_peer","reliable")
func update_held_item_graphics(model_path):
	for f in fp_item_handler.get_children():
		f.queue_free()
	for t in tp_item_handler.get_children():
		t.queue_free()
	if model_path == "":
		return
	var mf = load(model_path).instantiate()
	var mt = load(model_path).instantiate()
	fp_item_handler.add_child(mf)
	tp_item_handler.add_child(mt)

@rpc("any_peer", "reliable")
func update_accessories_graphics(a = Inventory.accessories):
	for k in a.keys():
		var val = a[k]
		if accessories_paths.has(k):
			if accessories_paths[k] != null:
				accessories_paths[k].queue_free()
				accessories_paths[k] = null
		if val != "":
			var s = load(Lookup.items[val][3][0]).instantiate()
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
	settup_audio()
	if !is_multiplayer_authority():
		request_cosmetics.rpc()
		return
	tp_item_handler.hide()
	settup_team_hurtboxes(true)
	update_health_graphics()
	Global.connect("loaded_world",_on_world_load)
	Inventory.connect("update_accessories", update_accessories)
	Inventory.connect("update_held_item",update_held_item)
	display_name = Global.display_name
	update_stats_from_accessories()
	update_accessories_graphics()
	update_accessories_graphics.rpc(Inventory.accessories)
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
	hands.visible = true
	AG_handler.visible = false

func settup_team_hurtboxes(is_team):
	for h in hurtboxes:
		h.set_collision_layer_value(4,!is_team)
		h.set_collision_layer_value(7,is_team)
	pass

func _on_world_load():
	tp(Vector3.ZERO,Vector3.ZERO)

var jump_buffer = 0.0
func _input(event):
	if !is_multiplayer_authority() or Global.disable_avatar:
		return
	##hotbar
	if Input.is_action_just_pressed("hotbar_0"):
		Inventory.change_held_item(0)
	if Input.is_action_just_pressed("hotbar_1"):
		Inventory.change_held_item(1)
	if Input.is_action_just_pressed("hotbar_2"):
		Inventory.change_held_item(2)
	if Input.is_action_just_pressed("hotbar_3"):
		Inventory.change_held_item(3)
	if Input.is_action_just_pressed("hotbar_4"):
		Inventory.change_held_item(4)
	if Input.is_action_just_pressed("hotbar_5"):
		Inventory.change_held_item(5)
	if Input.is_action_just_pressed("hotbar_6"):
		Inventory.change_held_item(6)
	if Input.is_action_just_pressed("hotbar_7"):
		Inventory.change_held_item(7)
	if Input.is_action_just_pressed("hotbar_8"):
		Inventory.change_held_item(8)
	if Input.is_action_just_pressed("hotbar_9"):
		Inventory.change_held_item(9)
	##
	if Input.is_action_just_pressed("emote2"):
		if current_animation != "point":
			play_arm_anim("point")
		else:
			play_arm_anim("")
	if Input.is_action_just_pressed("emote1"):
		if current_animation != "wave":
			play_arm_anim("wave")
		else:
			play_arm_anim("")
	if Input.is_action_just_pressed("interact"):
		attempt_to_interact()
	if Input.is_action_just_pressed("lm"):
		_on_left_mouse()
	if Input.is_action_just_pressed("rm"):
		_on_right_mouse()
	if Input.is_action_just_pressed("push_to_talk"):
		voip.enabled = !voip.enabled
	if Input.is_action_just_pressed("blink"):
		blink_funny()
		blink_funny.rpc()
	if Input.is_action_just_pressed("third_person"):
		if camera.position.z == 0.0:
			camera.position.z = 2.0
			avatar.set_visibility_layer(1, true)
			hands.visible = false
			AG_handler.visible = true
			tp_item_handler.visible = true
		elif camera.position.z == 2.0:
			camera.position.z = -2.0
			camera.desired_rot.y = PI
		else:
			camera.desired_rot.y = 0.0
			avatar.set_visibility_layer(1, false)
			hands.visible = true
			AG_handler.visible = false
			tp_item_handler.visible = false
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
		hands.rotation.y -= event.relative.x /1000 * MouseSensitivity*0.25
		hands.rotation.y = clamp(hands.rotation.y, -0.5,0.5)
		hands.rotation.x += TempRotation
		hands.rotation.x = clamp(hands.rotation.x, -0.5,0.5)
		avatar.head_angle.x = -cameraHandler.rotation.x
		body.rotation.y += event.relative.x /1000 * MouseSensitivity
		body.rotation.y = clamp(body.rotation.y, -1.5, 1.5)
		avatar.head_angle.y = -body.rotation.y

func jump():
	jump_buffer = 0.0
	jumped_last_frame = true
	play_footstep()
	velocity.y = attributes["jump_velocity"]
	avatar.walk_tilt = 0.0
	avatar.animation_speed = 4.0

@onready var dust_particles = $dust_particles
@onready var impact_particles = $impact_particles
var airborn = false
var last_y_velocity = 0.0
var jumped_last_frame = false
var vel_last_frame = Vector3.ZERO
func _physics_process(delta):
	if !is_multiplayer_authority():
		return
	hands.rotation.x -= (velocity.y / attributes["jump_velocity"])*delta*10.0
	
	hands.position = lerp(hands.position, bobHandler.position, delta*64.0)
	hands.rotation = Global.vec3_rot_lerp(hands.rotation, bobHandler.rotation, delta*32.0)
	
	
	if position.y < -200.0:
		position = Vector3.ZERO
	# Add the gravity.
	if not is_on_floor():
		jumped_last_frame = false
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
			play_footstep()
			avatar.crouching += abs(last_y_velocity/9.8)*0.25
			var mult = (-last_y_velocity/9.8)*0.9
			var d = int(pow(mult,3.0))
			if d > 0:
				damage(d,"legs","fall_damage",Vector3(0.0,last_y_velocity,0.0))
				if d > 3:
					heavy_impact()
					heavy_impact.rpc()
			#avatar.walk_tilt += abs(last_y_velocity/9.8)*0.25
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("left", "right", "up", "down")
	var direction = (graphics.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if flying:
		update_velocity_flying(delta)
	elif direction:
		avatar.animation_state = walk_anim_key
		body.rotation.y = lerp(body.rotation.y, 0.0, delta*4.0)
		avatar.head_angle.y = body.rotation.y
		if !airborn and !jumped_last_frame:
			if sprinting and !crouching:
				velocity.x = lerp(velocity.x, direction.x * attributes["speed"]*2.2*speed_multipler, delta*8.0)
				velocity.z = lerp(velocity.z, direction.z * attributes["speed"]*2.2*speed_multipler, delta*8.0)
			elif crouching:
				velocity.x = lerp(velocity.x, direction.x * attributes["speed"]*0.75*speed_multipler, delta*8.0)
				velocity.z = lerp(velocity.z, direction.z * attributes["speed"]*0.75*speed_multipler, delta*8.0)
			else:
				velocity.x = lerp(velocity.x, direction.x * attributes["speed"]*0.85*speed_multipler, delta*8.0)
				velocity.z = lerp(velocity.z, direction.z * attributes["speed"]*0.85*speed_multipler, delta*8.0)
		else:
			velocity = update_velocity_air(direction, velocity, delta)
	else:
		if avatar.walk_angle != 0.0:
			body.rotation.y = avatar.walk_angle
			avatar.head_angle.y = -avatar.walk_angle
			avatar.walk_angle = 0.0
		avatar.animation_state = idle_anim_key
		avatar.resist_dir = Vector2(0.0,0.0)
		dust_particles.emitting = false
		if !airborn and !jumped_last_frame:
			if velocity.length() > attributes["speed"]*3.0:
				dust_particles.emitting = true
				velocity.x = lerp(velocity.x, 0.0, 2.0*delta)#16.0*delta)
				velocity.z = lerp(velocity.z, 0.0, 2.0*delta)#16.0*delta)
				var resist_dir = (velocity.normalized() * (velocity.length()/(attributes["speed"]*4.0))* graphics.transform.basis)
				if resist_dir.length() > 1.0:
					resist_dir = resist_dir.normalized()
				avatar.resist_dir = Vector2(resist_dir.x,resist_dir.z)
			else:
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
	vel_last_frame = velocity
	if not snap_up_to_stairs_check(delta):
		move_and_slide()
		snap_down_to_stairs_check()
	sync_information.rpc(position, graphics.rotation.y, body.rotation.y,avatar.animation_state, avatar.walk_speed, avatar.animation_speed, avatar.crouching, avatar.head_angle, avatar.falling, avatar.walk_angle, avatar.walk_tilt,avatar.resist_dir,dust_particles.emitting)

@rpc("any_peer","unreliable")
func heavy_impact():
	dust_particles.emitting = true
	
	pass

func update_velocity_gliding(delta):
	var yawcos = cos(graphics.rotation.y);
	var yawsin = sin(graphics.rotation.y);
	var pitchcos = cos(cameraHandler.rotation.x);
	var pitchsin = sin(cameraHandler.rotation.x);
	
	var lookX = yawsin * -pitchcos;
	var lookY = -pitchsin;
	var lookZ = yawcos * -pitchcos;
	
	var hvel = sqrt(velocity.x * velocity.x + velocity.z * velocity.z); #Vector2(velocity.x,velocity.z).length
	var hlook = pitchcos;
	var sqrpitchcos = pitchcos * pitchcos;
	
	velocity.y += (-0.08 + sqrpitchcos * 0.06);
	velocity.y -= gravity * delta
	if (velocity.y < 0 && hlook > 0):
		var yacc = velocity.y * -0.1 * sqrpitchcos;
		velocity.y += yacc;
		velocity.x += lookX * yacc / hlook ;
		velocity.z += lookZ * yacc / hlook ;
	
	if (-cameraHandler.rotation.x < 0):
		var yacc = hvel * -pitchsin * 0.04;
		velocity.y += yacc * 3.5 ;
		velocity.x -= lookX * yacc / hlook ;
		velocity.z -= lookZ * yacc / hlook ;
	
	if (hlook > 0):
		velocity.x += (lookX / hlook * hvel - velocity.x) * 0.1 ;
		velocity.z += (lookZ / hlook * hvel - velocity.z) * 0.1 ;
		
	velocity.x *= 0.99 ;
	velocity.y *= 0.98 ;
	velocity.z *= 0.99 ;

##flying old
		#velocity -= velocity*delta*attributes["flying_speed"]*0.5
		#velocity -= velocity*0.1*delta
		#avatar.animation_state = "fly"
		#var input_vertical = Input.get_vector("crouch", "jump", "down", "up")
		#if sprinting:
			#velocity.y = lerp(velocity.y, input_vertical.x * attributes["flying_speed"]*2.2*speed_multipler, delta*8.0)
		#else:
			#velocity.y = lerp(velocity.y, input_vertical.x * attributes["flying_speed"]*speed_multipler, delta*8.0)
		#if direction:
			#body.rotation.y = lerp(body.rotation.y, 0.0, delta*4.0)
			#avatar.head_angle.y = body.rotation.y
			#if sprinting:
				#velocity.x = lerp(velocity.x, direction.x * attributes["flying_speed"]*2.2*speed_multipler, delta*8.0)
				#velocity.z = lerp(velocity.z, direction.z * attributes["flying_speed"]*2.2*speed_multipler, delta*8.0)
			#else:
				#velocity.x = lerp(velocity.x, direction.x * attributes["flying_speed"]*speed_multipler, delta*8.0)
				#velocity.z = lerp(velocity.z, direction.z * attributes["flying_speed"]*speed_multipler, delta*8.0)
		#else:
			#if avatar.walk_angle != 0.0:
				#body.rotation.y = avatar.walk_angle
				#avatar.head_angle.y = -avatar.walk_angle
				#avatar.walk_angle = 0.0
			#velocity.x = lerp(velocity.x, 0.0, 4.0*delta)
			#velocity.z = lerp(velocity.z, 0.0, 4.0*delta)
		#pass


func update_velocity_flying(delta):
	if avatar.walk_angle != 0.0:
		body.rotation.y = avatar.walk_angle
		avatar.head_angle.y = -avatar.walk_angle
		avatar.walk_angle = 0.0
	var mult = (vel_last_frame - velocity).length()/(attributes["flying_speed"]*2.0)
	var d = int(pow(mult,3))
	if d > 0:
		damage(d,"legs","fall_damage",Vector3(0.0,last_y_velocity,0.0))
	avatar.animation_state = "fly"
	var input_vertical = Input.get_vector("crouch", "jump", "down", "up")
	var look_dir = get_look_dir()
	var combined_dir = (Vector3(0.0,input_vertical.x,0.0)+look_dir)*0.5
	var speed = velocity.length()
	var f_s = attributes["flying_speed"] * 5.0
	velocity.y -= gravity * delta
	velocity += combined_dir * f_s * delta
	
	var friction = speed/f_s
	
	
	velocity -= velocity * friction * delta
	body.rotation.y = lerp(body.rotation.y, 0.0, delta*4.0)
	avatar.head_angle.y = body.rotation.y

func dir_to_angle(dir):
	if dir.y == 0.0 and dir.x == 0.0:
		return 0.0
	return -atan2(-dir.y, -dir.x)+PI*0.5

@onready var bobHandler = $playerAvatar/cameraHandler/bobbingHandler
var time = 0.0
var cameraTiltAdd = 0.0
func bobbing(delta, mult, dir):
	if airborn:
		time += delta * 0.25 * (1.0 + (mult-3.0)*0.125)
	else:
		time += delta * (1.0 + (mult-3.0)*0.125)
	bobHandler.position.x = sin(time*16-PI*0.5)*0.002*mult*4.0
	bobHandler.position.y = sin(time*16)*0.006*mult*4.0
	bobHandler.rotation.x = sin(time*16+PI*0.5)*0.001*mult*4.0
	cameraTiltAdd = lerp(cameraTiltAdd, -dir.x * 0.03 * mult, delta*4.0)
	bobHandler.rotation.z = sin(time*8-PI*0.5)*0.005*mult + cameraTiltAdd

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
	elif add_speed > acceleration/3*attributes["air_acceleration"] * frame_time: #should be accaleration/4 but i made it more fun :D
		add_speed = acceleration/3*attributes["air_acceleration"] * frame_time
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
	if not is_on_floor() and velocity.y <= 0 and (was_on_floor_last_frame or _snapped_to_stairs_last_frame) and floor_below and !jumped_last_frame:
		var body_test_result = PhysicsTestMotionResult3D.new()
		if run_body_test_motion(self.global_transform, Vector3(0, -MAX_STEP_HEIGHT, 0), body_test_result):
			var translate_y = body_test_result.get_travel().y
			self.position.y += translate_y
			apply_floor_snap()
			did_snap = true
	_snapped_to_stairs_last_frame = did_snap

func snap_up_to_stairs_check(delta) -> bool:
	if jumped_last_frame: return false
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
func sync_information(pos: Vector3, rot: float, rotB: float, anim_state: String, WalkS: float, AnimS: float, C: float, HA: Vector2, F:float, A: float, T: float, res_dir: Vector2, em_dust: bool):
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
	avatar.resist_dir = res_dir
	dust_particles.emitting = em_dust
	pass

@rpc("any_peer", "reliable")
func sync_cosmetics(skin, t: Array, dn: String):
	avatar.set_display_name(dn)
	display_name = dn
	var skin_img = Global.data_to_image(skin)
	avatar.load_skin(skin_img, t[0],t[1],t[2],t[3],t[4],t[5])
	load_skin_hands(t[3],skin_img)

@onready var hands_meshes = [
	$playerAvatar/cameraHandler/hands/handR/rightArm2N,
	$playerAvatar/cameraHandler/hands/handR/rightArm2NOL,
	$playerAvatar/cameraHandler/hands/handR/rightArm2S,
	$playerAvatar/cameraHandler/hands/handR/rightArm2SOL,
	$playerAvatar/cameraHandler/hands/handR/rightArm1N,
	$playerAvatar/cameraHandler/hands/handR/rightArm1NOL,
	$playerAvatar/cameraHandler/hands/handR/rightArm1S,
	$playerAvatar/cameraHandler/hands/handR/rightArm1SOL
]

var h_m_slim = [
	2,3,6,7
]

func load_skin_hands(slim, img):
	var mat = hands_meshes[0].get_active_material(0).duplicate()
	mat.albedo_texture = img
	for m in hands_meshes:
		m.set_surface_override_material(0, mat)
		m.visible = !slim
	for i in h_m_slim:
		hands_meshes[i].visible = slim


@rpc("any_peer","reliable")
func request_cosmetics() -> void:
	if is_multiplayer_authority():
		sync_cosmetics.rpc(Global.skin, [Global.ears, Global.tail, Global.snout, Global.slim, Global.eyeColor, Global.mouthData], Global.display_name)
		update_accessories_graphics.rpc(Inventory.accessories)
		sync_hand_anim.rpc(current_animation)

@rpc("any_peer","reliable")
func sync_hand_anim(key):
	play_arm_anim(key)

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
func tp(pos : Vector3, rot = graphics.rotation.y):
	global_position = pos
	graphics.rotation.y = rot

func damage(amount, id, attacker, knockback = Vector3.ZERO):
	print(attacker + " hit " + display_name + " with " + str(amount) + " damage in the " + id)
	health -= amount
	#var b = load("res://assets/effects/blood_mist.tscn").instantiate()
	#b.position = position + Vector3(0.0,1.0,0.0)
	#b.velocity = knockback
	#get_parent().add_child(b)
	if !is_multiplayer_authority():
		return
	velocity += knockback
	if health <= 0:
		var key = ""
		if id == "head":
			key = "headshot"
		die(attacker, key, knockback)
	
	update_health_graphics()

signal died
@onready var corpse = preload("res://entities/ragdolls/player_corpse.tscn")
func die(attacker = "", key = "",add_vel = Vector3.ZERO):
	emit_signal("died")
	health = attributes["max_health"]
	match key:
		"headshot" : 
			print(display_name + " was headshot by " + attacker)
		_:
			print(display_name + " was killed by " + attacker)
	if !is_multiplayer_authority():
		return
	create_ragdoll(add_vel, position, graphics.rotation.y, velocity)
	create_ragdoll.rpc(add_vel, position, graphics.rotation.y, velocity)
	#var c = corpse.instantiate()
	#var pos = position
	#await get_tree().physics_frame
	#c.rotation.y = graphics.rotation.y
	#c.position = pos
	#get_parent().add_child(c)
	#c.activate("", velocity+add_vel, Vector3(0.0,5.0,0.0))
	velocity = Vector3.ZERO
	tp(Vector3.ZERO,0.0)

@rpc("any_peer","reliable")
func create_ragdoll(add_vel,pos,rot,vel):
	var c = corpse.instantiate()
	await get_tree().physics_frame
	c.rotation.y = rot
	c.position = pos
	get_parent().add_child(c)
	c.load_skin(avatar.meshes[0].get_active_material(0).duplicate(),avatar.is_slim)
	c.activate("", vel+add_vel, Vector3(0.0,5.0,0.0))


@onready var hurtboxes = [
	$playerAvatar/genericAvatar/root/chestBase/hip_L/knee_L/hurtbox,
	$playerAvatar/genericAvatar/root/chestBase/hip_L/hurtbox,
	$playerAvatar/genericAvatar/root/chestBase/hip_R/knee_R/hurtbox,
	$playerAvatar/genericAvatar/root/chestBase/hip_R/hurtbox,
	$playerAvatar/genericAvatar/root/chestBase/neck/hurtbox,
	$playerAvatar/genericAvatar/root/chestBase/shoulder_L/elbowL/hurtbox,
	$playerAvatar/genericAvatar/root/chestBase/shoulder_L/hurtbox,
	$playerAvatar/genericAvatar/root/chestBase/shoulder_R/elbowR/hurtbox,
	$playerAvatar/genericAvatar/root/chestBase/shoulder_R/hurtbox,
	$playerAvatar/genericAvatar/root/chestBase/hurtbox
]

@onready var attack_look = $playerAvatar/cameraHandler/bobbingHandler/attack
func _on_left_mouse():
	#Global.emit_signal("spawn_projectile", "arrow", look_reference.global_position, get_look_dir(), display_name)
	
	var type = -1
	if held_item_data != []:
		type = held_item_data[2]
	
	match type:
		Lookup.itemType.weapons_sword:
			use_sword()
		Lookup.itemType.weapons_projectile:
			use_projectile_weapon()
		_:
			punch()
	pass

func punch():
	play_arm_anim("punch")
	pass

func use_sword():
	if Input.is_action_pressed("rm"):
		play_arm_anim("stab_1")
	elif current_animation == "slash_1":
		play_arm_anim("slash_2")
	elif current_animation == "slash_2":
		play_arm_anim("stab_1")
	else:
		play_arm_anim("slash_1")

func use_projectile_weapon():
	var proj_key = held_item_data[3][0]
	var anim_key = held_item_data[3][1]
	play_arm_anim(anim_key)
	Global.emit_signal("spawn_projectile", proj_key, look_reference.global_position, get_look_dir(), display_name)
	pass

func _on_right_mouse():
	#Global.emit_signal("spawn_projectile", "arrow", look_reference.global_position, get_look_dir(), display_name)
	var type = -1
	if held_item_data != []:
		type = held_item_data[2]
	
	match type:
		Lookup.itemType.weapons_sword:
			use_sword_special()
		Lookup.itemType.weapons_projectile:
			use_projectile_special()
		_:
			punch_special()
	pass

func use_sword_special():
	
	pass

func use_projectile_special():
	
	pass

func punch_special():
	
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
			process_interact_data(ret)
			return
	print("invalid interact")

func process_interact_data(data):
	match data[0]:
		interact_return_code.is_item: Inventory.pickup_item(data[1][0],data[1][1]) #is item should pick it up

##audio handling
func settup_audio():
	avatar.connect("step",play_footstep)
	pass

const footstep_sounds = [
	"res://assets/sounds/player/fabricStep1.ogg",
	"res://assets/sounds/player/footsteps3.ogg",
]

func play_footstep():
	if !is_on_floor():
		return
	var p = footstep_sounds.pick_random()
	$footsteps.stream = load(p)
	$footsteps.pitch_scale = randf_range(0.9,1.1)
	$footsteps.play()
	pass

##arm animations
@onready var handR = $playerAvatar/cameraHandler/hands/handR

func play_arm_anim(key):
	current_animation = key
	play_avatar_arm_anim(key)
	play_avatar_arm_anim.rpc(key)
	anim_time = 1.0

@rpc("any_peer","reliable")
func play_avatar_arm_anim(key):
	anim_event = 0
	avatar.play_arm_anim(key)

var anim_event = 0
var anim_time = 0.0
var current_animation = ""
func _process(delta):
	match current_animation:
		"":
			fp_item_handler.rotation = Global.vec3_rot_lerp(fp_item_handler.rotation, Vector3(-PI*0.5,0.0,0.0), delta*6.0)
			handR.rotation_degrees = Global.vec3_rot_lerp(handR.rotation_degrees, Vector3(65.4,170.4,-176.9),delta*8.0)
			handR.position = lerp(handR.position, Vector3(0.391,-0.429,0.005), delta*8.0)
			anim_time = 0.0
			anim_event = 0
		"punch":
			anim_time -= delta*4.0
			handR.rotation.x = 1.141445 + sin(anim_time*PI)*0.5
			handR.rotation.y = 2.96706 + (sin(anim_time*PI-PI*0.2)+0.75)*0.5
			handR.position = Vector3(0.391,-0.429,0.005)
			if anim_time < 0.5 and anim_event == 0:
				deal_look_damage()
				anim_event = 1
			if anim_time < 0.0:
				current_animation = ""
		"wave":
			handR.position = Vector3(0.391,-0.429,0.005)
			anim_time -= delta*0.65
			handR.rotation.x = 0.575959 - sin(anim_time*PI*4.0)*0.1
			handR.rotation.z = -3.0874874 + (sin(anim_time*PI*4.0))*0.5
			handR.position.z = -0.25
			handR.position.x = 0.5
			if anim_time < 0.0:
				anim_time += 1.0
		"point":
			anim_time -= delta*0.25
			handR.position = Vector3(0.584,-0.25429,-0.447)
			handR.rotation.x = sin(anim_time*PI*2.0)*0.001 + 1.5
			handR.rotation.y = sin(anim_time*PI*2.0+PI*0.1)*0.001 + 2.96706
			handR.rotation.z = sin(anim_time*PI*2.0+PI*0.5)*0.001 - 3.0874874
			if anim_time < 0.0:
				anim_time += 1.0
		"slash_1":
			#fp_item_handler.rotation.x = -PI*0.25 + (1.0 - anim_time)*PI*0.25 - PI*0.5
			fp_item_handler.rotation.x = -PI*0.5 - (1.0 - anim_time)*PI*0.5
			anim_time -= delta*3.0
			handR.position = lerp(Vector3(0.37,-0.415,-0.095), Vector3(-0.272,-0.538,-0.048), (1.0 - anim_time))
			handR.rotation_degrees = Global.vec3_rot_lerp(Vector3(17.1,-101,-112), Vector3(26.6,-17.6,-70.6), (1.0 - anim_time))
			if anim_time < 0.5 and anim_event == 0:
				deal_look_damage(held_item_data[3][0],held_item_data[3][1])
				anim_event = 1
			if anim_time < 0.1 and Input.is_action_pressed("lm"):
				_on_left_mouse()
			if anim_time < 0.0:
				current_animation = ""
		"slash_2":
			fp_item_handler.rotation.x = -PI*0.5 - (1.0 - anim_time)*PI*0.5
			anim_time -= delta*3.0
			handR.position = lerp(Vector3(0.171,-0.193,-0.048), Vector3(0.257,-0.193,-0.048), (1.0 - anim_time))
			handR.rotation_degrees = Global.vec3_rot_lerp(Vector3(35.8,128.6,92.7), Vector3(15.3,46.5,71.8), (1.0 - anim_time))
			if anim_time < 0.5 and anim_event == 0:
				deal_look_damage(held_item_data[3][0],held_item_data[3][1])
				anim_event = 1
			if anim_time < 0.1 and Input.is_action_pressed("lm"):
				_on_left_mouse()
			if anim_time < 0.0:
				current_animation = ""
		"stab_1":
			anim_time -= delta * 2.0
			var val = (1.0 - anim_time)
			if anim_time > 0.5:
				handR.position = lerp(handR.position, Vector3(0.26,-0.193,0.326), val*2.0)
				handR.rotation_degrees = Global.vec3_rot_lerp(handR.rotation_degrees, Vector3(16.6,49.6,84.8), val*2.0)
				fp_item_handler.rotation.x = lerp_angle(fp_item_handler.rotation.x, 2.89724655831, val*2.1)
			else:
				handR.position = lerp(Vector3(0.26,-0.193,0.326), Vector3(0.224,-0.19,-0.101),(val*2.0)-1.0)
				handR.rotation_degrees = Global.vec3_rot_lerp(Vector3(16.6,49.6,84.8), Vector3(16.0,94.5,98.0),(val*2.0)-1.0)
				if anim_time < 0.25 and anim_event == 0:
					#stabs deal three hits of halfed damage total 1.5 damage
					#stabs should not deal knockback
					deal_look_damage(held_item_data[3][0]*0.75,held_item_data[3][1])
					anim_event = 1
				elif anim_time < 0.2 and anim_event == 1:
					deal_look_damage(held_item_data[3][0]*0.75,held_item_data[3][1])
					anim_event = 2
				elif anim_time < 0.15 and anim_event == 2:
					deal_look_damage(held_item_data[3][0]*0.75,held_item_data[3][1])
					anim_event = 3
			if anim_time < 0.0:
				current_animation = ""
			pass

func deal_look_damage(dam := 1, dist := 5.0) -> void:
	attack_look.target_position = Vector3(0.0,0.0,-dist)
	if attack_look.is_colliding():
		var hit = attack_look.get_collider()
		var poi = attack_look.get_collision_point()
		var dir = get_look_dir() + Vector3(0.0,0.5,0.0)
		if hit.is_in_group("hurtbox"):
			hit.take_damage.rpc(attributes["strength"]*dam,poi,display_name,dir*attributes["strength"]*2.0)

##ui and stuffs
func update_health_graphics():
	$UI/health.text = str(health) + " / " + str(attributes["max_health"])
	var dif = health/attributes["max_health"]
	var col = Color("GREEN")
	if dif < 0.75:
		col = Color("YELLOW")
	elif dif < 0.5:
		col = Color("ORANGE")
	elif dif < 0.25:
		col = Color("RED")
	$UI/health.set("theme_override_colors/font_color",col)
	pass



##
