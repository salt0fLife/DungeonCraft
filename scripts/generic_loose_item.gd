extends Node3D

@export var item_key = "simple_rock"
@export var count = 1
var display_name = "loading"
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
	type = item[2]
	rotation.y = randf_range(-PI, PI)

var vel = 0.0
var gravity = 4.0
func _physics_process(delta):
	if !$RayCast3D.is_colliding():
		vel -= gravity * delta
		if vel < -0.5:
			vel = -0.5
	else:
		vel += delta * gravity
	
	rotation.y += delta*PI
	
	position.y += vel * delta
	pass

func interact():
	print("interacted with item display name of " + display_name)
	print("item key of " + item_key)
	print("type of " + str(type))
	print("tooltip of " + str(toolTip))
	print("nice :3")
	call_deferred("queue_free")
	return [1,[item_key, count]]
	#[interact_return_code,item_data]





