extends Node3D

@export var item_key = "simple_rock"
@export var count = 1
var display_name = "loading"
var type = 0
var tool_tip = "pickup"
var tool_tip_color = Color.WHITE


func _ready():
	if !Lookup.items.has(item_key):
		printerr("invalid item key of value " + item_key + ". freeing from queue")
		queue_free()
		return
	#just checking if the key is valid
	var item = Lookup.items[item_key]
	display_name = item[0]
	var model = load(item[1]).instantiate()
	model.process_mode = PROCESS_MODE_DISABLED
	$graphics.add_child(model)
	type = item[2]
	$graphics.rotation.y = randf_range(-PI, PI)

var vel = 0.0
var gravity = 4.0
var time = randf_range(0.0,4.0*PI)
func _physics_process(delta):
	if !$RayCast3D.is_colliding():
		vel -= gravity * delta
		if vel < -5.0:
			vel = -5.0
	else:
		vel = 0.0
		#vel += delta * gravity
	
	$graphics.rotation.y += delta*PI
	time += delta * 4.0
	if time > PI*4.0:
		time -= PI*4.0
	$graphics.position.y = sin(time)*0.05
	
	position.y += clamp(vel * delta, -0.5, 0.5) #just make sure we dont clip anywhere


func interact():
	print("interacted with item display name of " + display_name)
	print("item key of " + item_key)
	print("type of " + str(type))
	print("tooltip of " + str(tool_tip))
	print("nice :3")
	#call_deferred("queue_free")
	return [Lookup.interact_return_code.is_item, item_key]
	#[interact_return_code,item_data]

signal destroyed
func destroy():
	emit_signal("destroyed", self)
	call_deferred("queue_free")


