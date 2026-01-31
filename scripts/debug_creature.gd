extends CharacterBody3D

var attributes = {
	"speed" : 5.0,
	"acceleration" : 1.0,
	"max_health" : 10.0,
	"health" : 10.0,
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

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	if !is_multiplayer_authority():
		return
	await  get_tree().process_frame #if the world was just loaded we have to let the room_and_doors_information_populate first
	target_furthest_door_in_room() #>:3c

@onready var graphics = $graphics
func _physics_process(delta):
	if !is_multiplayer_authority():
		return
	if !is_on_floor():
		velocity.y -= gravity*delta
	velocity_towards_target(delta)
	check_for_reached_target()
	last_pos = position
	move_and_slide()
	sync.rpc(position,graphics.rotation.y)

@rpc("any_peer","unreliable")
func sync(pos,rot):
	position = pos
	graphics.rotation.y = rot

var last_pos = Vector3.ZERO
var still_frames = 0

func navigate(wish_dir):
	graphics.rotation.y = atan2(velocity.z,-velocity.x) + PI*0.5
	var r1 = false
	if (last_pos - position).length() < 0.001: #unstuck operation
		still_frames += 1
		#if still_frames > 10: #long enough to be certain its stuck
			#avoid_points += [(position + wish_dir)]
		if still_frames > 90: #full second or so
			#target_furthest_door_in_room() #just go somewhere completely different
			enter_door(target_door_indx)
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

var sub_door_taget_override = false #make it able to climb ladders to this
#checks for close sub_doors close to target and then checks distance to their sibling against distance to target
#after checks for sub_doors distance to target subdoor if applicable
#then acts on premeditations using ladders as needed >:3c

var target_location = position #should cause it to reach target and rethink at start
var target_is_door = false
var target_door_indx = 0
var last_door_indx = 0

func target_furthest_door_in_room() -> void:
	#var room_doors = [] #index is room id, data is door_indx
	#var doors_val = [] #index is door_indx (door number in group "doorway"), data is [Location, output_location, output room_id]
	#target_location = get_tree().get_first_node_in_group("player").position
	#return
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
	#sets wish_vel towards target
	var pointer = (target_location - position)
	for p in avoid_points:
		var dif = p - position
		var dis = dif.length() * 0.1 #seems like a good value (about 10m of effect)
		pointer -= dif*dis
	pointer = pointer.normalized()
	var wish_dir = Vector3(pointer.x,0.0,pointer.z).normalized()
	var wish_vel = wish_dir * attributes["speed"]
	#moves towards previously picked ladder
	if climbing:
		if (position.y < ladder_height.y and position.y > ladder_height.x):
			#print("climbing ladder")
			ladder_target_override = false
			velocity.x = 0.0
			velocity.z = 0.0
			position.x = ladder_pos.x
			position.z = ladder_pos.y
			if pointer.y == 0.0: #just in case
				pointer.y = 1.0
			velocity.y = (pointer.y / abs(pointer.y))*attributes["speed"]
		else:
			climbing = false
		if abs(pointer.y) < 0.05:
			climbing = false #jumps if level
	elif ladder_target_override:
		#checks if has reached ladder
		if (Vector2(position.x,position.z) - ladder_pos).length() < 0.75:
			#print("reached ladder")
			ladder_target_override = false
			#print("started climbing")
			climbing = true
		else:
			var ladder_location = Vector3(ladder_pos.x,position.y,ladder_pos.y)
			wish_vel = (ladder_location - position).normalized() * attributes["speed"]
			#print("moving towards ladder ")
	#checks if it should find a ladder
	elif abs(pointer.y) > 0.1: #less math and a bit cleaner #(abs(pointer.y) > Vector2(pointer.x,pointer.z).length()): #checks if wish_vel wants to go vertical more than horizontal
		#print("wants to go up")
		#checks if can climb last_computed ladder
		if (Vector2(position.x,position.z) - ladder_pos).length() < 0.75 and (position.y < ladder_height.y and position.y > ladder_height.x):
			#print("found previously computed ladder")
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
			#print("looking for new ladder")
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
					#print("found ladder")
		else:
			#print("no ladders in room")
			pass
	velocity = lerp(velocity,wish_vel,delta*4.0)
	navigate(wish_dir)

func check_for_reached_target() -> void:
	if (position - target_location).length() < 0.75: #seems like a good number lmao
		if target_is_door:
			enter_door(target_door_indx)
		else:
			target_furthest_door_in_room() #we only walk through doors in this house

func enter_door(door_index:int) -> void:
	var door_data = Global.doors_val[door_index]
	position = door_data[1]
	room_id = door_data[2]
	last_door_indx = door_index
	target_furthest_door_in_room() #one must imagine him happy

