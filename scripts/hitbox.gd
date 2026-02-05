@icon("res://assets/textures/icons/hurtbox.svg")
class_name hitbox extends Area3D
@export var active_time = 0.1
@export var damage = [[1.0,Lookup.damageType.generic]]
@export var knockback = Vector3.ZERO
@export var size = Vector3(1.0,1.0,1.0)
@export var friendly_node : NodePath
@export var owner_tag = ""
@export var weapon_name = ""
@export var remember = false
var graphics = []
# Called when the node enters the scene tree for the first time.
@onready var m_mat = preload("res://assets/materials/hitbox_display_mat.tres")
@export var active = true
@export var effects = {}

func _ready():
	var mi = MeshInstance3D.new()
	mi.mesh = BoxMesh.new()
	mi.mesh.size = size
	add_child(mi)
	mi.visible = Settings.show_combat_boxes
	mi.set_surface_override_material(0,m_mat)
	mi.set_layer_mask_value(1,false)
	mi.set_layer_mask_value(2,true)
	Settings.connect("update_combat_boxes",_update_show_graphics)
	var ml = Label3D.new()
	ml.text = str(weapon_name)
	mi.add_child(ml)
	ml.set_layer_mask_value(1,false)
	ml.set_layer_mask_value(2,true)
	#if !active:
		#return #just optional visuals
	var m = CollisionShape3D.new()
	m.shape = BoxShape3D.new()
	m.shape.size = size
	add_child(m,true,Node.INTERNAL_MODE_FRONT)
	print("added collision shape")
	set_collision_mask_value(1,false)
	set_collision_mask_value(4,true)
	set_collision_mask_value(7,true)
	#m.position -= size*0.5 #centers it
	#centered by default mb

func _update_show_graphics():
	for i in graphics:
		i.visible = Settings.show_combat_boxes

@export var no_hit_list = []
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if !active:
		active_time -= delta
		if active_time <= 0.0:
			call_deferred("queue_free")
		return
	#var friendly = #get_node(friendly_node)
	for b in get_overlapping_bodies():
		if b.has_method("take_damage"):
			#print(b)
			var hh = b.get_node(b.health_handler)
			if no_hit_list.has(hh):
				continue #dont apply damage more than once
			#if hh == friendly:
				#print("friendly")
				#continue #dont damage self
			no_hit_list += [hh]
			b.take_damage.rpc(damage, global_position, owner_tag, weapon_name, knockback, remember)
			for e in effects.keys():
				print("applied " + str(e) + " for " + str(effects[e]) + " on " + str(b))
				b.apply_status_effect.rpc(e,effects[e]) #apply all effects needed
				b.apply_status_effect(e,effects[e])
			#take_damage(val, pos, owned_by, weapon_name, knockback = Vector3.ZERO, remember = false):
	active_time -= delta
	if active_time <= 0.0:
		call_deferred("queue_free")
