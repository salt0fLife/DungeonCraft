extends CharacterBody3D
@export var health_handler:NodePath
@export var id = ""
@export var damage_mult := 1.0
@export var hardness := 0
var hitmarker = preload("res://assets/effects/hitmarker.tscn")

func _ready():
	get_node(health_handler).connect("died", _on_host_died)

@rpc("any_peer", "call_local")
func take_damage(val, pos, owned_by, weapon_name, knockback = Vector3.ZERO, remember = false):
	var amount = val#*damage_mult
	get_node(health_handler).damage(amount, id, owned_by, weapon_name, knockback, remember)
	#h.val = amount
	for a in val:
		var h = hitmarker.instantiate()
		h.val = a[1]
		h.type = a[0]
		add_child(h)
		h.global_position = pos

signal remove_shrapnel
func _on_host_died():
	emit_signal("remove_shrapnel")
