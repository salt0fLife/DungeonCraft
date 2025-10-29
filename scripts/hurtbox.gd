extends StaticBody3D
@export var health_handler:NodePath
@export var id = ""
@export var damage_mult := 1
@export var hardness := 0
var hitmarker = preload("res://assets/effects/hitmarker.tscn")

func _ready():
	get_node(health_handler).connect("died", _on_host_died)

@rpc("any_peer", "call_local")
func take_damage(val, pos, owned_by):
	var amount = val*damage_mult
	get_node(health_handler).damage(amount, id, owned_by)
	var h = hitmarker.instantiate()
	h.val = amount
	add_child(h)
	h.global_position = pos
	pass

signal remove_shrapnel
func _on_host_died():
	emit_signal("remove_shrapnel")
