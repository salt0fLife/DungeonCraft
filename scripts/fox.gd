extends CharacterBody3D


# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var desired_pos = Vector3.ZERO
const max_hypothetical_distance = 100.0 #just make sure it cant get this far away from something observed easily 

var points_of_interest = {
	
	
}

#each element should be    node : Vector2(how desireable it is to reach, last time observed)
var detected_entities = {
	
	
}

var wishDir = Vector3.ZERO
var speed = 1.0

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
	move_and_slide()

@export var wishdir_modifier_strength = 0.5
var memory_time = 2.0
var general_travel_position = Vector3.ZERO
var general_travel_appeal = 0.25
func think():
	#in the future make desire_pos be a common food location or something
	var forget_list = []
	desired_pos = Vector3.ZERO
	var wishDir_modifier = (general_travel_position-global_position).normalized()#would be making rounds to food areas if hungery or making way home should take these into account
	var highest_appeal = general_travel_appeal
	for deNode in detected_entities:
		var de = detected_entities[deNode]
		var time_since_sighting = Global.time - de.y
		if time_since_sighting > memory_time:
			#forget entity
			forget_list += [deNode]
			pass
		else:
			#remember and account for entity
			var appeal = de.x * ((memory_time - time_since_sighting)*0.1)
			var distance = (deNode.global_position - global_position).length()
			appeal = appeal * remap(distance, 0.0, max_hypothetical_distance, 1.0, 0.0)
			#scales appeal with how far away it is
			if abs(appeal) > abs(highest_appeal):
				desired_pos = deNode.global_position
				highest_appeal = appeal
			else:
				wishDir_modifier += (deNode.global_position - global_position).normalized() * appeal
	wishDir_modifier = wishDir_modifier.normalized()
	#remove forgotten entities
	for x in forget_list:
		detected_entities.erase(x)
	#calculate wishdir based on appeal and position
	wishDir = (desired_pos - global_position).normalized()
	#quick and dirty way to handle running away from negative appeal
	wishDir = wishDir * highest_appeal/abs(highest_appeal)
	wishDir = (wishDir + wishDir_modifier * wishdir_modifier_strength).normalized()


const appeal_lookup = {
	"rabbit" : 2.0,
	"foodPlant" : -0.1,
	"fox" : -0.1
}

@onready var sight_area = $sight_check_area
func look():
	var t = Global.time
	for n in sight_area.get_overlapping_bodies():
		if n != self:
			var appeal = 0.0
			var tags = n.get_groups()
			for key in tags:
				if appeal_lookup.has(key):
					appeal += appeal_lookup[key]
			detected_entities[n] = Vector2(appeal, t)

const bite_groups = ["rabbit"]

func _on_bite_area_body_entered(body):
	var groups = body.get_groups()
	for g in groups:
		if bite_groups.has(g):
			start_bite()

func start_bite():
	if biting:
		return
	bite_timer = bite_time
	biting = true

var biting = false
var bite_timer = 0.0
var bite_time = 0.25
@onready var bite_area = $biteArea
func bite():
	biting = false
	bite_timer = 0.0
	for b in bite_area.get_overlapping_bodies():
		print(str(self) + " bit " + str(b))
		pass
