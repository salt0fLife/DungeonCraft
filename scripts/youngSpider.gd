extends CharacterBody3D

@export var speed = 2.5
@export var jump_strength = 6.0
@export var distance_till_jump = 3.0
@export var distance_till_bite = 1.0
@export var sight_range = 10.0
@export var give_up_range = 20.0
@export var acceleration = 4.0
var bite_strength = 1.0
var size = 1.0

var attributes = {
	"speed" : 24.0,
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

@onready var avatar = $graphics/youngSpiderAvatar
func _ready():
	avatar.time = randf_range(0.0,64.0*PI)
	speed = randf_range(speed*0.25,speed*4.0)
	acceleration = randf_range(acceleration*0.25,acceleration*4.0)
	sight_range = randf_range(sight_range*0.5,sight_range*2.0)
	give_up_range = randf_range(give_up_range*0.5,give_up_range*2.0)
	size = randf_range(0.75,2.0)
	scale = Vector3(size,size,size)
	speed *= size
	acceleration -= (1.0-size)*0.25
	avatar.bounce_strength += randf_range(0.0,0.1)
	pass

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var target = null
@onready var graphics = $graphics
func _physics_process(delta):
	var mult = Vector2(velocity.x,velocity.z).length()/(4.0*size)
	var a_speed = 1.0
	if mult > 1.3:
		a_speed += (mult-1.3)
		mult = 1.3
	avatar.mult = mult
	avatar.speed = a_speed
	var col = move_and_collide(velocity*delta,true)
	if col:
		var norm = col.get_normal(0)
		graphics.look_at(norm,Vector3.UP,true)
	else:
		graphics.rotation = Vector3.ZERO
		graphics.rotation.y = atan2(-velocity.z,velocity.x)-PI*0.5
	if !is_on_floor():
		avatar.stand = 0.3
	else:
		avatar.stand = 0.0
	if !is_multiplayer_authority():
		return
	# Add the gravity.
	if not is_on_floor() and !is_on_wall():
		velocity.y -= gravity * delta
	check_for_player_distance()
	if target == null:
		move_idle(delta)
	else:
		move_track(delta)
	velocity -= velocity*delta
	avoid_close_entities(delta)
	move_and_slide()
	sync_info.rpc(position,velocity)

@onready var vision = $vision
func check_for_player_distance():
	var closest = 255.0
	if target != null:
		if target.ghost:
			target = null
	for p in get_tree().get_nodes_in_group("player"):
		if !p.ghost: #does not track dead entities
			var dif = p.global_position - global_position
			vision.target_position = dif + Vector3(0.0,0.5,0.0) #checks slightly above ground
			vision.force_raycast_update()
			if !vision.is_colliding(): #can only see you if you are not behind wall
				var dis = dif.length()
				if dis < sight_range:
					if target == null:
						target = p
						closest = dis
					elif dis < closest:
						target = p
						closest = dis
				elif dis > give_up_range and target == p:
					target = null

const lunge_cooldown = 1.0
var lunge_timer = 0.0
const bite_cooldown = 0.75
var bite_timer = 0.0
func move_track(delta):
	var dif = target.global_position - global_position
	var dir = Vector3(dif.x,0.0,dif.z).normalized()
	var dis = dif.length()
	if bite_timer > 0.0:
		bite_timer -= delta
		if bite_timer < 0.0:
			bite_timer = 0.0
	if dis < distance_till_bite:
		if bite_timer == 0.0:
			bite()
		velocity.x = lerp(velocity.x,0.0,attributes["acceleration"]*delta)
		velocity.z = lerp(velocity.z,0.0,attributes["acceleration"]*delta)
	else:#only moves closer if not in bite range
		velocity.x = lerp(velocity.x,attributes["speed"] * dir.x, attributes["acceleration"]*delta)
		velocity.z = lerp(velocity.z,attributes["speed"] * dir.z, attributes["acceleration"]*delta)
		if dis < distance_till_jump and is_on_floor():
			if lunge_timer < 0.0:
				lunge(dir)
			else:
				lunge_timer -= delta

func lunge(dir):
	lunge_timer = lunge_cooldown
	velocity.x += jump_strength * dir.x
	velocity.z += jump_strength * dir.z
	velocity.y = jump_strength
	pass

@onready var bite_area = $graphics/bite_area
func bite():
	#print("bite")
	bite_timer = bite_cooldown
	var remember = []
	for b in bite_area.get_overlapping_bodies():
		if b.has_method("take_damage") and !b.is_in_group("entity_spider"):
			var hh = get_node(b.health_handler)
			if remember.has(hh):
				continue #dont apply damage more than once
			remember += [hh]
			b.take_damage.rpc([[bite_strength,Lookup.damageType.stab]], bite_area.global_position, "young spider", "fangs")
			break #only bite one person

@export var decision_timer = randf_range(0.0,1.0)
@export var decision_speed = 0.1
var desired_pos = position
func move_idle(delta):
	decision_timer += delta * decision_speed
	if decision_timer > 0.0:
		decision_timer -= 1.0
		match randi_range(0,4):
			0:
				#walk
				desired_pos += Vector3(randf_range(-20.0,20.0),0.0,randf_range(-20.0,20.0))
				pass
			_:
				#other
				desired_pos += Vector3(randf_range(-2.0,2.0),0.0,randf_range(-2.0,2.0))
				pass
	var desired_vel = (desired_pos - position).normalized()
	velocity = lerp(velocity,desired_vel,acceleration*delta)
	pass

@rpc("any_peer","unreliable")
func sync_info(pos = position, vel = velocity):
	position = pos
	velocity = vel

@export var avoid_radius = 2.0
@export var avoid_strength = 5.0
func avoid_close_entities(delta):
	for e in get_tree().get_nodes_in_group("entity"):
		var dif = e.global_position - global_position
		var dis = dif.length()
		if dis < avoid_radius:
			var dir = dif.normalized()
			velocity -= dir * delta * avoid_strength * (avoid_radius-dis)
			pass
	pass

func die(attacker = "", weapon_name = "", add_vel = Vector3.ZERO):
	call_deferred("queue_free")

func set_health(val):
	attributes["health"] = val



