extends Node3D
@export var spider_count = 20

# Called when the node enters the scene tree for the first time.
func _ready():
	if !is_multiplayer_authority():
		return
	for i in range(0,spider_count):
		Global.instance_creature("young_spider", Vector3(-15.0-i*1.0,1.0,0.0))
	pass # Replace with function body.
