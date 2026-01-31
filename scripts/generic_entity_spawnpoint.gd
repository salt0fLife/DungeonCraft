extends Node3D
@export var entity_key := "debug"
@export var attribute_changes := {}

# Called when the node enters the scene tree for the first time.
func _ready():
	if !is_multiplayer_authority():
		return
	Global.instance_creature(entity_key,position,attribute_changes)
