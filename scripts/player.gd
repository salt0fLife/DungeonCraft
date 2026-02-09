extends CharacterBody3D

@onready var MouseSensitivity = Settings.user_settings["look_sensitivity"]
@onready var cameraHandler = $playerAvatar/cameraHandler
@onready var graphics = $playerAvatar
@onready var avatar = $playerAvatar/genericAvatar
@onready var camera = $playerAvatar/cameraHandler/bobbingHandler/SpringArm3D/Camera3D#$playerAvatar/cameraHandler/bobbingHandler/Camera3D
@onready var body = $playerAvatar/genericAvatar/root
@onready var voip = $playerAvatar/cameraHandler/voip
@onready var AG_handler = $playerAvatar/accesories
@onready var hands = $playerAvatar/cameraHandler/hands

var sprinting = false
var crouching = false
var desired_crouching = false
var flying = false
var ghost = false
var display_name = ""
var walk_anim_key = "walk"
var idle_anim_key = "idle"

## accessories and weapons
var attributes = {
	##vision
	"dark_vision" : 0.0,
	"ghost_communication" : false,
	##movement
	#ground
	"speed" : 3.0,
	"speed_multiplier" : 1.0,
	"jump_velocity" : 6.0,
	"air_acceleration": 1.0,
	#air
	"can_fly" : false,
	"flying_speed" : 5.0,
	"flying_control" : 1.0,
	"flying_can_glide" : false,
	"flying_can_hover" : false,
	##bars and such
	"max_health" : 10.0,
	"max_mana" : 10.0,
	"max_stamina" : 10.0,
	"mana_regen_speed" : 1.0,
	"stamina_regen_speed": 1.0,
	##damage enhancements
	"strength" : 1.0, #increases physical attacks
	"chaotic_affinity" : 1.0, #increases blight explosion and lightning attacks
	"divine_affinity" : 1.0, #increases holy and fire attacks attacks
	"arcane_affinity" : 1.0, #increases magic ice and toxic attacks (magic ie curses and spells or something)
	"size" : 1.0,
	##defenses
	#localized_generic_defense
	"defense_head" : 1.0,
	"defense_torso" : 1.0,
	"defense_arms" : 1.0,
	"defense_handL" : 1.0,
	"defense_handR" : 1.0,
	"defense_legs" : 1.0,
	"defense_footR" : 1.0,
	"defense_footL" : 1.0,
	#real_defense
	"true_defense" : 1.0, #only changed through race and subclass, effects all damage
	"generic_defense" : 1.0,
	"stab_defense" : 1.0,
	"slash_defense" : 1.0,
	"blunt_defense" : 1.0,
	"fire_defense" : 1.0,
	"ice_defense" : 1.0,
	"toxic_defense" : 1.0,
	"explosion_defense" : 1.0,
	"magic_defense" : 1.0,
	"lightning_defense" : 1.0,
	"holy_defense" : 1.0,
	"blight_defense" : 1.0
	#
}
const base_attributes = {
	##vision
	"dark_vision" : 0.0,
	"ghost_communication" : false,
	##movement
	#ground
	"speed" : 3.0,
	"speed_multiplier" : 1.0,
	"jump_velocity" : 6.0,
	"air_acceleration": 1.0,
	#air
	"can_fly" : false,
	"flying_speed" : 5.0,
	"flying_control" : 1.0,
	"flying_can_glide" : false,
	"flying_can_hover" : false,
	##bars and such
	"max_health" : 10.0,
	"max_mana" : 10.0,
	"max_stamina" : 10.0,
	"mana_regen_speed" : 1.0,
	"stamina_regen_speed": 1.0,
	##damage enhancements
	"strength" : 1.0, #increases physical attacks
	"chaotic_affinity" : 1.0, #increases blight explosion and lightning attacks
	"divine_affinity" : 1.0, #increases holy and fire attacks attacks
	"arcane_affinity" : 1.0, #increases magic ice and toxic attacks (magic ie curses and spells or something)
	"size" : 1.0,
	##defenses
	#localized_generic_defense
	"defense_head" : 1.0,
	"defense_torso" : 1.0,
	"defense_arms" : 1.0,
	"defense_handL" : 1.0,
	"defense_handR" : 1.0,
	"defense_legs" : 1.0,
	"defense_footR" : 1.0,
	"defense_footL" : 1.0,
	#real_defense
	"true_defense" : 1.0, #only changed through race and subclass, effects all damage
	"generic_defense" : 1.0,
	"stab_defense" : 1.0,
	"slash_defense" : 1.0,
	"blunt_defense" : 1.0,
	"fire_defense" : 1.0,
	"ice_defense" : 1.0,
	"toxic_defense" : 1.0,
	"explosion_defense" : 1.0,
	"magic_defense" : 1.0,
	"lightning_defense" : 1.0,
	"holy_defense" : 1.0,
	"blight_defense" : 1.0
	#
}
var accessories_paths = {
}
var status_effects = {
}

func update_accessories():
	update_stats_from_accessories()
	update_accessories_graphics()
	update_accessories_graphics.rpc(Inventory.accessories)
	update_attribute_graphics()
	update_attribute_graphics.rpc(attributes["size"],attributes["chaotic_affinity"],attributes["divine_affinity"],attributes["arcane_affinity"])

var last_mh_c_l:float = 1.0 #max health changed level idk man
func update_stats_from_accessories():
	var attribute_multipliers = {}
	set_stats_to_default()
	var applied_bonuses = []
	for i in Inventory.accessories.keys():
		var val = Inventory.accessories[i]
		if val[0] != "": #applies all of the equipments and sets modifiers
			var data = Lookup.items[val[0]]
			for k in data[3][1].keys():
				if attributes.has(k):
					if typeof(data[3][1][k]) == TYPE_BOOL:
						attributes[k] = data[3][1][k]
					else:
						attributes[k] += data[3][1][k]
			#set bonus
			if data.size() == 6: #checks for set_bonus key
				var sb_key = data[5]
				if !applied_bonuses.has(sb_key):
					applied_bonuses += [sb_key]
					var sb_data = Lookup.set_bonus[sb_key]
					var can_apply = true
					for c in sb_data[0].keys(): #checks to see if you have all important items
						if !Inventory.accessories[c][0] == sb_data[0][c]: #TGIC
							can_apply = false
					if can_apply:
						print("YOU EQUIPPED A FULL SET! now you get" + str(sb_data[1]))
						for sbk in sb_data[1].keys():
							if attributes.has(sbk):
								if typeof(sb_data[1][sbk]) == TYPE_BOOL:
									attributes[sbk] = sb_data[1][sbk]
								else:
									attributes[sbk] += sb_data[1][sbk]
		#enchantments
		if val[3].has("enchantments"): #val[3] is items custom data
			for ench in val[3]["enchantments"]:
				match ench:
					Lookup.enchantments.eyes_of_the_dead:
						attributes["ghost_communication"] = true
					Lookup.enchantments.resilience:
						attributes["true_defense"] += 0.05 #efffectively decreases all damage by 5% and it stacks
					Lookup.enchantments.advanced_resiliance:
						attributes["true_defense"] += 0.15 #efffectively decreases all damage by 15% and it stacks
					Lookup.enchantments.desolation:
						attributes["chaotic_affinity"] += 0.5
					Lookup.enchantments.mastery:
						attributes["chaotic_affinity"] += 0.5
						attributes["divine_affinity"] += 0.5
						attributes["arcane_affinity"] += 0.5
					Lookup.enchantments.advanced_mastery:
						attributes["chaotic_affinity"] += 2.0
						attributes["divine_affinity"] += 2.0
						attributes["arcane_affinity"] += 2.0
					Lookup.enchantments.perfect_mastery:
						attributes["chaotic_affinity"] += 10.0
						attributes["divine_affinity"] += 10.0
						attributes["arcane_affinity"] += 10.0
	#"strength" : 1.0, #increases physical attacks
	#"chaotic_affinity" : 1.0, #increases blight explosion and lightning attacks
	#"divine_affinity" : 1.0, #increases holy and fire attacks attacks
	#"arcane_affinity" : 1.0, #increases magic ice and toxic attacks (magic ie curses and spells or something)
	#"true_defense" : 1.0, #only changed through race and subclass, effects all damage
	#"generic_defense" : 1.0,
	#"stab_defense" : 1.0,
	#"slash_defense" : 1.0,
	#"blunt_defense" : 1.0,
	#"fire_defense" : 1.0,
	#"ice_defense" : 1.0,
	#"toxic_defense" : 1.0,
	#"explosion_defense" : 1.0,
	#"magic_defense" : 1.0,
	#"lightning_defense" : 1.0,
	#"holy_defense" : 1.0,
	#"blight_defense" : 1.0
	
	#resilience, #improves all defensive attributes by small amounts
	#advanced_resiliance, #better resiliance resiliance
	#desolation, #applies blight and increases damage attributes decreases defensive effects
	#mastery, #improves everything by a little bit
	#advanced_mastery, #better mastery
	#perfect_mastery, #better better mastery
	#weightless, #removes movement debuffs and knockback resistance if applicable #weightlessness?
	#density, #increases movment debuffs and knockback resistance if applicable
	#swiftness, #increases attack speed and all ground movement speed
	#blessing, #increases blight and holy defense
	#divine_blessing, #better blessed
	#eyes_of_the_dead, #allows you too talk to dead players
	
	for k in attributes.keys(): #applies a cap on some attributes because yes
		if Lookup.max_attributes.has(k):
			if attributes[k] > Lookup.max_attributes[k]:
				attributes[k] = Lookup.max_attributes[k]
	health = attributes["max_health"]*last_mh_c_l #no infinite health for you :3
	#Global.ghost_communication = attributes["ghost_communication"]
	update_ghost_communication(attributes["ghost_communication"]) #also sets the Global
	update_health_graphics()
	Global.emit_signal("update_attributes", attributes)
	
	

@rpc("any_peer") #yeah yeah go crazy
func set_eye_glow(col : Color) -> void:
	avatar.set_eye_param("shader_parameter/glow_col_2",col)
	avatar.set_eye_param("shader_parameter/glow_col_3",col)
	pass

#func update_stats_from_accessories():
	#set_stats_to_default()
	#var applied_bonuses = []
	#for i in Inventory.accessories.keys():
		#var val = Inventory.accessories[i]
		#if val != "":
			#var data = Lookup.items[val]
			#for k in data[3][1].keys():
				#if attributes.has(k):
					#if typeof(data[3][1][k]) == TYPE_BOOL:
						#attributes[k] = data[3][1][k]
					#else:
						#attributes[k] += data[3][1][k]
			##set bonus
			#if data.size() == 6: #checks for set_bonus key
				#var sb_key = data[5]
				#if !applied_bonuses.has(sb_key):
					#applied_bonuses += [sb_key]
					#var sb_data = Lookup.set_bonus[sb_key]
					#var can_apply = true
					#for c in sb_data[0].keys(): #checks to see if you have all important items
						#if !Inventory.accessories[c] == sb_data[0][c]:
							#can_apply = false
					#if can_apply:
						#print("YOU EQUIPPED A FULL SET! now you get" + str(sb_data[1]))
						#for sbk in sb_data[1].keys():
							#if attributes.has(sbk):
								#if typeof(sb_data[1][sbk]) == TYPE_BOOL:
									#attributes[sbk] = sb_data[1][sbk]
								#else:
									#attributes[sbk] += sb_data[1][sbk]
	#update_health_graphics()
	#pass

var held_item_data = []
var held_item_custom_data = {}
var held_item_count = 0
func update_held_item():
	held_item_data = Inventory.get_held_item_data()
	if held_item_data != []:
		var held_item = Inventory.get_held_item()
		held_item_custom_data = held_item[3]
		held_item_count = held_item[1]
		var mp = held_item_data[1]
		if held_item_custom_data.keys().has("custom_model_path"):
			print("loaded with custom model path")
			mp = held_item_custom_data["custom_model_path"]
		if held_item_custom_data.keys().has("enchantments"):
			var col = Color.BLUE_VIOLET
			if !held_item_custom_data["enchantments"].is_empty():
				col = Lookup.enchantment_colors[held_item_custom_data["enchantments"][0]]
			if held_item_custom_data.keys().has("enchantment_color"):
				col = held_item_custom_data["enchantment_color"]
			update_held_item_graphics(mp,true,col)
			update_held_item_graphics.rpc(mp,true,col)
		else:
			update_held_item_graphics(mp)
			update_held_item_graphics.rpc(mp)
		update_anims_from_item_type(held_item_data[2])
	else:
		held_item_custom_data = {}
		held_item_count = 0
		update_held_item_graphics("")
		update_held_item_graphics.rpc("")
		update_anims_from_item_type(-1)
	print(held_item_custom_data)
	print(held_item_count)
	pass

func update_anims_from_item_type(type):
	
	
	#might add later but animations are a lot
	match type:
		Lookup.itemType.weapons_sword:
			walk_anim_key = "walk_weapon"
			idle_anim_key = "idle_weapon"
			play_arm_anim("draw_weapon")
		Lookup.itemType.weapons_spear:
			walk_anim_key = "walk_staff"
			idle_anim_key = "idle_staff"
			play_arm_anim("draw_staff")
		Lookup.itemType.weapons_scythe:
			walk_anim_key = "walk_weapon"
			idle_anim_key = "idle_weapon"
			play_arm_anim("draw_staff")
		Lookup.itemType.weapons_glaive:
			walk_anim_key = "walk_weapon"
			idle_anim_key = "idle_staff"
			play_arm_anim("draw_weapon")
		Lookup.itemType.book:
			play_arm_anim("read")
		_:
			reset_first_person_hand()
			walk_anim_key = "walk"
			idle_anim_key = "idle"
			pass

@onready var fp_item_handler = $playerAvatar/cameraHandler/hands/handR/fp_item_handler
@onready var tp_item_handler = $playerAvatar/genericAvatar/root/chestBase/shoulder_R/elbowR/tp_item_handler

@rpc("any_peer","reliable")
func update_held_item_graphics(model_path, enchanted = false, enchanted_col = Color.BLUE_VIOLET):
	for f in fp_item_handler.get_children():
		f.queue_free()
	for t in tp_item_handler.get_children():
		t.queue_free()
	if model_path == "":
		return
	var mf = load(model_path).instantiate()
	var mt = load(model_path).instantiate()
	if mf.has_method("enable_item_mode"):
		mf.enable_item_mode()
		mt.enable_item_mode()
	if mf is MeshInstance3D:
		mf.set_layer_mask_value(1,true)
		mf.set_layer_mask_value(2,true)
	if enchanted and mf is MeshInstance3D:
		var mat = mf.get_active_material(0).duplicate()
		mat.set("shader_parameter/enchanted_col", enchanted_col)
		mf.set_surface_override_material(0,mat)
		mt.set_surface_override_material(0,mat)
	elif mf.has_method("set_enchanted_col"):
		mf.set_enchanted_col(enchanted_col)
		mt.set_enchanted_col(enchanted_col)
	fp_item_handler.add_child(mf)
	tp_item_handler.add_child(mt)

@rpc("any_peer", "reliable")
func update_accessories_graphics(a = Inventory.accessories):
	for k in a.keys():
		var enchant_col = Color.BLACK
		var val = a[k]
		if val[3].keys().has("enchantments"):
			var col = Color.BLUE_VIOLET
			if !val[3]["enchantments"].is_empty():
				col = Lookup.enchantment_colors[val[3]["enchantments"][0]]
			if val[3].keys().has("enchantment_color"):
				col = val[3]["enchantment_color"]
			enchant_col = col
		if accessories_paths.has(k):
			if accessories_paths[k] != null:
				for p in accessories_paths[k]:
					p.queue_free()
				accessories_paths[k] = null
		if val[0] != "":
			accessories_paths[k] = []
			for g in Lookup.items[val[0]][3][0]:
				var s = load(g[0]).instantiate()
				var bi = g[1]
				if k == "shoeR" and bi == 2:
					bi = 4
				elif k == "shoeL" and bi == 4:
					bi = 2 #swaps the feet for shoes
				elif (k == "gloveR" or k == "braceletR") and bi == 7:
					bi = 9
				elif (k == "gloveL" or k == "braceletL") and bi == 9:
					bi = 7 #swaps hands for bracelets and gloves
				if bi == 9:
					var s2 = s.duplicate()
					elbowR.add_child(s2)
					accessories_paths[k] += [s2]
					#elbowR.add_child(s.duplicate())
				avatar.bone_paths[bi].add_child(s)
				accessories_paths[k] += [s]
				if s is MeshInstance3D: #does not apply to non mesh items
					var m = s.get_active_material(0).duplicate()
					m.set("shader_parameter/enchanted_col",enchant_col)
					s.set_surface_override_material(0,m)
				elif s.has_method("set_enchanted_col"):
					s.set_enchanted_col(enchant_col)
			
			pass

@rpc("any_peer", "reliable")
func update_attribute_graphics(s = attributes["size"],chaotic = attributes["chaotic_affinity"],divine = attributes["divine_affinity"],arcane = attributes["arcane_affinity"]):
	scale = Vector3(s,s,s)
	var eye_glow = Color.BLACK
	var c_a = chaotic/Lookup.max_attributes["chaotic_affinity"]
	var d_a = divine/Lookup.max_attributes["divine_affinity"]
	var a_a = arcane/Lookup.max_attributes["arcane_affinity"]
	var eye_taper = 0.08
	var smile = 0.0
	if c_a > d_a:
		if c_a > a_a:
			#c_a is highest chaotic
			eye_glow = lerp(eye_glow,Color.WEB_PURPLE,c_a)
			eye_taper = -0.08
			smile = -0.01
		else:
			#a_a is highest arcane
			eye_glow = lerp(eye_glow,Color.SPRING_GREEN,a_a)
			eye_taper = 0.0
			smile = 0.0
	else:
		if d_a > a_a:
			#d_a is highest divine
			eye_glow = lerp(eye_glow,Color.GOLD,d_a)
			smile = 0.02
		else:
			#a_a is highest arcane
			eye_glow = lerp(eye_glow,Color.SPRING_GREEN,a_a)
			eye_taper = 0.0
			smile = 0.0
	set_eye_glow(eye_glow)
	avatar.eye_taper = eye_taper
	avatar.smile_addition = smile


func set_stats_to_default():
	last_mh_c_l = health / attributes["max_health"]
	attributes = base_attributes.duplicate(true)

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity") * 1.5
#var speed_multipler = 1.0

func _update_settings():
	print("updated player settings")
	MouseSensitivity = Settings.user_settings["look_sensitivity"]

var health = 0.0
var mana = 0.0
var stamina = 0.0
var winded = false
func _ready():
	Settings.connect("updated",_update_settings)
	shadow_mat = shadow_mat.duplicate()
	shadow.set_surface_override_material(0,shadow_mat)
	health = attributes["max_health"]
	mana = attributes["max_mana"]
	stamina = attributes["max_stamina"]
	#voip.settup_audio(get_multiplayer_authority())
	var emat = avatar.eyes.get_active_material(0).duplicate()
	avatar.eyes.set_surface_override_material(0, emat)
	var mmat = avatar.mouth.get_active_material(0).duplicate()
	avatar.mouth.set_surface_override_material(0, mmat)
	settup_audio()
	if !is_multiplayer_authority():
		request_cosmetics.rpc()
		return
	get_viewport().connect("size_changed",_on_screen_resized)
	_on_screen_resized() #make sure verything works fine
	avatar.visible = false
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
	tp(Vector3.ZERO,0.0)

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
		#interacting = true
	elif Input.is_action_just_released("interact"):
		stop_interacting()
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
		desired_perspective += 1
		if desired_perspective > 5:
			desired_perspective = 0
		if !forced_perspective:
			set_perspective(desired_perspective)
		#if camera.position.z == 0.0:
			#camera.position.z = 2.0
			#avatar.set_visibility_layer(1, true)
			#avatar.visible = true
			#hands.visible = false
			#AG_handler.visible = true
			#tp_item_handler.visible = true
		#elif camera.position.z == 2.0:
			#camera.position.z = -2.0
			#camera.desired_rot.y = PI
		#else:
			#camera.desired_rot.y = 0.0
			#avatar.set_visibility_layer(1, false)
			#hands.visible = true
			#avatar.visible = false
			#AG_handler.visible = false
			#tp_item_handler.visible = false
			#camera.position.z = 0.0
	if Input.is_action_just_pressed("sprint") and Input.is_action_pressed("up"):
		sprinting = true
	if Input.is_action_just_pressed("up") and Input.is_action_pressed("sprint"):
		sprinting = true
	if Input.is_action_just_released("sprint"):
		sprinting = false
	if Input.is_action_just_released("up"):
		sprinting = false
	if Input.is_action_just_pressed("crouch"):
		desired_crouching = true
	if Input.is_action_just_released("crouch"):
		desired_crouching = false
	if Input.is_action_just_pressed("jump"):
		if is_on_floor() or _snapped_to_stairs_last_frame:
			jump()
		else:
			if flying:
				if jump_buffer > 0.0:
					set_flying(false)
				else:
					jump_buffer = 0.5
					pass #does not feel good but need for double tap :( maybe fix later
			elif attributes["can_fly"] and ! winded:
				set_flying(true)
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
	
	##items and stuff
	if Input.is_action_just_pressed("drop_item"):
		Inventory.drop_hotbar_item(Inventory.held_item, get_non_clipped_look_reference())
	
	##debug stuffs
	if Input.is_action_just_pressed("perish"):
		die(display_name, "perish", "",Vector3(0.0,1.0,0.0))
	if Input.is_action_just_pressed("respawn"):
		respawn()
	if Input.is_action_just_pressed("debugMisc"):
		create_after_image(velocity)
		create_after_image.rpc(velocity)

@rpc("any_peer","unreliable")
func create_after_image(vel = Vector3.ZERO, pos = position, lightness = 0.0):
	var af_im = load("res://assets/avatar/player_after_image.tscn").instantiate()
	var pose = avatar.get_pose()
	af_im.starting_fade = lightness
	get_parent().add_child(af_im)
	af_im.position = pos
	af_im.rotation = rotation
	af_im.rotation.y = graphics.rotation.y + PI + body.rotation.y
	af_im.apply_pose(pose)
	af_im.initial_vel = vel*0.1

func set_flying(val):
	if flying == val:
		return
	flying = val
	if !Settings.user_settings["auto_flying_perspective"]:
		return
	if val:
		set_perspective(Settings.user_settings["desired_flying_perspective"])
		forced_perspective = true
	else:
		set_perspective(desired_perspective)
		forced_perspective = false

@onready var look_reference_check = $playerAvatar/cameraHandler/look_reference_check
func get_non_clipped_look_reference() -> Vector3:
	if look_reference_check.is_colliding():
		var poi = look_reference_check.get_collision_point()
		poi +=  look_reference_check.get_collision_normal()*0.1
		return poi
	else:
		return look_reference.global_position

func jump():
	is_climbing_ladder = false
	jump_buffer = 0.0
	jumped_last_frame = true
	play_footstep()
	if sprinting:
		velocity.y = attributes["jump_velocity"]
	else:
		velocity.y = clamp(attributes["jump_velocity"],0.0,base_attributes["jump_velocity"]*2.0)
	avatar.walk_tilt = 0.0
	avatar.animation_speed = 4.0

@onready var dust_particles = $dust_particles
@onready var impact_particles = $impact_particles
@onready var head_bonk = $head_bonk
var airborn = false
var last_y_velocity = 0.0
var jumped_last_frame = false
var vel_last_frame = Vector3.ZERO
var after_image_pos = Vector3.ZERO
var after_image_this_frame = false
var after_image_buffer = 0

#var spectating = false
#var spectating_entity = null
#var spectate_index = 0
# idea is to trap person in room or around other player but I think I will not do that
#maybe instead just limit what they can do as a ghost
#func spectate_next_player() -> void:
	#var valid_targets = []
	#var players = get_tree().get_nodes_in_group("player")
	#for i in range(0,players.size()):
		#var p = players[i]
		#if !p.ghost:
			#valid_targets += [i]
	#pass

func _physics_process(delta):
	if !is_multiplayer_authority():
		return
	
	if head_bonk.is_colliding():
		crouching = true
	else:
		crouching = desired_crouching
	
	hands.rotation.x -= (velocity.y / attributes["jump_velocity"])*delta*10.0
	
	hands.position = lerp(hands.position, bobHandler.position, delta*64.0)
	hands.rotation = Global.vec3_rot_lerp(hands.rotation, bobHandler.rotation, delta*32.0)
	if is_climbing_ladder:
		climbing_ladder(delta) #nice
		return
	
	if position.y < -200.0:
		position = Vector3.ZERO
	# Add the gravity.
	if not is_on_floor() and not _snapped_to_stairs_last_frame:
		jumped_last_frame = false
		avatar.animation_speed = lerp(avatar.animation_speed, 0.25*attributes["speed_multiplier"], delta*40.0)
		last_y_velocity = velocity.y
		airborn = true
		if !flying and !ghost:
			velocity.y -= gravity * delta
			avatar.falling = lerp(avatar.falling, 1.0, delta*4.0)
		elif !attributes["can_fly"] or winded:
			set_flying(false)
		if jump_buffer != 0.0:
			jump_buffer -= delta
			if jump_buffer < 0.0:
				jump_buffer = 0.0
		#head bonk damage
		if is_on_wall() or is_on_ceiling():
			var mult = (vel_last_frame.length()-velocity.length())/9.8
			var d = int(pow(mult,2.0))
			if d > 0:
				damage([[3,d]],"physics_damage","", "",-vel_last_frame*0.1,false)
				heavy_impact()
				heavy_impact.rpc()
	else:
		set_flying(false)
		if jump_buffer > 0.0:
			jump()
		avatar.animation_speed = 1.0*attributes["speed_multiplier"]
		avatar.falling = 0.0
		if airborn:
			airborn = false
			play_footstep()
			avatar.crouching += abs(last_y_velocity/9.8)*0.25
			var mult = (-last_y_velocity/9.8)*0.9
			var d = int(pow(mult,3.0))
			d = d / (attributes["jump_velocity"] * 0.16666666) #idk why but doing division with a constant feels illigal
			if d > 0:
				damage([[3,d]],"fall_damage","", "",Vector3(0.0,last_y_velocity,0.0),false)
				#if d > 3:
				heavy_impact()
				heavy_impact.rpc()
			#avatar.walk_tilt += abs(last_y_velocity/9.8)*0.25
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("left", "right", "up", "down")
	var direction = (graphics.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if Global.disable_avatar:
		direction = Vector3.ZERO
	cameraHandler.rotation.z = lerp(cameraHandler.rotation.z,0.0,delta*8.0) #for flying tilt reset
	if ghost:
		dust_particles.emitting = false
		velocity -= velocity*delta*attributes["flying_speed"]*0.5
		velocity -= velocity*0.1*delta
		avatar.animation_state = "fly"
		var input_vertical = Input.get_vector("crouch", "jump", "down", "up")
		if sprinting:
			velocity.y = lerp(velocity.y, input_vertical.x * attributes["flying_speed"]*2.2*attributes["speed_multiplier"], delta*8.0)
		else:
			velocity.y = lerp(velocity.y, input_vertical.x * attributes["flying_speed"]*attributes["speed_multiplier"], delta*8.0)
		if direction:
			body.rotation.y = lerp(body.rotation.y, 0.0, delta*4.0)
			avatar.head_angle.y = -body.rotation.y
			if sprinting:
				velocity.x = lerp(velocity.x, direction.x * attributes["flying_speed"]*2.2*attributes["speed_multiplier"], delta*8.0)
				velocity.z = lerp(velocity.z, direction.z * attributes["flying_speed"]*2.2*attributes["speed_multiplier"], delta*8.0)
			else:
				velocity.x = lerp(velocity.x, direction.x * attributes["flying_speed"]*attributes["speed_multiplier"], delta*8.0)
				velocity.z = lerp(velocity.z, direction.z * attributes["flying_speed"]*attributes["speed_multiplier"], delta*8.0)
		else:
			if avatar.walk_angle != 0.0:
				body.rotation.y = avatar.walk_angle
				avatar.head_angle.y = -avatar.walk_angle
				avatar.walk_angle = 0.0
			velocity.x = lerp(velocity.x, 0.0, 4.0*delta)
			velocity.z = lerp(velocity.z, 0.0, 4.0*delta)
	elif flying:
		update_velocity_flying(delta)
	elif direction:
		avatar.animation_state = walk_anim_key
		body.rotation.y = lerp(body.rotation.y, 0.0, delta*4.0)
		avatar.head_angle.y = body.rotation.y
		if !airborn and !jumped_last_frame:
			if sprinting and !crouching and !status_effects.has(Lookup.statusEffectType.cursed):
				velocity.x = lerp(velocity.x, direction.x * attributes["speed"]*2.2*attributes["speed_multiplier"], delta*8.0)
				velocity.z = lerp(velocity.z, direction.z * attributes["speed"]*2.2*attributes["speed_multiplier"], delta*8.0)
			elif crouching:
				velocity.x = lerp(velocity.x, direction.x * attributes["speed"]*0.75*attributes["speed_multiplier"], delta*8.0)
				velocity.z = lerp(velocity.z, direction.z * attributes["speed"]*0.75*attributes["speed_multiplier"], delta*8.0)
			else:
				velocity.x = lerp(velocity.x, direction.x * attributes["speed"]*0.85*attributes["speed_multiplier"], delta*8.0)
				velocity.z = lerp(velocity.z, direction.z * attributes["speed"]*0.85*attributes["speed_multiplier"], delta*8.0)
		else:
			velocity = update_velocity_air(direction, velocity, delta)
	else:
		if avatar.walk_angle != 0.0:
			body.rotation.y = avatar.walk_angle
			avatar.head_angle.y = -avatar.walk_angle
			avatar.walk_angle = 0.0
		avatar.animation_state = idle_anim_key
		avatar.resist_dir = Vector2(0.0,0.0)
		avatar.head_angle.y = -body.rotation.y
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
	
	var true_speed = sqrt(pow(velocity.x,2) + pow(velocity.z,2))/(base_attributes["speed"]*attributes["speed_multiplier"])
	if flying:
		true_speed = sqrt(pow(velocity.x,2) + pow(velocity.z,2))/(base_attributes["flying_speed"])
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
	if flying:
		avatar.crouching = lerp(avatar.crouching, 0.25, delta*12.0)
		cameraHandler.position.y = lerp(cameraHandler.position.y, 0.65, delta*8.0)
	elif crouching:
		avatar.crouching = lerp(avatar.crouching, 0.25, delta*12.0)
		#avatar.crouching = 0.25
		cameraHandler.position.y = lerp(cameraHandler.position.y, 0.9, delta*8.0*2.0)
	else:
		avatar.crouching = lerp(avatar.crouching, 0.0, delta*12.0)
		#avatar.crouching = 0.0
		cameraHandler.position.y = lerp(cameraHandler.position.y, 1.233, delta*8.0)
	avatar.walk_speed = true_speed #lerp(avatar.walk_speed, true_speed, delta*4.0)
	avatar.walk_tilt = lerp(avatar.walk_tilt, 0.15, delta*8.0)
	bobbing(delta, true_speed, input_dir)
	avoid_close_entities(delta)
	#after images
	if after_image_this_frame:
			var lightness = 1.0 / ((after_image_buffer + 1)*2.0)
			create_after_image(velocity,after_image_pos,lightness)
			create_after_image.rpc(velocity,after_image_pos,lightness)
			after_image_buffer -= 1
			after_image_pos = position
			if after_image_buffer < 0:
				after_image_this_frame = false
				after_image_buffer = 0
	if velocity.length() > speed_cap*0.25:
		if velocity.length() > vel_last_frame.length()*1.25:# or velocity.dot(vel_last_frame) < 0.75:
			after_image_this_frame = true
			after_image_buffer = 10
			after_image_pos = position
	
	vel_last_frame = velocity
	if not snap_up_to_stairs_check(delta):
		move_and_slide()
		snap_down_to_stairs_check()
	var vel_length = velocity.length()
	if vel_length > speed_cap:
		velocity = speed_cap * velocity.normalized() #keeps you from going into orbit :3
	speed_appeal = lerp(speed_appeal,velocity.length()/speed_cap,delta*8.0)#Vector2(velocity.x,velocity.z).length()/speed_cap
	var desired_fov = Settings.user_settings["desired_fov"]
	var speed_fov_effect = Settings.user_settings["speed_fov_effect"]
	camera.fov = lerp(desired_fov,desired_fov+speed_fov_effect,speed_appeal)
	Global.set_post("shader_parameter/action_lines",speed_appeal)
	$genericAudio/movement_wind.volume_db = remap(speed_appeal,0.0,1.0,-80.0,-15.0)
	update_shadow()
	sync_information.rpc(position, graphics.rotation.y, body.rotation.y,avatar.animation_state, avatar.walk_speed, avatar.animation_speed, avatar.crouching, avatar.head_angle, avatar.falling, avatar.walk_angle, avatar.walk_tilt,avatar.resist_dir,dust_particles.emitting,room_id)
	$UI/second_pass/SubViewport/second_pass.global_transform = camera.global_transform
	$UI/second_pass/SubViewport/second_pass.fov = camera.fov

func climbing_ladder(delta):
	set_flying(false)
	velocity = Vector3.ZERO
	position.x = ladder_pos.x
	position.z = ladder_pos.y
	
	graphics.rotation.y = clamp(graphics.rotation.y,ladder_facing-PI*0.25,ladder_facing+PI*0.25)
	avatar.animation_speed = 1.0
	avatar.animation_state = "idle"
	if Input.is_action_just_pressed("jump"):
		is_climbing_ladder = false
		jump()
		return
	elif Input.is_action_just_pressed("crouch"):
		is_climbing_ladder = false
		velocity.y = -2.0
		#escape
		return
	if Input.is_action_pressed("up"):
		position.y += delta*2.0
	elif Input.is_action_pressed("down"):
		position.y -= delta*2.0
	if position.y < ladder_height.x:
		#below ladder
		is_climbing_ladder = false
		pass
	elif position.y > ladder_height.y:
		#above ladder
		is_climbing_ladder = false
		#jump() feel bad
		velocity.y = 2.0 #feel good
		pass
	var vel_length = velocity.length()
	if vel_length > speed_cap:
		velocity = speed_cap * velocity.normalized() #keeps you from going into orbit :3
	speed_appeal = lerp(speed_appeal,velocity.length()/speed_cap,delta*8.0)#Vector2(velocity.x,velocity.z).length()/speed_cap
	var desired_fov = Settings.user_settings["desired_fov"]
	var speed_fov_effect = Settings.user_settings["speed_fov_effect"]
	camera.fov = lerp(desired_fov,desired_fov+speed_fov_effect,speed_appeal)
	Global.set_post("shader_parameter/action_lines",speed_appeal)
	$genericAudio/movement_wind.volume_db = remap(speed_appeal,0.0,1.0,-80.0,-15.0)
	update_shadow()
	sync_information.rpc(position, graphics.rotation.y, body.rotation.y,avatar.animation_state, avatar.walk_speed, avatar.animation_speed, avatar.crouching, avatar.head_angle, avatar.falling, avatar.walk_angle, avatar.walk_tilt,avatar.resist_dir,dust_particles.emitting,room_id)
	$UI/second_pass/SubViewport/second_pass.global_transform = camera.global_transform
	$UI/second_pass/SubViewport/second_pass.fov = camera.fov

@onready var shadow = $playerAvatar/projected_shadow/shadow
@onready var shadow_mat = shadow.get_active_material(0)
@onready var shadow_check = $playerAvatar/projected_shadow/shadow_check
func update_shadow():
	if shadow_check.is_colliding():
		shadow.visible = true
		var poi = global_position + Vector3(0.0,shadow_check.get_collision_point(0).y-global_position.y,0.0) #only cares about y pos
		#var norm = shadow_check.get_collision_normal(0)
		shadow.global_position = poi + Vector3(0.0,0.01,0.0)
		#shadow.look_at(norm,Vector3.UP,true)
		var dis = (poi - global_position).length()
		shadow_mat.set("shader_parameter/power",(1.0 - dis*0.5))
	else:
		shadow.visible = false
		#shadow_mat.set("shader_parameter/power",0.0)


func loop_audio(node):
	node.play()
	pass

var speed_appeal = 0.0
var speed_cap = 50.0

var avoid_radius = 0.3
var avoid_strength = 200.0
func avoid_close_entities(delta):
	for e in get_tree().get_nodes_in_group("entity"):
		var dif = e.global_position - global_position
		var dis = dif.length()
		if dis < avoid_radius:
			var dir = dif.normalized()
			var add_v = dir * delta * avoid_strength * (avoid_radius-dis)
			velocity.x += -add_v.x
			velocity.z += -add_v.z
			pass
	pass

@rpc("any_peer","unreliable")
func heavy_impact():
	dust_particles.emitting = true
	Global.create_camera_impact(position, 0.002)
	$genericAudio/anklesBreak.play()
	pass

func update_velocity_gliding(delta):
	var yawcos = cos(graphics.rotation.y);
	var yawsin = sin(graphics.rotation.y);
	var pitchcos = cos(-cameraHandler.rotation.x);
	var pitchsin = sin(-cameraHandler.rotation.x);
	
	var lookX = yawsin * -pitchcos;
	var lookY = -pitchsin;
	var lookZ = yawcos * -pitchcos;
	
	var hvel = sqrt(velocity.x * velocity.x + velocity.z * velocity.z); #Vector2(velocity.x,velocity.z).length
	var hlook = pitchcos;
	var sqrpitchcos = pitchcos * pitchcos;
	
	velocity.y += (-0.08 + sqrpitchcos * 0.06);
	#velocity.y -= gravity * delta
	if (velocity.y < 0 && hlook > 0):
		var yacc = velocity.y * -0.1 * sqrpitchcos * delta * 60.0;
		velocity.y += yacc;
		velocity.x += ((lookX * yacc) / hlook) * 0.5;
		velocity.z += ((lookZ * yacc) / hlook) * 0.5;
	
	if (-cameraHandler.rotation.x < 0):
		var yacc = hvel * -pitchsin * 0.1 * delta * 60.0;
		velocity.y += yacc;
		velocity.x -= ((lookX * yacc) / hlook) * 0.75;
		velocity.z -= ((lookZ * yacc) / hlook) * 0.75;
	
	if (hlook > 0): #turning
		velocity.x += (lookX / hlook * hvel - velocity.x) * 0.1 ; #turning speed
		velocity.z += (lookZ / hlook * hvel - velocity.z) * 0.1 ;
	
	
	#velocity.x *= 0.99 ;
	#velocity.y *= 0.98 ;
	#velocity.z *= 0.99 ; bro why did I type this, it caused me so much trouble for NOOO reason ;-;
	velocity.x -= velocity.x * delta*0.1 #friction
	velocity.z -= velocity.z * delta*0.1
	velocity.y -= velocity.y * delta * 0.1

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
	stamina -= attributes["stamina_regen_speed"]*delta #keeps from regening while flying
	if avatar.walk_angle != 0.0:
		body.rotation.y = avatar.walk_angle
		avatar.head_angle.y = -avatar.walk_angle
		avatar.walk_angle = 0.0
	var mult = (vel_last_frame - velocity).length()/(attributes["flying_speed"]*2.0)
	var d = int(pow(mult,3))
	if d > 0:
		damage([[Lookup.damageType.blunt, d]],"fall_damage","", "",Vector3(0.0,last_y_velocity,0.0))
	avatar.animation_state = "fly"
	if attributes["flying_can_hover"]:
		if attributes["flying_can_glide"]: #bootleg ability to glide while can hover
			if Input.is_action_pressed("jump") and Input.is_action_pressed("crouch"):
				velocity.y -= gravity * delta
				update_velocity_gliding(delta*1.0) #glide
				stamina -= delta*0.05
				body.rotation.y = lerp(body.rotation.y, 0.0, delta*4.0)
				avatar.head_angle.y = -body.rotation.y
				cameraHandler.rotation.z = -body.rotation.y*speed_appeal*0.4*Settings.user_settings["flying_tilt_power"]
				if Input.is_action_pressed("up"):
					velocity += get_look_dir() * attributes["flying_speed"] * delta
				return
		var input_vertical = Input.get_vector("crouch", "jump", "up", "down")
		var input_flat = Input.get_vector("left", "right", "up", "down")
		var f_s = attributes["flying_speed"]
		var desired_vel = f_s * (graphics.transform.basis * Vector3(input_flat.x, input_vertical.x, input_flat.y)).normalized()
		velocity += (desired_vel - velocity) * delta * f_s
		stamina -= delta * 0.5
		#body.rotation.y = lerp(body.rotation.y, 0.0, delta*4.0)
		#avatar.head_angle.y = -body.rotation.y
		if input_flat.length() > 0.05:
			body.rotation.y = lerp(body.rotation.y, 0.0, delta*4.0)
			avatar.head_angle.y = -body.rotation.y
		else:
			if avatar.walk_angle != 0.0:
				body.rotation.y = avatar.walk_angle
				avatar.head_angle.y = -avatar.walk_angle
				avatar.walk_angle = 0.0
		return
	
	var input_vertical = Input.get_vector("crouch", "jump", "down", "up")
	var look_dir = get_look_dir()
	var combined_dir = (Vector3(0.0,input_vertical.x,0.0)+look_dir*input_vertical.y).normalized()
	var speed = velocity.length()
	var f_s = attributes["flying_speed"]*2.5# * 5.0
	velocity.y -= gravity * delta
	#velocity += combined_dir * f_s * delta
	#velocity.y += combined_dir.y * f_s *delta
	var friction = f_s*0.05 + speed/f_s * 0.1
	if velocity.y < 1.0:
		friction = friction * 0.25
	if input_vertical.length() < 0.05: #gliding
		if attributes["flying_can_glide"]:
			update_velocity_gliding(delta*1.0) #glide
			stamina -= delta*0.05
		else:
			velocity.y -= velocity.y * delta * 0.5
		#var speed_horizontal = Vector2(velocity.x, velocity.z).length()
		##velocity.x = lerp(velocity.x,speed_horizontal*look_dir.x,delta)
		##velocity.z = lerp(velocity.z,speed_horizontal*look_dir.z,delta)
		##if look_dir.y > 0.0:
			##velocity.y += (speed*look_dir.y - velocity.y) * delta*clamp((speed/5.0),0.0,1.0)*8.0 #gliding
			##velocity.x += (speed*look_dir.x - velocity.x) * delta*clamp((speed/5.0),0.0,1.0)*1.0 #gliding
			##velocity.z += (speed*look_dir.z - velocity.z) * delta*clamp((speed/5.0),0.0,1.0)*1.0 #gliding
		##else:
			###velocity.y += look_dir.y * delta * f_s
			##velocity.y += (speed*look_dir.y - velocity.y) * delta*clamp((speed/5.0),0.0,1.0)*8.0 #gliding
			##velocity.x += (speed_horizontal*look_dir.x - velocity.x) * delta*clamp((speed/5.0),0.0,1.0)*1.0 #gliding
			##velocity.z += (speed_horizontal*look_dir.z - velocity.z) * delta*clamp((speed/5.0),0.0,1.0)*1.0 #gliding
		#
		#var add_vel_y = (speed*look_dir.y - velocity.y) * delta*clamp((speed/5.0),0.0,5.0)*2.0 #gliding
		#var add_vel_hor = (speed*look_dir - velocity) * delta*clamp((speed/5.0),0.0,5.0)*2.0 #gliding
		##if (add_vel_hor.x > 0.0) == (look_dir.x > 0.0): #makes sure they are aiming the same way
		#if (add_vel_y > 0.0) == (look_dir.y > 0.0): #makes sure they are aiming the same way
			#velocity.y += add_vel_y#(speed*look_dir.y - velocity.y) * delta*clamp((speed/5.0),0.0,1.0)*1.0 #gliding
			##velocity.x -= add_vel_y*look_dir.x
			##velocity.z -= add_vel_y*look_dir.z
		##if (add_vel_hor.z > 0.0) == (look_dir.z > 0.0): #makes sure they are aiming the same way
		#velocity.x += add_vel_hor.x#(speed*look_dir.x - velocity.x) * delta*clamp((speed/5.0),0.0,1.0)*1.0 #gliding
		#velocity.z += add_vel_hor.z#(speed*look_dir.z - velocity.z) * delta*clamp((speed/5.0),0.0,1.0)*1.0 #gliding
		#if speed > speed_cap:
			#velocity -= velocity * delta*10.0
		##velocity.x -= velocity.x * friction * delta*0.01
		##velocity.z -= velocity.z * friction * delta*0.01
	elif abs(input_vertical.y) > 0.05: #flying forward
		velocity += combined_dir * f_s * delta
		stamina -= delta * 0.5
		if attributes["flying_can_glide"]:
			update_velocity_gliding(delta*1.0)
		velocity.y -= velocity.y * friction * delta
		velocity.x -= velocity.x * friction * delta
		velocity.z -= velocity.z * friction * delta
	else: #flying up
		velocity += combined_dir * f_s * delta
		stamina -= delta
		velocity.x -= velocity.x * friction * delta
		velocity.z -= velocity.z * friction * delta
	
	#body.rotation.y = lerp(body.rotation.y, 0.0, delta*4.0)
	#avatar.head_angle.y = -body.rotation.y
	
	body.rotation.y = lerp(body.rotation.y, 0.0, delta*4.0)
	avatar.head_angle.y = -body.rotation.y
	cameraHandler.rotation.z = -body.rotation.y*speed_appeal*0.4*Settings.user_settings["flying_tilt_power"]

func dir_to_angle(dir):
	if dir.y == 0.0 and dir.x == 0.0:
		return 0.0
	return -atan2(-dir.y, -dir.x)+PI*0.5

@onready var bobHandler = $playerAvatar/cameraHandler/bobbingHandler
var time = 0.0
var cameraTiltAdd = 0.0
func bobbing(delta, mult, dir):
	mult = clamp(mult,0.0,4.0)
	if airborn:
		time += delta * 0.25 * (1.0 + (mult-3.0)*0.125) * mult
		bobHandler.position.x = sin(time*32)*mult*0.0005
		bobHandler.position.y = sin(time*37)*mult*0.0005
		bobHandler.rotation.x = sin(time*35)*mult*0.0005
		hands.position.x = sin(time*32+PI)*mult*0.0005
		hands.position.y =  sin(time*32+PI)*mult*0.0005
		bobHandler.rotation.z =  sin(time*32)*mult*0.0005
	else:
		time += delta * (1.0 + (mult-3.0)*0.125)
		bobHandler.position.x = sin(time*16-PI*0.5)*0.002*mult*4.0 * 0.75
		bobHandler.position.y = sin(time*16)*0.006*mult*4.0 * 0.75
		bobHandler.rotation.x = sin(time*16+PI*0.5)*0.001*mult*4.0 
		hands.position.x = sin(time*16.0-PI*0.25)*0.002*mult*4.0 * 0.25
		hands.position.y = sin(time*16.0+PI*0.25)*0.006*mult*4.0 * 0.25
		cameraTiltAdd = lerp(cameraTiltAdd, -dir.x * 0.03 * mult, delta*4.0)
		bobHandler.rotation.z = sin(time*8-PI*0.5)*0.005*mult + cameraTiltAdd

@onready var camera_spring = $playerAvatar/cameraHandler/bobbingHandler/SpringArm3D
var desired_perspective = 0
var forced_perspective = false
func set_perspective(val):
	print("set perspective " + str(val))
	match val:
		1: #third person
			camera.desired_rot.y = 0.0
			camera.desired_rot.x = 0.0
			camera_spring.rotation.y = 0.0
			camera_spring.rotation_degrees.x = 0.0
			var t = get_tree().create_tween()
			#t.tween_property(camera,"position",Vector3(0.0,0.0,2.0),0.1)
			t.tween_property(camera_spring,"spring_length",2.0,0.1)
			avatar.set_visibility_layer(1, true)
			avatar.visible = true
			hands.visible = false
			AG_handler.visible = true
			tp_item_handler.visible = true
		2: #front
			var t = get_tree().create_tween()
			#camera.position = Vector3.ZERO
			camera_spring.spring_length = 0.0
			camera.desired_rot.y = PI
			#t.tween_property(camera,"position",Vector3(0.0,0.0,-2.0),0.1)
			t.tween_property(camera_spring,"spring_length",-2.0,0.1)
			camera_spring.rotation.y = 0.0
			avatar.set_visibility_layer(1, true)
			avatar.visible = true
			hands.visible = false
			AG_handler.visible = true
			tp_item_handler.visible = true
		3: #over shoulder right
			camera.desired_rot.y = 0.1*PI
			var t = get_tree().create_tween()
			#t.tween_property(camera,"position",Vector3(0.75,0.0,0.6),0.1)
			t.tween_property(camera_spring,"spring_length",1.0,0.1)
			camera_spring.rotation.y = -PI*0.1
			avatar.set_visibility_layer(1, true)
			avatar.visible = true
			hands.visible = false
			AG_handler.visible = true
			tp_item_handler.visible = true
		4: #over shoulder left
			camera.desired_rot.y = -0.1*PI
			var t = get_tree().create_tween()
			#t.tween_property(camera,"position",Vector3(-0.75,0.0,0.6),0.1)
			t.tween_property(camera_spring,"spring_length",1.0,0.1)
			camera_spring.rotation.y = PI*0.1
			avatar.set_visibility_layer(1, true)
			avatar.visible = true
			hands.visible = false
			AG_handler.visible = true
			tp_item_handler.visible = true
		5: #third person far
			camera_spring.rotation.y = 0.0
			camera.desired_rot.y = 0.0
			var t = get_tree().create_tween()
			#t.tween_property(camera,"position",Vector3(0.0,0.5,4.0),0.1)
			t.tween_property(camera_spring,"spring_length",4.0,0.1)
			avatar.set_visibility_layer(1, true)
			avatar.visible = true
			hands.visible = false
			AG_handler.visible = true
			tp_item_handler.visible = true
		_: #normal
			camera_spring.rotation.y = 0.0
			var t = get_tree().create_tween()
			camera.desired_rot.y = 0.0
			camera.desired_rot.x = 0.0
			camera_spring.rotation.y = 0.0
			camera_spring.rotation_degrees.x = 0.0
			#t.tween_property(camera,"position",Vector3(0.0,0.0,0.0),0.1)
			t.tween_property(camera_spring,"spring_length",0.0,0.1)
			avatar.set_visibility_layer(1, false)
			avatar.visible = false
			hands.visible = true
			AG_handler.visible = false
			tp_item_handler.visible = false

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
func sync_information(pos: Vector3, rot: float, rotB: float, anim_state: String, WalkS: float, AnimS: float, C: float, HA: Vector2, F:float, A: float, T: float, res_dir: Vector2, em_dust: bool, r_id: int):
	position = pos
	graphics.rotation.y = rot
	body.rotation.y = rotB
	avatar.animation_state = anim_state
	avatar.walk_speed = WalkS
	avatar.animation_speed = AnimS
	avatar.crouching = C
	avatar.head_angle = HA
	cameraHandler.rotation.x = HA.y #only needed for hitbox graphics
	avatar.falling = F
	avatar.walk_angle = A
	avatar.walk_tilt = T
	avatar.resist_dir = res_dir
	dust_particles.emitting = em_dust
	room_id = r_id
	update_shadow()
	pass

var cosmetics_data = [] #loads for everything regardless of local or remote

@rpc("any_peer", "reliable")
func sync_cosmetics(skin, t: Array, dn: String):
	cosmetics_data = [skin,t]
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
	#var mat = load("res://assets/avatar/playerSkin.tres").duplicate()
	#mat.albedo_texture = img
	#var tran_mat = mat.duplicate()
	#tran_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR
	var mat = avatar.base_skin_mat
	var tran_mat = avatar.tran_skin_mat
	var key = "normal"
	if slim: key = "slim"
	var profile_paths = Global.avatar_profiles[key]
	var arm_1_R = load(profile_paths[8]).instantiate()
	var arm_2_R = load(profile_paths[9]).instantiate()
	arm_1_R.set_surface_override_material(0,mat)
	arm_1_R.get_child(0,true).set_surface_override_material(0,tran_mat)
	arm_2_R.set_surface_override_material(0,mat)
	arm_2_R.get_child(0,true).set_surface_override_material(0,tran_mat)
	
	arm_1_R.set_layer_mask_value(1,false)
	arm_1_R.set_layer_mask_value(2,true)
	arm_2_R.set_layer_mask_value(1,false)
	arm_2_R.set_layer_mask_value(2,true)
	
	arm_1_R.get_child(0).set_layer_mask_value(1,false)
	arm_1_R.get_child(0).set_layer_mask_value(2,true)
	arm_2_R.get_child(0).set_layer_mask_value(1,false)
	arm_2_R.get_child(0).set_layer_mask_value(2,true)
	
	handR.get_child(0).add_child(arm_1_R)
	elbowR.get_child(0).add_child(arm_2_R)
	arm_1_R.position = Vector3.ZERO
	arm_2_R.position = Vector3.ZERO
	
	#for m in hands_meshes:
		#m.set_surface_override_material(0, mat)
		#m.visible = !slim
	#for i in h_m_slim:
		#hands_meshes[i].visible = slim

func _on_screen_resized():
	$UI/second_pass/SubViewport.size = DisplayServer.window_get_size()
	print($UI/second_pass/SubViewport.size)

@rpc("any_peer","reliable")
func request_cosmetics() -> void:
	if is_multiplayer_authority():
		sync_cosmetics.rpc(Global.skin, [Global.ears, Global.tail, Global.snout, Global.slim, Global.eyeColor, Global.mouthData], Global.display_name)
		update_accessories_graphics.rpc(Inventory.accessories)
		update_attribute_graphics.rpc(attributes["size"],attributes["chaotic_affinity"],attributes["divine_affinity"],attributes["arcane_affinity"])
		sync_hand_anim.rpc(current_animation)
		set_ghost.rpc(ghost)
		update_status_effect_graphics.rpc(status_effects)

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
func tp(pos : Vector3, rot: float = graphics.rotation.y):
	global_position = pos
	graphics.rotation.y = rot

var last_attacker = ""
var last_attack_forget = 20.0
var last_attack_forget_timer = 0.0

@onready var blood_decal = preload("res://assets/effects/blood_decal.tscn")
@onready var hitmarker = preload("res://assets/effects/hitmarker.tscn")
func damage(data, id, attacker, weapon_name = "", knockback = Vector3.ZERO, count_attacker = false):
	if !is_multiplayer_authority():
		return
	#print(attacker + " hit " + display_name + " with " + str(data) + " damage in the " + id)
	if count_attacker:# and attacker != "":
		last_attack_forget_timer = last_attack_forget
		last_attacker = attacker
	var amount = 0.0
	var primary_damage_type = 0
	var last_primary_damage = 0.0
	for i in data:
		# i = [damage_type, amount]
		var d = i
		var total = 0.0
		var a = attributes
		#var h = hitmarker.instantiate()
		#h.val = d[1]
		#h.type = d[0]
		#h.position = position
		#h.position.y += 0.65
		#get_parent().add_child(h)
		match d[0]:# d = [damage_type, amount]
			Lookup.damageType.generic: #applies defense stuff
				total += d[1] / (a["generic_defense"]*a["true_defense"])
			Lookup.damageType.stab:
				total += d[1] / (a["stab_defense"]*a["true_defense"])
			Lookup.damageType.slash:
				total += d[1] / (a["slash_defense"]*a["true_defense"])
			Lookup.damageType.blunt:
				total += d[1] / (a["blunt_defense"]*a["true_defense"])
			Lookup.damageType.fire:
				total += d[1] / (a["fire_defense"]*a["true_defense"])
			Lookup.damageType.ice:
				total += d[1] / (a["ice_defense"]*a["true_defense"])
			Lookup.damageType.toxic:
				total += d[1] / (a["toxic_defense"]*a["true_defense"])
			Lookup.damageType.explosion:
				total += d[1] / (a["explosion_defense"]*a["true_defense"])
			Lookup.damageType.magic:
				total += d[1] / (a["magic_defense"]*a["true_defense"])
			Lookup.damageType.lightning:
				total += d[1] / (a["lightning_defense"]*a["true_defense"])
			Lookup.damageType.holy:
				total += d[1] / (a["holy_defense"]*a["true_defense"])
			Lookup.damageType.blight:
				total += d[1] / (a["blight_defense"]*a["true_defense"])
			_:
				printerr("unknown_damage_id of : " + str(d[0]))
				total += d[1] / a["true_defense"]
		if total > last_primary_damage:
			last_primary_damage = total
			primary_damage_type = i[0]
		amount += total #adds current damage type to total amount
	if limb_key_to_defense.has(id):
		amount = amount / attributes[limb_key_to_defense[id]] #applies local defense to whole damage value based on key
	health -= amount
	
	var h = hitmarker.instantiate()
	h.val = amount
	h.type = primary_damage_type
	h.position = position
	h.position.y += 0.65
	get_parent().add_child(h)
	
	if is_on_floor() or is_on_wall():
		var col = get_last_slide_collision()
		if col != null: #yeah idk man had it happen once so why not
			var norm = col.get_normal(0)
			var poi = col.get_position(0)
			add_blood(norm,poi)
			add_blood.rpc(norm,poi)
	
	add_hitmarker.rpc(amount,primary_damage_type) #now everyone knows :D
	
	velocity += knockback
	if health <= 0:
		var key = id
		call_deferred("die",attacker, key, weapon_name, knockback, primary_damage_type)
		#die(attacker, key, weapon_name, knockback, primary_damage_type)
	else:
		var t = get_tree().create_tween()
		var visual_pow = clamp((amount/attributes["max_health"])*2.0,0.2,1.0)
		#visual_pow = 0.3
		t.tween_method(set_damaged, Vector2(0.0,visual_pow), Vector2(1.0,visual_pow), 0.25)
		t.connect("finished",set_damaged.bind(Vector2(0.0,0.0)))
		pass
	update_health_graphics()

@rpc("any_peer")
func add_hitmarker(val,type):
	var h = hitmarker.instantiate()
	h.val = val
	h.type = type
	h.position = position
	h.position.y += 0.65
	get_parent().add_child(h)

@rpc("any_peer")
func add_blood(norm,poi):
	var b = blood_decal.instantiate()
	b.unlimited_life_time = true
	$blood_handler.add_child(b)
	b.global_position = poi + norm*0.01
	var rot_y = atan2(norm.x,norm.z)
	var rot_x = atan2(sqrt(pow(norm.x,2.0)+pow(norm.z,2.0)),norm.y)
	b.rotation.y = rot_y
	b.rotation.x = rot_x
	if $blood_handler.get_child_count(false) > 256:
		$blood_handler.get_child(0).queue_free()

func set_damaged(val):
	var sined_val = (sin(val.x*PI)+1.0)*0.5*val.y
	#print("set_damaged " + str(sined_val))
	Global.set_post("shader_parameter/damaged", (sined_val))
	set_damaged_third_person(sined_val)
	set_damaged_third_person.rpc(sined_val)
	pass

@rpc("any_peer")
func set_damaged_third_person(val):
	avatar.set_damaged(val)
	pass

func add_status_effect(id,time):
	if status_effects.has(id):
		status_effects[id] += time
	else:
		status_effects[id] = time
	update_status_effect_graphics(status_effects)
	update_status_effect_graphics.rpc(status_effects)

const fall_damage_messages = [
	" fell to their death",
	" broke their ankles",
	" experienced gravity",
	" jumped off a bridge",
	" fell down the stairs",
	" tripped"
]
const physics_damage_messages = [ #should be funny lmao
	" was thrown violently against a wall",
	" had all of their bones shattered",
	" got their head slammed into the wall", #these first three have to be able to have -by player added to them
	" hit a wall quite forcefully",
	" broke every single one of their bones",
	" violently cracked their skull"
]

const perish_messages = [
	" bid farewell cruel world",
	" died instantly",
	" perished",
	" alt+f4",
	" shuffled off this mortal coil",
	
]

const damage_types_verbs = [
	["hurt", "hit", "wounded"],
	["stabbed","skewered","impaled"],
	["slashed","sliced","cut","severed","chopped"],
	["bashed","bruised","smashed","squished","crushed","flattened"],
	["burned","scorched","incinerated"],
	["froze"],
	["poisoned"],
	["exploded", "dismembered", "disfigured"],
	["cursed"],
	["electrocuted", "shocked", "disintegrate"],
	["blessed","sanctified","purified"],
	["defiled","currupted","tainted","corroded"]
]

const key_nicknames = {
	"head" : ["noggin", "head", "face"],
	"torso" : ["torso", "body", "chest", "stomach"],
	"armR" : ["right arm", "right shoulder"],
	"armL" : ["left arm", "left shoulder"],
	"handR" : ["right hand", "right forearm"],
	"handL" : ["left hand", "left forearm"],
	"legL" : ["left leg", "left thigh"],
	"legR" : ["right leg", "right thigh"],
	"footL" : ["left foot", "left shin", "left toe"],
	"footR" : ["right foot", "right shin", "right toe"],
}

	#generic,
	#stab,
	#slash,
	#blunt,
	#fire,
	#ice,
	#toxic,
	#explosion,
	#magic,
	
	#lightning,
	#holy,
	#blight

signal died
@onready var corpse = preload("res://entities/ragdolls/player_corpse.tscn")
@rpc("any_peer","reliable") #for the funny cool stuff like petrification
func die(attacker = "", key = "", weapon_name = "", add_vel = Vector3.ZERO, damage_id = 0):
	if !is_multiplayer_authority():
		ghost = true #for the creatures
		return
	clear_status_effects = true
	print(attacker)
	print(last_attacker)
	Global.emit_signal("player_death")
	health = attributes["max_health"]
	if attacker == "":
		attacker = last_attacker
	Global.print_chat(get_death_message(attacker,key,weapon_name,damage_id), "red")
	#match key: #died to natrual causes
		#"fall_damage" : 
			#if attacker == "":
				#if last_attacker == "": #died natrually
					#Global.print_chat((display_name + fall_damage_messages.pick_random()), "red")
				#else:#died to natrual causes while fighting attacker
					#Global.print_chat((display_name + fall_damage_messages.pick_random()) + " while running from " + last_attacker, "red")
			#else:
				#Global.print_chat((display_name + fall_damage_messages.pick_random()) + " while running from " + last_attacker, "red")
		#"perish": 
			#if attacker == "":
				#if last_attacker == "": #died natrually
					#Global.print_chat((display_name + perish_messages.pick_random()), "red")
				#else:#died to natrual causes while fighting attacker
					#Global.print_chat((display_name + perish_messages.pick_random()) + " while fighting " + last_attacker, "red")
			#else:
				#Global.print_chat((display_name + perish_messages.pick_random()) + " while fighting " + last_attacker, "red")
			#pass
		#_:
			#if !key_nicknames.has(key):
				#if last_attacker != "":
					#Global.print_chat(display_name + " died to " + key + " " + weapon_name + " while fighting " + last_attacker, "red")
				#else:
					#Global.print_chat(display_name + " died to " + key + " " + weapon_name, "red")
				#pass
			#elif attacker == "":
				#if last_attacker == "":
					##natrual
					#Global.print_chat(display_name + " got their " + key_nicknames[key].pick_random() + damage_types_verbs[damage_id].pick_random(), "red")
				#else:
					#Global.print_chat(display_name + " got their " + key_nicknames[key].pick_random() + damage_types_verbs[damage_id].pick_random() + " while fighting " + last_attacker, "red")
					##natrual while fighting
					#pass
			#else:
				#Global.print_chat(display_name + " was " + damage_types_verbs[damage_id].pick_random() + " in the " + key_nicknames[key].pick_random() + " by " + attacker, "red")
				##fighting
				#pass
		#"head" : 
	if !is_multiplayer_authority():
		await  get_tree().process_frame
		#emit_signal("died") #phantom signal will do this after the other calls are made
		return
	update_health_graphics()
	#create_ragdoll.rpc(add_vel, position, graphics.rotation.y, velocity,Inventory.accessories)
	#await create_ragdoll(add_vel, position, graphics.rotation.y, velocity,Inventory.accessories)
	#add_vel,pos,rot,vel,acc,key = "", damage_id = 0
	create_appropriate_corpse(add_vel,position,graphics.rotation.y,velocity,Inventory.accessories,key,damage_id)
	create_appropriate_corpse.rpc(add_vel,position,graphics.rotation.y,velocity,Inventory.accessories,key,damage_id)
	await get_tree().process_frame
	update_status_effect_graphics({})
	update_status_effect_graphics.rpc({})
	set_ghost(true)
	set_ghost.rpc(true)
	velocity = Vector3.ZERO
	await  get_tree().process_frame
	emit_signal("died")
	phantom_signal.rpc("died")
	Inventory.drop_all(position)
	#tp(Vector3.ZERO,0.0)

func get_death_message(attacker = "", key = "", weapon_name = "", damage_id = 0) -> String:
	var message = ""
	match key:
		"fall_damage":
			message = display_name + fall_damage_messages.pick_random()
			if attacker != "":
				message = display_name + " was pushed off cliff by " + attacker
		"physics_damage":
			message = display_name + physics_damage_messages.pick_random()
			if attacker != "":
				message = display_name + physics_damage_messages[randi_range(0,2)] + " by " + attacker
		"perish":
			message = display_name + perish_messages.pick_random()
			if attacker != "":
				message += " while fighting " + attacker
		"petrification":
			message = display_name + " was turned to stone"
			if attacker != "":
				message += " by " + attacker
		"status_effect":
			match damage_id:
				Lookup.damageType.fire:
					message = display_name + " went up in flames"
				Lookup.damageType.blight:
					message = display_name + " wasted away"
				Lookup.damageType.toxic:
					message = display_name + " choked on poison"
				Lookup.damageType.holy:
					message = display_name + " was purged"
				Lookup.damageType.magic:
					message = display_name + " fell to a hex"
			if attacker != "":
				message += " while fighting " + attacker
		_:
			if attacker == "":
				message = display_name + " got " + damage_types_verbs[damage_id].pick_random()
			else:
				message = display_name + " was " + damage_types_verbs[damage_id].pick_random() + " by " + attacker
	return message

@rpc("any_peer","reliable")
func create_appropriate_corpse(add_vel,pos,rot,vel,acc,key = "", damage_id = 0) -> void:
	match key:
		"petrification":
			create_petrification_statue(pos,rot)
		_:
			create_ragdoll(add_vel,pos,rot,vel,acc)

@rpc("unreliable","call_remote")
func phantom_signal(signal_key : String): #sick ass function name
	emit_signal(signal_key)

@rpc("any_peer", "reliable")
func set_ghost(val):
	ghost = val
	print("set_ghost")
	$ghostParticles.emitting = val
	voip.set_ghostly(val)
	avatar.set_ghost(val)
	#set_collision_layer_value(3, !val)
	#set_collision_mask_value(1, !val)
	#we want collision now no more flying through stuff because of room system
	if val:
		avatar.set_eye_param("blend_mode", 1)
		avatar.set_mouth_param("blend_mode", 1)
		#$playerAvatar/cameraHandler/hands/handR/rightArm2N.get_active_material(0).set("blend_mode", 1)
		handR.get_child(0).get_child(0).get_active_material(0).set("blend_mode", 1)
		handR.get_child(0).get_child(0).get_child(0,true).get_active_material(0).set("blend_mode", 1)
	else:
		avatar.set_eye_param("blend_mode", 0)
		avatar.set_mouth_param("blend_mode", 0)
		#$playerAvatar/cameraHandler/hands/handR/rightArm2N.get_active_material(0).set("blend_mode", 0)
		handR.get_child(0).get_child(0).get_active_material(0).set("blend_mode", 0)
		handR.get_child(0).get_child(0).get_child(0,true).get_active_material(0).set("blend_mode", 0)
	set_invulnerable(val)
	print("set_ghost2")
	if !is_multiplayer_authority():
		$playerAvatar/genericAvatar/root/chestBase/neck/nameTag.visible = !val
	else:
		if !attributes["ghost_communication"]:
			Global.ghost_communication = val # always yes if ghost but otherwise skill
		if val:
		#print("set_ghost_perspective")
			velocity -= get_look_dir() * 4.0 #push you back a bit so it feels like you left body
		#set_perspective(3)
		#forced_perspective = true
		#no longer forced because it feels bad
	#else:
		#set_perspective(desired_perspective)
		#forced_perspective = false
	if is_multiplayer_authority(): #makes sure visibility is always correctly set
		update_health_graphics() #yeah this too
		if val: #you are a ghost
			for p in get_tree().get_nodes_in_group("player"):
				if p.ghost:
					p.set_mute(false)
					p.set_graphics_visible(true) #you are ghost can see everyone (invisibility will be in shader if I even add it)
		else:
			if Global.ghost_communication: #alive but can see them anyways
				#dont really need to do anything because you can always see them
				pass
			else: #cannot see them now so have to hide manually
				for p in get_tree().get_nodes_in_group("player"):
					if p.ghost:
						p.set_mute(true)
						p.set_graphics_visible(false) #you are ghost can see everyone (invisibility will be in shader if I even add it)
	else:
		if val: #only for non main person players
			if !Global.ghost_communication: #handles it if your
				set_mute(true)
				set_graphics_visible(false)
			else:
				set_mute(false)
				set_graphics_visible(true)
		else: #always visible and not mute when alive 
			#(i dont think an attribute that mutes you would ever be fun so no dont need to worry about that)
			set_mute(false)
			set_graphics_visible(true)

func update_ghost_communication(val : bool): #specifically for the ghost_communication attribute
	if ghost: #dead
		#really dont need to do anything you should already be able to see everyone
		pass
	else: #alive
		if val == Global.ghost_communication:
			return #no need to compute this again its up to date
		#need to compute again
		Global.ghost_communication = val
		if val: #you can see them now couldnt before
			for p in get_tree().get_nodes_in_group("player"):
				if p.ghost:
					p.set_mute(false)
					p.set_graphics_visible(true)
		else: #you cant see them now could before
			for p in get_tree().get_nodes_in_group("player"):
				if p.ghost:
					p.set_mute(true)
					p.set_graphics_visible(false)


func set_invulnerable(val):
	if val:
		for h in hurtboxes:
			h.set_collision_layer_value(4,false)
			h.set_collision_layer_value(7,false)
	else:
		settup_team_hurtboxes(is_multiplayer_authority())
	pass

func respawn(pos = position):
	position = pos
	health = attributes["max_health"]
	set_ghost(false)
	set_ghost.rpc(false)
	update_health_graphics()

@rpc("any_peer","reliable")
func reset_all(): #like it was all a bad dream
	print("reset all")
	respawn(Vector3.ZERO)
	leave_no_trace()

func leave_no_trace() -> void: #cleans up all blood and bodies
	print("left no trace")
	for c in $ragdollHandler.get_children(false):
		c.queue_free()
	for b in $blood_handler.get_children(false):
		b.queue_free()

@rpc("any_peer","reliable")
func create_ragdoll(add_vel,pos,rot,vel,acc):
	if $ragdollHandler.get_child_count(false) > 8:
		$ragdollHandler.get_child(0).queue_free()
	#makes sure there is never a truly unholy amount of ragdolls
	var c = corpse.instantiate()
	await get_tree().physics_frame
	c.rotation.y = rot
	c.position = pos
	c.accessories = acc
	c.connect("blood_decal",add_blood) #allows player to handle blood seperately
	$ragdollHandler.add_child(c)
	var mat = avatar.base_skin_mat.duplicate()#meshes[1].get_active_material(0).duplicate()
	#mat.set("blend_mode", 0)
	c.load_skin(mat,avatar.is_slim)
	c.activate("", vel+add_vel, Vector3(0.0,5.0,0.0))
	return true

func create_petrification_statue(pos:Vector3,rot:float)-> void:
	if $ragdollHandler.get_child_count(false) > 8:
		$ragdollHandler.get_child(0).queue_free()
	#makes sure there is never a truly unholy amount of ragdolls
	var c = load("res://entities/ragdolls/petrified_player_corpse.tscn").instantiate()
	c.rotation.y = rot
	c.position = pos
	#->stone does not bleed
	#c.connect("blood_decal",add_blood) #allows player to handle blood seperately
	$ragdollHandler.add_child(c)
	var mat = avatar.base_skin_mat.duplicate()
	#mat.set("blend_mode", 0)
	#c.set_mat(mat)
	c.load_skin(cosmetics_data)
	c.set_pose(avatar.get_pose()) #:3

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
	if ghost:
		return
	var type = -1
	if held_item_data != []:
		type = held_item_data[2]
	
	match type:
		Lookup.itemType.book :use_book(false)
		Lookup.itemType.weapons_sword: use_sword()
		Lookup.itemType.weapons_projectile: use_projectile_weapon()
		Lookup.itemType.weapons_longsword: use_longsword()
		Lookup.itemType.weapons_mace: use_mace()
		Lookup.itemType.weapons_fishing_rod: use_fishing_rod()
		Lookup.itemType.weapons_bow: use_bow()
		Lookup.itemType.weapons_spear: use_spear()
		Lookup.itemType.weapons_glaive: use_glaive()
		Lookup.itemType.weapons_scythe: use_scythe()
		Lookup.itemType.weapons_wand: use_wand()
		Lookup.itemType.weapons_spellbook: use_spellbook()
		_:
			punch()
	pass

func use_book(flip_forward : bool):
	for b in fp_item_handler.get_children(false):
		if flip_forward and b.has_method("flip_forward"):
			b.flip_forward()
		elif b.has_method("flip_back"):
			b.flip_back()

func punch():
	deal_look_damage()
	play_arm_anim("punch")
	pass

func use_sword():
	if Input.is_action_pressed("rm"):
		play_arm_anim("stab_1")
		#deal_look_damage(held_item_data[3][2],held_item_data[3][1])
		deal_sword_sweep(held_item_data[3][2], held_item_data[0],1.0)
	elif current_animation == "slash_1":
		#deal_look_damage(held_item_data[3][0],held_item_data[3][1])
		deal_sword_sweep(held_item_data[3][0], held_item_data[0],1.0)
		play_arm_anim("slash_2")
	elif current_animation == "slash_2":
		play_arm_anim("stab_1")
		#deal_look_damage(held_item_data[3][2],held_item_data[3][1])
		deal_sword_sweep(held_item_data[3][2], held_item_data[0],1.0)
	else:
		play_arm_anim("slash_1")
		#deal_look_damage(held_item_data[3][0],held_item_data[3][1])
		deal_sword_sweep(held_item_data[3][0], held_item_data[0],1.0)

func use_longsword():
	print("used longsword")

func use_mace():
	print("used mace")

func use_fishing_rod():
	print("used fishing rod")

func use_bow():
	print("used bow")

func use_spear():
	print("used spear")

func use_glaive():
	print("used glaive")

func use_scythe():
	print("used scythe")

func use_wand():
	print("used wand")
	mana -= 1.0
	update_mana_graphics()
	Global.instance_projectile("lightning_seed", get_non_clipped_look_reference(), get_look_dir(), display_name)

func use_spellbook():
	print("used spellbook")
	summon_lightning()

@onready var distance_look = $playerAvatar/cameraHandler/bobbingHandler/distance_select
func summon_lightning():
	#print("summoned lightning")
	#var l = load("res://entities/lightning_bolt.tscn").instantiate()
	#Global.instance_creature("lightning",global_position)
	if distance_look.is_colliding():
		var poi = distance_look.get_collision_point()
		Global.instance_projectile("lightning", poi, Vector3.UP, display_name)
	else:
		#dont summon lightning if cannot find target :3
		pass
	pass

func use_projectile_weapon():
	if mana - 2.0 < 0.0:
		return
	else:
		mana -= 2.0
	var proj_key = held_item_data[3][0]
	var anim_key = held_item_data[3][1]
	play_arm_anim(anim_key)
	#Global.emit_signal("spawn_projectile", proj_key, look_reference.global_position, get_look_dir(), display_name)
	spawn_projectile_test(proj_key)
	pass

func spawn_projectile_test(key):
	var proj = Lookup.Projectiles[key].instantiate()
	proj.dir = get_look_dir()
	proj.owned_by = display_name
	$projectile_handler.add_child(proj, true)
	proj.position = look_reference.global_position
	proj.velocity = proj.dir*proj.speed
	proj.connect("hit",_on_projectile_hit)

func _on_projectile_hit(id):
	if id == "head":
		
		pass
	else:
		
		
		pass
	pass

func _on_right_mouse():
	#Global.emit_signal("spawn_projectile", "arrow", look_reference.global_position, get_look_dir(), display_name)
	var type = -1
	if held_item_data != []:
		type = held_item_data[2]
	
	match type:
		Lookup.itemType.book:use_book(true)
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
#interact returns should be formatted like so
@onready var look = $playerAvatar/cameraHandler/bobbingHandler/look
func attempt_to_interact(primary_interact = true):
	if look.is_colliding():
		var hit = look.get_collider()
		if hit == null:
			printerr("something was deleted before could interact check your code fucker :/")
			return
		if hit.is_in_group("interact"):
			time_to_interact = hit.interact_time
			var ret = hit.interact()
			interacting_timer = time_to_interact
			interact_data = [ret, primary_interact, hit]
			
			interact_initial_pos = position
			interact_initial_rot = Vector2(graphics.rotation.y,cameraHandler.rotation.x)
			initial_distance_to_interact = (hit.global_position - position).length()
			
			interacting = true
			print("started_interacting: " + str(ret))
			#print(ret)
			#process_interact_data(ret, primary_interact, hit)
			return
	print("invalid interact")

var time_to_interact = 0.75
var interacting = false
var interacting_timer = 0.0
var interact_data = null #[ret,primary_interact,hit]
var interact_initial_rot = Vector2.ZERO
var interact_initial_pos = Vector3.ZERO
var initial_distance_to_interact = 0.0

var is_climbing_ladder = false
var ladder_pos = Vector2.ZERO
var ladder_height = Vector2.ZERO
var ladder_facing = 0.0

var room_id = 0

func process_interact_data(data, normal, hit):
	match data[0]:
		Lookup.interact_return_code.is_item: 
			if Inventory.pickup_item(data[1], !normal):#is item should pick it up
				hit.destroy()
			else:
				print("cant pick up inventory full")
		Lookup.interact_return_code.is_doorway:
			var old_room_id = room_id
			position = data[1][0]
			graphics.rotation.y += data[1][1]
			room_id = data[1][2]
			Global.emit_signal("enter_room",data[1][2])
			if !ghost:
				Global.play_sound(position,"res://assets/sounds/environment_interaction/doorOpen.ogg",room_id)
				Global.play_sound(position,"res://assets/sounds/environment_interaction/doorClose.ogg",old_room_id)
			pass
		Lookup.interact_return_code.is_ladder:
			is_climbing_ladder = true
			var li = data[1] #[xz_pos, height_min_max,facing_rot]
			ladder_pos = li[0]
			ladder_height = li[1]
			ladder_facing = li[2]
			position.y = clamp(position.y,ladder_height.x,ladder_height.y)
			position.x = ladder_pos.x
			position.z = ladder_pos.y

func enter_door(door_index : int) -> void:
	var dd= Global.doors_val[door_index] #[Location, output_location, output room_id, room_id]
	var old_room = room_id
	position = dd[1]
	graphics.rotation.y += 0.0 #rotation add is not store for navigation so just keep same rot
	room_id = dd[2]
	Global.emit_signal("enter_room",room_id)
	Global.play_sound(position,"res://assets/sounds/environment_interaction/doorClose.ogg",old_room)
	Global.play_sound(position,"res://assets/sounds/environment_interaction/doorOpen.ogg",room_id)

##audio handling
func settup_audio():
	avatar.connect("step",play_footstep)
	$genericAudio/movement_wind.connect("finished", loop_audio.bind($genericAudio/movement_wind)) #makes audio play after finished
	pass

const footstep_sounds = [
	#"res://assets/sounds/player/fabricStep1.ogg",
	#"res://assets/sounds/player/footsteps3.ogg",
	"res://assets/sounds/footsteps/stone/footstepStone4.wav",
	"res://assets/sounds/footsteps/stone/footstepStone1.wav"
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
@onready var elbowR = $playerAvatar/cameraHandler/hands/handR/elbow

func play_arm_anim(key):
	reset_first_person_hand()
	current_animation = key
	play_avatar_arm_anim(key)
	play_avatar_arm_anim.rpc(key)
	anim_time = 1.0

func reset_first_person_hand() -> void:
	handR.position = Vector3(0.566,-0.382,-0.129)
	handR.rotation_degrees = Vector3(90.0,-9.1,0.0)
	fp_item_handler.position = Vector3(0.0,-0.465,-0.09)
	fp_item_handler.rotation_degrees = Vector3(-90.0,0.0,0.0)

@rpc("any_peer","reliable")
func play_avatar_arm_anim(key):
	anim_event = 0
	avatar.play_arm_anim(key)

var anim_event = 0
var anim_time = 0.0
var current_animation = ""
func _process(delta):
	if last_attack_forget_timer > 0.0:
		last_attack_forget_timer -= delta
	elif last_attack_forget_timer < 0.0:
		print("forgot attacker")
		last_attack_forget_timer = 0.0
		last_attacker = ""
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
			anim_time -= delta*3.0*2.0
			handR.position = lerp(Vector3(0.37,-0.415,-0.095), Vector3(-0.272,-0.538,-0.048), (1.0 - anim_time))
			handR.rotation_degrees = Global.vec3_rot_lerp(Vector3(17.1,-101,-112), Vector3(26.6,-17.6,-70.6), (1.0 - anim_time))
			#if anim_time < 0.5 and anim_event == 0:
				#deal_look_damage(held_item_data[3][0],held_item_data[3][1])
				#anim_event = 1
			if anim_time < 0.1 and Input.is_action_pressed("lm"):
				_on_left_mouse()
			if anim_time < 0.0:
				current_animation = ""
		"slash_2":
			fp_item_handler.rotation.x = -PI*0.5 - (1.0 - anim_time)*PI*0.5
			anim_time -= delta*3.0*2.0
			handR.position = lerp(Vector3(0.171,-0.193,-0.048), Vector3(0.257,-0.193,-0.048), (1.0 - anim_time))
			handR.rotation_degrees = Global.vec3_rot_lerp(Vector3(35.8,128.6,92.7), Vector3(15.3,46.5,71.8), (1.0 - anim_time))
			#if anim_time < 0.5 and anim_event == 0:
				#deal_look_damage(held_item_data[3][0],held_item_data[3][1])
				#anim_event = 1
			if anim_time < 0.1 and Input.is_action_pressed("lm"):
				_on_left_mouse()
			if anim_time < 0.0:
				current_animation = ""
		"stab_1":
			anim_time -= delta * 2.0*2.0
			var val = (1.0 - anim_time)
			if anim_time > 0.5:
				handR.position = lerp(handR.position, Vector3(0.26,-0.193,0.326), val*2.0)
				handR.rotation_degrees = Global.vec3_rot_lerp(handR.rotation_degrees, Vector3(16.6,49.6,84.8), val*2.0)
				fp_item_handler.rotation.x = lerp_angle(fp_item_handler.rotation.x, 2.89724655831, val*2.1)
			else:
				handR.position = lerp(Vector3(0.26,-0.193,0.326), Vector3(0.224,-0.19,-0.101),(val*2.0)-1.0)
				handR.rotation_degrees = Global.vec3_rot_lerp(Vector3(16.6,49.6,84.8), Vector3(16.0,94.5,98.0),(val*2.0)-1.0)
				#if anim_time < 0.25 and anim_event == 0:
					##stabs deal three hits of halfed damage total 1.5 damage
					##stabs should not deal knockback
					#deal_look_damage(held_item_data[3][2],held_item_data[3][1])
					#anim_event = 1
				#elif anim_time < 0.2 and anim_event == 1:
					#deal_look_damage(held_item_data[3][2],held_item_data[3][1])
					#anim_event = 2
				#elif anim_time < 0.15 and anim_event == 2:
					#deal_look_damage(held_item_data[3][2],held_item_data[3][1])
					#anim_event = 3
			if anim_time < 0.0:
				current_animation = ""
			pass
		"read":
			handR.position = Vector3(0.163,-0.554,-0.243)
			handR.rotation_degrees = Vector3(50.3,-140.2,-163.9)
			fp_item_handler.position = Vector3(-0.153,-0.514,-0.192)
			fp_item_handler.rotation_degrees = Vector3(-44.9,9.5,24.6)
	if !is_multiplayer_authority():
		return
	$UI/tooltip.visible = false
	if look.is_colliding():
		var hit = look.get_collider()
		if hit != null:
			if hit.is_in_group("tool_tip"):
				$UI/tooltip.visible = true
				$UI/tooltip.text = hit.tool_tip
				$UI/tooltip.modulate = hit.tool_tip_color
	status_effect_timer -= delta
	if status_effect_timer < 0.0:
		status_effect_timer = 0.25
		if !clear_status_effects:
			update_status_effect_ui()
			for k in status_effects.keys():
				match k:
					Lookup.statusEffectType.burning:
						status_effects[k] -= 0.25
						damage([[Lookup.damageType.fire,0.25]], "status_effect", "", "burning")
						if status_effects[k] < 0.0 or (velocity.length() > speed_cap*0.5):
							status_effects.erase(k)
							update_status_effect_graphics(status_effects)
							update_status_effect_graphics.rpc(status_effects)
					Lookup.statusEffectType.blighted:
						status_effects[k] -= 0.25
						damage([[Lookup.damageType.blight,0.25*2.5]], "status_effect", "", "blighted")
						if status_effects[k] < 0.0:
							status_effects.erase(k)
							update_status_effect_graphics(status_effects)
							update_status_effect_graphics.rpc(status_effects)
					Lookup.statusEffectType.poisoned:
						status_effects[k] -= 0.25
						damage([[Lookup.damageType.toxic,0.25*1.75]], "status_effect", "", "poisoned")
						if status_effects[k] < 0.0:
							status_effects.erase(k)
							update_status_effect_graphics(status_effects)
							update_status_effect_graphics.rpc(status_effects)
					Lookup.statusEffectType.cursed:
						status_effects[k] -= 0.25
						damage([[Lookup.damageType.magic,0.25*1.0]], "status_effect", "", "cursed")
						if status_effects[k] < 0.0:
							status_effects.erase(k)
							update_status_effect_graphics(status_effects)
							update_status_effect_graphics.rpc(status_effects)
					Lookup.statusEffectType.blessed:
						status_effects[k] -= 0.25
						#healing function here
						damage([[Lookup.damageType.magic,-0.25*1.0]], "status_effect", "", "blessed")
						if status_effects[k] < 0.0:
							status_effects.erase(k)
							update_status_effect_graphics(status_effects)
							update_status_effect_graphics.rpc(status_effects)
		else:
			print("clearing status effects")
			for k in status_effects.keys():
				print(k)
				status_effects.erase(k)
			clear_status_effects = false
	if mana < attributes["max_mana"]:
		mana += delta * attributes["mana_regen_speed"]
		if mana > attributes["max_mana"]:
			mana = attributes["max_mana"]
		update_mana_graphics()
	if stamina < attributes["max_stamina"]:
		if stamina < 0.0:
			set_flying(false)
			winded = true
			stamina = 0.0
		stamina += delta * attributes["stamina_regen_speed"]
		if stamina > attributes["max_stamina"] * 0.5:
			winded = false
		if stamina >= attributes["max_stamina"]:
			stamina = attributes["max_stamina"]
		update_stamina_graphics()
	
	#interacting
	if interacting:
		interacting_timer -= delta
		update_interacting_graphics()
		if interacting_timer < 0.0:
			interacting_timer = 0.0
			process_interact_data(interact_data[0],interact_data[1],interact_data[2])
			stop_interacting()
		elif (interact_initial_pos - position).length() > 0.5:
			if initial_distance_to_interact > (interact_data[2].global_position - position).length():
				print("waved movement interact cancel because distance was closer to target")
				interact_initial_pos = position
			else: stop_interacting()
			print("moved to far")
		elif (interact_initial_rot.x > graphics.rotation.y+PI*0.25) or (interact_initial_rot.x < graphics.rotation.y-PI*0.25):
			stop_interacting()
			print("rotated to far horizontal")
		elif (interact_initial_rot.y > cameraHandler.rotation.x+PI*0.25) or (interact_initial_rot.y < cameraHandler.rotation.x-PI*0.25):
			stop_interacting()
			print("rotated to far vertical")
		#i feel like those parameters are lenient enough
var clear_status_effects : bool = true
var status_effect_timer  : float = 0.25

func stop_interacting():
	interacting = false
	$UI/crosshairControl/crosshair.hide()
	print("stopped interacting")

func update_interacting_graphics():
	$UI/crosshairControl/crosshair.visible = true
	$UI/crosshairControl/crosshair.frame = int(remap(interacting_timer,0.0,time_to_interact,0.0,4.0))
	
	pass

func update_mana_graphics():
	$UI/mana.text = str(round(mana)) + " / " + str(attributes["max_mana"])
	Global.emit_signal("update_mana_graphics",mana)
	pass

func update_stamina_graphics():
	$UI/stamina.text = str(round(stamina)) + " / " + str(attributes["max_stamina"])
	if winded:
		$UI/stamina.set("theme_override_colors/font_color",Color.YELLOW)
	else:
		$UI/stamina.set("theme_override_colors/font_color",Color.LIME_GREEN)
	pass

func update_status_effect_ui():
	var text = ""
	for k in status_effects.keys():
		text += Lookup.status_effect_names[k] + " : " + str(round(status_effects[k])) + "\n"
	$UI/status_effects/RichTextLabel.text = text
	pass

func deal_look_damage(dam := [[Lookup.damageType.generic, 1]], dist := 2.0) -> void:
	var weapon_name = "hands"
	if !held_item_data == []:
		weapon_name = held_item_data[0]
	attack_look.target_position = Vector3(0.0,0.0,-dist)
	if attack_look.is_colliding():
		var hit = attack_look.get_collider()
		var poi = attack_look.get_collision_point()
		var dir = get_look_dir() + Vector3(0.0,0.5,0.0)
		if hit.is_in_group("hurtbox"):
			hit.take_damage.rpc(dam,poi,display_name,weapon_name, dir*attributes["strength"]*2.0, true)

@onready var hitbox_handler = $playerAvatar/cameraHandler/hitboxes
@onready var near_hitbox = $playerAvatar/cameraHandler/hitboxes/near_hitbox
func deal_sword_sweep(dam, weapon_name, knockback_mult = 1.0):
	var h = hitbox.new()
	h.active_time = 0.5
	h.damage = dam
	h.weapon_name = weapon_name
	h.knockback = get_look_dir() * knockback_mult
	h.remember = true
	h.size = Vector3(2.0,2.0,2.0)
	h.position.z -= 1.5
	#h.friendly_node = get_path_to(self)
	h.no_hit_list += [self]
	hitbox_handler.add_child(h)
	add_hh_child.rpc(h.size, Vector3(0.0,0.0,-1.5), h.active_time, weapon_name)
	return ##pre hitbox code
	var col_count = near_hitbox.get_collision_count()
	var dir = get_look_dir()
	print(str(col_count))
	print(weapon_name)
	print(dam)
	for i in range(0,col_count):
		var hit = near_hitbox.get_collider(i)
		if hit.is_in_group("hurtbox"):
			var poi = near_hitbox.get_collision_point(i)
			hit.take_damage.rpc(dam,poi,display_name,weapon_name, dir*knockback_mult, true)
			print("hurtbox found " + str(hit))
		else:
			print("hit wall ending swing")
			break #cannot hit through walls
	pass

@rpc("any_peer")
func add_hh_child(size : Vector3, offset : Vector3, life_time : float, weapon_name := "", active := false) -> void:
	var h = hitbox.new() #for other people to see
	h.size = size
	h.active = active
	h.active_time = life_time
	h.weapon_name = weapon_name
	h.position = offset
	hitbox_handler.add_child(h)

##ui and stuffs
func update_health_graphics():
	Global.emit_signal("update_health_graphics",health,attributes["max_health"])
	var percent = remap(health,0.0,attributes["max_health"],0.0,1.0)
	Global.set_post("shader_parameter/heart_pounding",1.0-percent)
	var rounded_health = round(health * 4.0)*0.25 #rounds to nearest .25
	$UI/health.text = str(rounded_health) + " / " + str(attributes["max_health"]) + " HP"
	var dif = health/attributes["max_health"]
	var col = Color("GREEN")
	if dif < 0.75:
		col = Color("YELLOW")
	elif dif < 0.5:
		col = Color("ORANGE")
	elif dif < 0.25:
		col = Color("RED")
	if ghost:
		$UI/health.text = "deceased"
		col = Color("RED")
	$UI/health.set("theme_override_colors/font_color",col)
	pass

##status effects
@rpc("any_peer","reliable")
func update_status_effect_graphics(se):
	#handles burning
	var burning = se.has(Lookup.statusEffectType.burning)
	var fire_col = Lookup.fire_colors[0]
	avatar.set_burning(burning,Lookup.fire_colors[0])
	#handles blighted
	if se.has(Lookup.statusEffectType.blighted):
		if burning:
			avatar.set_burning(se.has(Lookup.statusEffectType.blighted), Lookup.fire_colors[2])
			fire_col = Lookup.fire_colors[2]
			burning = true
		else:
			avatar.set_burning(se.has(Lookup.statusEffectType.blighted), Lookup.fire_colors[4])
			fire_col = Lookup.fire_colors[4]
			burning = true
	#poisoned
	avatar.set_poisoned(se.has(Lookup.statusEffectType.poisoned))
	#cursed
	avatar.set_cursed(se.has(Lookup.statusEffectType.cursed))
	#blessed
	avatar.set_blessed(se.has(Lookup.statusEffectType.blessed))
	if is_multiplayer_authority():
		Global.set_post("shader_parameter/fire_color",fire_col)
		Global.set_post("shader_parameter/burning",burning)
		#Inventory.active_status_effects = se.keys()
		#Inventory.emit_signal("update_status_effect_graphics")

const limb_key_to_defense = {
	"footL" : "defense_footL",
	"legL" : "defense_legs",
	"footR" : "defense_footR",
	"legR" : "defense_legs",
	"head" : "defense_head",
	"handL" : "defense_handL",
	"armL" : "defense_arms",
	"handR" : "defense_handR",
	"armR" : "defense_arms",
	"torso" : "defense_torso",
	}

@rpc("reliable")
func request_ghost() -> bool:
	return ghost


func set_mute(val : bool) -> void:
	if !val:
		$playerAvatar/genericAvatar/root/chestBase/neck/voicePlayer.set("volume_db",0.0)
	else:
		$playerAvatar/genericAvatar/root/chestBase/neck/voicePlayer.set("volume_db",-80.0)
	pass

func set_graphics_visible(val : bool) -> void:
	$playerAvatar.visible = val

