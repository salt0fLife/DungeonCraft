@icon("res://assets/textures/icons/hurtbox.svg")
class_name hurtbox extends CharacterBody3D

@export var health_handler:NodePath
@export var id = ""
@export var damage_mult := 1.0
@export var hardness := 0
var hitmarker = preload("res://assets/effects/hitmarker.tscn")

func _ready():
	get_node(health_handler).connect("died", _on_host_died)
	
	create_graphics() #for debugging
	Settings.connect("update_combat_boxes",_update_show_graphics)

var graphics = []

@onready var dis_mat = preload("res://assets/materials/hurtbox_display_mat.tres")
func create_graphics():
	for i in get_children(false):
		var shape = i.shape
		if shape is ConcavePolygonShape3D:
			#print("concave polygon")
			var pv3 = shape.get_faces()
			var surface_array = []
			surface_array.resize(Mesh.ARRAY_MAX)
			surface_array[Mesh.ARRAY_VERTEX] = pv3
			var m = MeshInstance3D.new()
			var mm = ArrayMesh.new()
			mm.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES,surface_array)
			m.mesh = mm
			add_child(m)
			m.transform = i.transform #makes sure they are perfectly lines up
			graphics += [m]
			#m.scale += Vector3(0.3,0.3,0.3)
			m.set_surface_override_material(0,dis_mat)
			m.visible = Settings.show_combat_boxes
			m.set_layer_mask_value(1,false)
			m.set_layer_mask_value(2,true)
			pass

func _update_show_graphics():
	for i in graphics:
		i.visible = Settings.show_combat_boxes
	pass

@rpc("any_peer", "call_local")
func take_damage(val, pos, owned_by, weapon_name, knockback = Vector3.ZERO, remember = false):
	var amount = val#*damage_mult
	get_node(health_handler).damage(amount, id, owned_by, weapon_name, knockback, remember)
	#h.val = amount
	#for a in val:
		#var h = hitmarker.instantiate()
		#h.val = a[1]
		#h.type = a[0]
		#add_child(h)
		#h.global_position = pos

signal remove_shrapnel
func _on_host_died():
	emit_signal("remove_shrapnel")

@rpc("any_peer","reliable")
func apply_status_effect(effect_id:int,time:float):
	if !is_multiplayer_authority():
		return
	get_node(health_handler).add_status_effect(effect_id,time)
	pass
