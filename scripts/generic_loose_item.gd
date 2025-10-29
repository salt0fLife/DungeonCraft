extends Node3D

@export var item_key = "simple_rock"
var display_name = "loading"
var weight = 0.0
var size = 0.0
var type = 0
var toolTip = "pickup"

func _ready():
	if !Lookup.items.has(item_key):
		printerr("invalid item key of value " + item_key + ". freeing from queue")
		queue_free()
	#just checking if the key is valid
	var item = Lookup.items[item_key]
	display_name = item[0]
	var model = load(item[1]).instantiate()
	add_child(model)
	weight = item[2]
	size = item[3]
	type = item[4]
	$CollisionShape3D.shape.set("radius", size)
	$RayCast3D.target_position = Vector3(0.0,-size-1.0,0.0)
	rotation.y = randf_range(-PI, PI)

var vel = 0.0
var gravity = 4.0
func _physics_process(delta):
	if !$RayCast3D.is_colliding():
		vel -= gravity * delta
		if vel > 0.5:
			vel = 0.5
	else:
		var poi = $RayCast3D.get_collision_point()
		var distance = (global_position - poi).normalized()
		vel += distance.y * delta
	
	rotation.y += delta*PI
	
	position.y += vel * delta
	pass

func interact():
	print("interacted with item display name of " + display_name)
	print("item key of " + item_key)
	print("weight of " + str(weight))
	print("size of " + str(size))
	print("type of " + str(type))
	print("tooltip of " + str(toolTip))
	print("nice :3")
	return [0,item_key]





