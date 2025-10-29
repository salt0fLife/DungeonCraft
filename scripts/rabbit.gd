extends CharacterBody3D


# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var desired_pos = Vector3.ZERO
const max_hypothetical_distance = 100.0 #just make sure it cant get this far away from something observed easily 
var rot = 0.0

var points_of_interest = {
	
	
}

#each element should be    node : Vector2(how desireable it is to reach, last time observed)
var detected_entities = {
	
	
}

var wishDir = Vector3.ZERO
var speed = 2.0

@onready var graphics = $graphics
func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
	#get info about surroundings
	look()
	#account for desires and find path
	think()
	#manage initialized_bite
	if biting:
		bite_timer -= delta
		if bite_timer < 0.0:
			bite()
	velocity = lerp(velocity, wishDir * speed, delta*4.0)
	
	#handle rotation
	var rot = atan2(velocity.z, -velocity.x)
	graphics.rotation.y = rot - PI*0.5
	move_and_slide()

@export var wishdir_modifier_strength = 0.5
var memory_time = 5.0
var bravery = 0.5
func think():
	#in the future make desire_pos be a common food location or something
	var forget_list = []
	desired_pos = Vector3.ZERO
	var general_travel_direction = (-global_position).normalized()
	var wishDir_modifier = general_travel_direction#would be making rounds to food areas if hungery or making way home should take these into account
	var highest_appeal = 0.01
	var fear_pos = Vector3.ZERO
	var highest_fear = 0.01
	for deNode in detected_entities:
		var de = detected_entities[deNode]
		var time_since_sighting = Global.time - de[1]
		if time_since_sighting > memory_time:
			#forget entity
			forget_list += [deNode]
		else:
			#remember and account for entity
			var generalAppeal = de[0][0] * ((memory_time - time_since_sighting)*0.1)
			var foodAppeal = de[0][1] * ((memory_time - time_since_sighting)*0.1)
			var fear = de[0][2] * ((memory_time - time_since_sighting)*0.1)
			var distance = (deNode.global_position - global_position).length()
			generalAppeal = generalAppeal * remap(distance, 0.0, max_hypothetical_distance, 1.0, 0.0)
			foodAppeal = foodAppeal * remap(distance, 0.0, max_hypothetical_distance, 1.0, 0.0)
			fear = fear * remap(distance, 0.0, max_hypothetical_distance, 1.0, 0.0)
			#combines appeal
			var appeal = foodAppeal + generalAppeal
			#scales appeal with how far away it is
			if appeal > highest_appeal:
				desired_pos = deNode.global_position
				highest_appeal = appeal
			else:
				wishDir_modifier += (deNode.global_position - global_position).normalized() * (appeal-fear)
			if fear > highest_fear:
				fear_pos = deNode.global_position
				highest_fear = fear
	wishDir_modifier = wishDir_modifier.normalized()
	#remove forgotten entities
	for x in forget_list:
		detected_entities.erase(x)
	#calculate wishdir based on appeal, fear and position
	if highest_fear > highest_appeal + bravery:
		wishDir = -(fear_pos - global_position).normalized()
	else:
		wishDir = (desired_pos - global_position).normalized()
	wishDir = (wishDir + wishDir_modifier * wishdir_modifier_strength).normalized()


const appeal_lookup = {
	#[general appeal, food appeal, fear]
	"fox" : [-0.5, 0.0, 10.0],
	"foodPlant" : [1.0, 2.0, 0.0]
}

@onready var sight_area = $sight_check_area
var fov = 180
func look():
	var t = Global.time
	for n in sight_area.get_overlapping_bodies():
		if n != self:
			#check if in fov
			var dif = n.global_position - global_position
			var angle_to = atan2(dif.z,dif.x)
			
			if abs((angle_to - rot)*180/PI) <= fov:
				#calculate appeal and add to de list
				var appeal =[0.0,0.0,0.0]
				var tags = n.get_groups()
				for key in tags:
					if appeal_lookup.has(key):
						appeal[0] += appeal_lookup[key][0]
						appeal[1] += appeal_lookup[key][1]
						appeal[2] += appeal_lookup[key][2]
				detected_entities[n] = [appeal, t]

const bite_groups = ["foodPlant"]

func _on_bite_area_body_entered(body):
	var groups = body.get_groups()
	print(groups)
	for g in groups:
		if bite_groups.has(g):
			start_bite()

func start_bite():
	print("start bite")
	if biting:
		return
	bite_timer = bite_time
	biting = true

var biting = false
var bite_timer = 0.0
var bite_time = 0.25
@onready var bite_area = $biteArea
func bite():
	print("bite")
	biting = false
	bite_timer = 0.0
	for b in bite_area.get_overlapping_bodies():
		if b != self:
			if b.is_in_group("foodPlant"):
				var n = b.Nutrition
				print("ate b with nutrition of " + str(n))
				b.queue_free()
			else:
				print(str(self) + " bit " + str(b))
