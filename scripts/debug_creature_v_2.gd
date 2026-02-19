extends CharacterBody3D

var attributes = {
	"speed" : 4.5,
	"acceleration" : 1.0,
	"max_health" : 10.0,
	"health" : 1.0,
	"jump_velocity" : 6.0,
	"can_fly" : false,
	"air_acceleration": 0.25,
	"strength" : 1.0,
	"size" : 1.0,
	##defenses
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
}
var room_id = 0

var update_frame_count = 24
var update_frame_counter = 0
var update_on_frame = 0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	load_players_skin()
	if !is_multiplayer_authority():
		return
	await  get_tree().process_frame #if the world was just loaded we have to let the room_and_doors_information_populate first
	target_furthest_door_in_room() #>:3c
	avatar.animation_state = "walk"

func load_players_skin() -> void:
	var skin_img = Global.data_to_image(Global.skin)
	var t = [Global.ears, Global.tail, Global.snout, Global.slim, Global.eyeColor, Global.mouthData, Global.fangs, Global.pointy_teeth]
	avatar.load_skin(skin_img, t[0],t[1],t[2],t[3],t[4],t[5],t[6],t[7])

@onready var avatar = $graphics/playerAvatar/genericAvatar
@onready var graphics = $graphics
func _physics_process(delta):
	if !is_multiplayer_authority():
		return
	#update_frame_counter += 1
	#if update_frame_counter > update_frame_count:
		#update_frame_counter = 0
	#if !update_frame_counter == update_on_frame: #is not time to update pathfinding so just do bare minimum
		#check_for_reached_target()
		#last_pos = position
		#if !is_on_floor():
			#velocity.y -= gravity*delta
		#move_and_slide()
		#return #only update when its on update frame
	$Label3D4.text = str(room_id)
	if target_is_door:
		teller("target: door " + str(target_door_indx),2)
	elif sub_door_target_override:
		teller("target: sub_door" + str(sub_door_indx),2)
	elif targeting_node:
		teller("target: entity " + str(target_node.name),2)
	else:
		teller("no valid target",2)
	if !is_on_floor():
		velocity.y -= gravity*delta
	else:
		failed_last_ladder_jump = false
		commiting_to_ladder_dir = false
	#look_for_prey()
	look_for_predators()
	velocity_towards_target(delta)
	check_for_reached_target()
	last_pos = position
	move_and_slide()
	avatar.walk_speed = (velocity.length()/attributes["speed"])*0.5 #likes to travel 5mps when at 0.5
	var dir = (target_location - position)
	var hori_dist = Vector2(dir.x,dir.z).length()
	avatar.head_angle.y = atan2(hori_dist,dir.y) + PI*0.5
	if !is_on_floor() and !climbing:
		avatar.falling += delta*0.25
		if avatar.falling > 1.0:
			avatar.falling = 1.0
	else:
		avatar.falling = 0.0
	if !climbing:
		avatar.animation_state = "walk"
	else:
		avatar.animation_state = "idle"
	sync.rpc(position,graphics.rotation.y,$Label3D.text,$Label3D2.text,$Label3D3.text)

@rpc("any_peer","unreliable")
func sync(pos,rot,txt1,txt2,txt3):
	position = pos
	graphics.rotation.y = rot
	$Label3D.text = txt1
	$Label3D2.text = txt2
	$Label3D3.text = txt3

var last_pos = Vector3.ZERO
var still_frames = 0

func navigate(wish_dir,delta):
	var desired_rot = (atan2(velocity.z,-velocity.x) + PI*0.5)
	graphics.rotation.y = lerp_angle(graphics.rotation.y, desired_rot,delta*2.0)
	#avatar.turn = (graphics.rotation.y - desired_rot)
	
	var r1 = false
	if (last_pos - position).length() < 0.001: #unstuck operation
		still_frames += 1
		if still_frames > 10: #long enough to be certain its stuck
			#avoid_points += [(position + wish_dir + Vector3(randf_range(-0.5,0.5),0.0,randf_range(-0.5,0.5)))]
			pass
		if still_frames > 90: #full second or so
			#target_furthest_door_in_room() #just go somewhere completely different
			#enter_door(target_door_indx)
			pass
	else:
		still_frames = 0
	if $graphics/RayCast3D.is_colliding():
		var norm = $graphics/RayCast3D.get_collision_normal()
		var poi = $graphics/RayCast3D.get_collision_point()
		var dist = ($graphics/RayCast3D.global_position - poi).length()
		velocity += norm * (dist*0.1) #rays length is 3.0
		graphics.rotation.y = atan2(velocity.z,-velocity.x) + PI*0.5
		#if $graphics/RayCast3D2.is_colliding() and $graphics/RayCast3D3.is_colliding():
			#avoid_points += [poi]
	#graphics.rotation.y = atan2(velocity.z,-velocity.x) + PI

var avoid_points = []

#var climbing = false
var ladder_rot = 0.0
var ladder_pos = Vector2.ZERO
var ladder_height = Vector2.ZERO
var ladder_target_override = false
var climbing = false

var failed_last_ladder_jump = false
var commiting_to_ladder_dir = false
var commit_ladder_up = true #false is commit down

var sub_door_location = Vector3.ZERO
var sub_door_exit_location = Vector3.ZERO
var sub_door_indx = 0
var sub_door_target_override = false #make it able to climb ladders to this
#checks for close sub_doors close to target and then checks distance to their sibling against distance to target
#after checks for sub_doors distance to target subdoor if applicable
#then acts on premeditations using ladders as needed >:3c

var target_location = position #should cause it to reach target and rethink at start
var target_type = 0
var target_is_door = false

var target_door_indx = 0
var last_door_indx = 0
var ghost = false

func target_furthest_door_in_room() -> void:
	#var room_doors = [] #index is room id, data is door_indx
	#var doors_val = [] #index is door_indx (door number in group "doorway"), data is [Location, output_location, output room_id]
	#target_location = get_tree().get_first_node_in_group("player").position
	#return
	ladder_target_override = false
	sub_door_target_override = false
	targeting_node = false
	var furthest_dist = 0.0
	for d_i in Global.room_doors[room_id]:
		var dd = Global.doors_val[d_i]
		var dist = (dd[0] - position).length()
		if dist > furthest_dist and d_i != last_door_indx: #keep it from looping the same two doors
			furthest_dist = dist
			target_door_indx = d_i
			target_location = dd[0]
			target_is_door = true
		#else dont do anything because closer than last
	#already set it all in the loop

func velocity_towards_target(delta) -> void:
	var next_desired_pos = target_location
	#sets wish_vel towards target
	var pointer = (target_location - position)
	if sub_door_target_override:
		teller("moving towards sub_door: " + str(sub_door_indx),1)
		#checks if is still helpful
		var sb_dis = (sub_door_location - position).length() + (sub_door_exit_location - target_location).length()
		var biased_dif = (target_location - position)
		biased_dif.y *= 1.5
		
		if sb_dis > biased_dif.length():
			#is no longer a shortcut even with biased in its favor
			sub_door_target_override = false
		#moves towards door and enters if applicable
		pointer = (sub_door_location - position)
		if pointer.length() < 0.75:
			enter_sub_door(sub_door_indx)
	elif !Global.room_internal_doors[room_id].is_empty() and !climbing:
		teller("looking for sub_door shortcut",1)
		var nearest_entrance = 1000.0 #arbitrary unrealisticly high value
		var p_dist = pointer#pointer.length()*4.0 #biased towards using subdoors for testing
		p_dist.y *= 1.0 #not as biased anymore because looping 4.0 #biased towards using subdoors when moving vertically
		p_dist = p_dist.length()
		for sd_i in Global.room_internal_doors[room_id]:
			var sd_data = Global.doors_val[sd_i]#[Location, output_location, output room_id]
			var dis_to_ent = (sd_data[0] - position).length()
			if climbing:
				dis_to_ent = (sd_data[0] - Vector3(ladder_pos.x,ladder_height.x,ladder_pos.y)).length()
				var opt_2 = (sd_data[0] - Vector3(ladder_pos.x,ladder_height.y,ladder_pos.y)).length()
				if opt_2 < dis_to_ent:
					dis_to_ent = opt_2
				#checks from end of ladder instead of current location so it doesent jump prematurely
			var exit_to_target = (sd_data[1] - target_location).length()
			if (dis_to_ent + exit_to_target) < p_dist:
				#is a valid shortcut
				#now loop to see if there are better ones
				if (dis_to_ent + exit_to_target) < nearest_entrance:
					#is currently the best fit
					#set as sub_door_target_override
					nearest_entrance = (dis_to_ent + exit_to_target)
					sub_door_location = sd_data[0]
					sub_door_indx = sd_i
					sub_door_exit_location = sd_data[1]
					sub_door_target_override = true
	for p in avoid_points:
		var p_dif = p - position
		var dis = p_dif.length()
		if dis == 0.0: #just in case
			dis = 1.0
		var mult = 10.0 / dis #seems like a good value (about 10m of effect)
		pointer -= p_dif*dis
	var dif = pointer
	next_desired_pos = (pointer + position)
	pointer = pointer.normalized()
	var wish_dir = Vector3(pointer.x,0.0,pointer.z).normalized()
	var wish_vel = wish_dir * attributes["speed"]
	#moves towards previously picked ladder
	if climbing:
		if (position.y <= ladder_height.y and position.y >= ladder_height.x):
			teller("climbing ladder")
			ladder_target_override = false
			velocity.x = 0.0
			velocity.z = 0.0
			position.x = ladder_pos.x
			position.z = ladder_pos.y
			if pointer.y == 0.0: #just in case
				pointer.y = 1.0
			if failed_last_ladder_jump: #self explanatory keeps from jumping and regrabbing ladders a bunch
				if commiting_to_ladder_dir:
					if commit_ladder_up:
						velocity.y = attributes["speed"]
					else:
						velocity.y = -attributes["speed"]
				else:
					commiting_to_ladder_dir = true
					if (pointer.y / abs(pointer.y))*attributes["speed"] > 0.0:
						commit_ladder_up = true
					else:
						commit_ladder_up = false
			else:
				velocity.y = (pointer.y / abs(pointer.y))*attributes["speed"]
		else:
			#reached top or bottom of ladder
			climbing = false
			failed_last_ladder_jump = false
			commiting_to_ladder_dir = false
			#move it a little to solid ground
			var add_pos = Vector3(0.0,0.0,0.25)
			add_pos.rotated(Vector3.UP,ladder_rot)
			position += add_pos 
			#hopefully will make it harder to get stuck on ladders
			
		if abs(dif.y) < 0.05 and !commiting_to_ladder_dir:
			velocity.y = 2.0
			climbing = false #jumps if close to level
			failed_last_ladder_jump = true #set to false as soon as touches ground
	elif ladder_target_override:
		var ladder_top_pos = Vector3(ladder_pos.x,ladder_height.x,ladder_pos.y)
		var ladder_bottom_pos = Vector3(ladder_pos.x,ladder_height.y,ladder_pos.y)
		var dist = (target_location - position).length()
		if abs(target_location.y - position.y) < 0.5 and nav_agent.is_target_reachable():#((ladder_top_pos - target_location).length() > dist or (ladder_bottom_pos - target_location).length() > dist) and (target_location.y < ladder_height.x-0.1 or target_location.y > ladder_height.y+0.1): 
			#is not helpful anymore stop moving towards it
			ladder_target_override = false
		else:
			#checks if has reached ladder
			if (Vector2(position.x,position.z) - ladder_pos).length() < 0.75:
				teller("reached ladder")
				ladder_target_override = false
				position.y = clamp(position.y, ladder_height.x,ladder_height.y) #snap to ladder
				#position.x = ladder_pos.x
				#position.z = ladder_pos.y
				teller("started climbing")
				climbing = true
			else:
				var ladder_location = Vector3(ladder_pos.x,position.y,ladder_pos.y)
				wish_vel = (ladder_location - position).normalized() * attributes["speed"]
				next_desired_pos = ladder_location
				teller("moving towards ladder ")
	#checks if it should find a ladder
	elif abs(pointer.y) > 0.1 or abs(dif.y) > 7.5: #less math and a bit cleaner #(abs(pointer.y) > Vector2(pointer.x,pointer.z).length()): #checks if wish_vel wants to go vertical more than horizontal
		teller("wants to go up")
		#checks if can climb last_computed ladder
		if (Vector2(position.x,position.z) - ladder_pos).length() < 0.75 and (position.y < ladder_height.y and position.y > ladder_height.x):
			teller("found previously computed ladder")
			ladder_target_override = false
			velocity.x = 0.0
			velocity.z = 0.0
			position.x = ladder_pos.x
			position.z = ladder_pos.y
			if pointer.y == 0.0: #just in case
				pointer.y = 1.0
			velocity.y = (pointer.y / abs(pointer.y))*attributes["speed"]
		#checks for new ladder because cannot climb last one anymore
		elif !Global.room_ladders[room_id].is_empty():
			teller("looking for new ladder")
			var closest_fit = 100.0 #arbitrary unrealisticly high value
			for l_i in Global.room_ladders[room_id]:
				var ladder_data = Global.ladders_val[l_i] #[position,height,rot]
				if !(ladder_data[1].x - 0.5 < position.y and ladder_data[1].y + 0.5 > position.y):
					continue #ladder is uneachable
				var pos_top = Vector3(ladder_data[0].x,ladder_data[1].x,ladder_data[0].y)
				var pos_bottom = Vector3(ladder_data[0].x,ladder_data[1].x,ladder_data[0].y)
				var min_dis = (pos_top - target_location).length()
				if (pos_bottom - target_location).length() < min_dis:
					min_dis = (pos_bottom - target_location).length()
				#get min_dis from either top and bottom
				if min_dis < closest_fit:
					closest_fit = min_dis
					ladder_pos = ladder_data[0]
					ladder_height = ladder_data[1]
					ladder_rot = ladder_data[2]
					ladder_target_override = true
					teller("found ladder")
		else:
			teller("no ladders in room")
	else:
		teller("desired height")
	var new_pos = consider_navigation_mesh(next_desired_pos) #considers navigation mesh
	if nav_agent.is_target_reachable():
		#target is always reachable >:3c
		wish_vel = (new_pos - position).normalized() * attributes["speed"]
	elif !climbing: #always unreachable when on ladder
		#wish_vel does not change
		if !looking_menacingly:
			looking_menacingly = true
			look_menacing_timer = 0.0
			print("started waiting for change")
		else:
			teller("looking menacingly")
			look_menacing_timer += delta
			if look_menacing_timer > 5.0: #low patients level
				print(target_location)
				target_closest_door(position)
				print("giving up and leaving")
				looking_menacingly = false
				tired_of_this_shit = true
	var last_y_vel = velocity.y
	velocity = lerp(velocity,wish_vel,delta*4.0)
	velocity.y = last_y_vel #gravity is a thing
	$MeshInstance3D.position = next_desired_pos
	$MeshInstance3D/Label3D.text = "current goal\n" + str(next_desired_pos)
	navigate(wish_dir,delta)

var look_menacing_timer = 0.0
var looking_menacingly = false
var tired_of_this_shit = false

func check_for_reached_target() -> void:
	#if target_is_door:
		#if Global.doors_val[target_door_indx][3] != room_id: #maybe save this on entering a door if it becomes a needed check
			#target_closest_door(position)
			#print("being stupid?")
			##the door is in a different room stupid
	if (position - target_location).length() < 0.75: #seems like a good number lmao
		if target_is_door:
			enter_door(target_door_indx)
		else:
			target_furthest_door_in_room() #we only walk through doors in this house

func enter_door(door_index:int) -> void:
	tired_of_this_shit = false
	var sounds = true
	var door_data = Global.doors_val[door_index]
	if door_data[2] == last_exited_room:
		sounds = false
	else:
		Global.play_sound(position,"res://assets/sounds/environment_interaction/doorClose.ogg",room_id)
	position = door_data[1]
	last_exited_room = room_id
	room_id = door_data[2]
	last_door_indx = door_index
	if sounds:
		Global.play_sound(position,"res://assets/sounds/environment_interaction/doorOpen.ogg",room_id)
	#target_furthest_door_in_room() #one must imagine him happy
	target_random_door() #more random and lifelike, need to add some pausing and thinking/smelling/looking stuff too

func enter_sub_door(door_index:int) -> void:
	sub_door_target_override = false
	var door_data = Global.doors_val[door_index]
	position = door_data[1]
	#room_id = door_data[2]
	last_door_indx = door_index

func teller(text = "", indx = 0):
	match indx:
		0:
			$Label3D.text = text
		1:
			$Label3D2.text = text
		_:
			$Label3D3.text = text

var targeting_node = false
var target_node = null
var last_exited_room = 0

func look_for_prey():
	var new_prey = false
	var lost_track = false
	var prey = get_tree().get_nodes_in_group("class_1")
	if targeting_node:
		if target_node != null:
			if target_node.room_id == room_id:
				target_location = target_node.position
				target_is_door = false
				return #is already chasing valid prey no need to track another
			else:
				lost_track = true
				targeting_node = false
	if !prey.is_empty() and !tired_of_this_shit: #tired of everything in that room just going to leave
		var min_distance = 1000.0 #arbitrary unrealisticly high value
		for e in prey: #maybe make groups for class_1 (prey), class_2 (middle_ground ie player), class_3 (predators)
			if e.room_id == room_id:
				#is in same room
				var dis_to = (e.position - position).length()
				if dis_to < min_distance: #we can make other weights besides distance like tastiness or smth
					target_node = e
					targeting_node = true
					min_distance = dis_to
	else:
		#no prey nodes currently in tree
		pass
	
	if new_prey:
		ladder_target_override = false
		sub_door_target_override = false
	
	if !targeting_node and lost_track:
		print("lost track of prey")
		#had prey last frame but they left room and there is no more prey in room
		target_closest_door(target_location)

func look_for_predators():
	var predators = get_tree().get_nodes_in_group("class_2")
	if !predators.is_empty() and !tired_of_this_shit: #tired of everything in that room just going to leave
		var min_distance = 1000.0 #arbitrary unrealisticly high value
		for e in predators: 
			if e.room_id == room_id:
				#target_furthest_door(e.position) #runs for door furthest from predator
				target_door_weighted(position,e.position)

func target_closest_door(pos : Vector3) -> void:
	ladder_target_override = false
	sub_door_target_override = false
	targeting_node = false
	var closest_dist = 0.0 #arbitrary unrealistically high value
	for d_i in Global.room_doors[room_id]:
		var dd = Global.doors_val[d_i]
		var dist = (dd[0] - pos).length()
		if dist < closest_dist: #dont care if it loops because it is could be chasing something that is looping
			closest_dist = dist
			target_door_indx = d_i
			target_location = dd[0]
			target_is_door = true

func target_door_weighted(close_pos : Vector3, far_pos : Vector3) -> void:
	ladder_target_override = false
	sub_door_target_override = false
	targeting_node = false
	var closest_dist = 0.0 #arbitrary unrealistically high value
	for d_i in Global.room_doors[room_id]:
		var dd = Global.doors_val[d_i]
		var dist = (dd[0] - close_pos).length() - (dd[0] - far_pos).length() #if door is closer to enemy than you value goes negative
		if dist < closest_dist: #dont care if it loops because it is could be chasing something that is looping
			closest_dist = dist
			target_door_indx = d_i
			target_location = dd[0]
			target_is_door = true

func target_furthest_door(pos : Vector3) -> void:
	ladder_target_override = false
	sub_door_target_override = false
	targeting_node = false
	var furthest_dist = 0.0
	for d_i in Global.room_doors[room_id]:
		var dd = Global.doors_val[d_i]
		var dist = (dd[0] - pos).length()
		if dist > furthest_dist and d_i != last_door_indx: #keep it from looping the same two doors
			furthest_dist = dist
			target_door_indx = d_i
			target_location = dd[0]
			target_is_door = true
		#else dont do anything because closer than last
	#already set it all in the loop

@onready var nav_agent = $NavigationAgent3D
func consider_navigation_mesh(target_pos : Vector3) -> Vector3:
	var next_path_point = Vector3.ZERO
	nav_agent.target_position = target_pos
	next_path_point = nav_agent.get_next_path_position()
	if (next_path_point - position).length() < 0.05:
		next_path_point = target_pos #should help from indecision
	return next_path_point

func set_health(value):
	attributes["health"] = value
	pass

@rpc("any_peer")
func die(_attacker = "",_weapon_name = ""):
	#dont do anything :D
	targeting_node = false
	ladder_target_override = false
	sub_door_target_override = false
	target_is_door = false
	call_deferred("respawn")
	#target_furthest_door_in_room()
	pass

func respawn() -> void:
	enter_door(range(0,Global.doors_val.size()).pick_random()) #enters random door to "reset" position
	pass


func target_random_door() -> void:
	ladder_target_override = false
	sub_door_target_override = false
	targeting_node = false
	var door_options = Global.room_doors[room_id]
	var d_i_i = range(0,door_options.size()).pick_random()
	var d_i = door_options[d_i_i] #door index = door index index lmao
	var dd = Global.doors_val[d_i] #[Location, output_location, output room_id]
	if dd[2] == last_exited_room: #makes sure you dont loop
		d_i_i += 1
		if d_i_i >= door_options.size(): #keeps you in same room
			d_i_i = 0 #if it only has one door it loops back anyway
		d_i = door_options[d_i_i] #invalid get_index 22??? *edit nevermind lmao its 5:26 AM, brain not be braining*
		dd = Global.doors_val[d_i]
	target_door_indx = d_i
	target_location = dd[0]
	target_is_door = true
