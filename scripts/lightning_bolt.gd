extends Node3D
var time = 0.0
var event = 0
var dir = Vector3.ZERO
var owned_by = "god"
var velocity = Vector3.ZERO
var speed = 0.0
var offset_appeal = Vector3.ZERO

func _ready():
	$MeshInstance3D2.rotation.x = randf_range(-PI*0.1,PI*0.1)
	$MeshInstance3D2.rotation.z = randf_range(-PI*0.1,PI*0.1)
	offset_appeal.x = -sin($MeshInstance3D2.rotation.z) * 100.0
	offset_appeal.z = sin($MeshInstance3D2.rotation.x) * 100.0
	offset_appeal.y = 100.0
	#y rot will not do anything due to shader

func _process(delta):
	time += delta
	#$MeshInstance3D2.position.y = 100.0 - clamp(time*4.0,0.0,1.0)*100.0
	$MeshInstance3D2.position = lerp(offset_appeal,Vector3.ZERO,clamp(time*4.0,0.0,1.0)) #moves to right pos
	if time > 0.25 and event < 2: #extended touchdown!
		Global.create_camera_impact(position, 0.1)
		$OmniLight3D.light_energy = 100 * (1.0 - sin(time*PI*20))*0.5
	if time > 0.25 and event < 1: #touchdown!
		Global.emit_signal("thunder_from_point", position) #emits thunder sound
		$AudioStreamPlayer3D.play()
		$electric.emitting = true
		run_damage()
		event = 1
	if time > 0.75:
		event = 2
		$OmniLight3D.hide()
		$electric.emitting = false
	if time > 1.0:
		call_deferred("queue_free")
	if is_multiplayer_authority():
		sync.rpc(position)

@rpc("any_peer","unreliable")
func sync(pos):
	position = pos

func run_damage() -> void:
	var h = hitbox.new()
	h.owner_tag = owned_by
	h.weapon_name = "lightning"
	h.active_time = 0.25
	h.size = Vector3(8.0,8.0,8.0)
	h.damage = [[Lookup.damageType.lightning,5.0]]
	h.effects = {Lookup.statusEffectType.burning:5.0}
	add_child(h)
	add_hh_child(h.size, Vector3.ZERO,h.active_time,h.weapon_name)
	return #pre hitbox code
	if $attackArea.has_overlapping_bodies():
		var hits = $attackArea.get_overlapping_bodies()
		var remember = []
		for hit in hits:
			var hh = get_node(hit.health_handler)
			if remember.has(hh):
				continue #dont deal damage twice
			remember += [hh]
			if hit.has_method("take_damage"):
				var val = [[Lookup.damageType.lightning,5.0]]
				hit.take_damage(val, position, owned_by, "lightning")
				hit.apply_status_effect(Lookup.statusEffectType.burning,5.0)

@rpc("any_peer")
func add_hh_child(size : Vector3, offset : Vector3, life_time : float, weapon_name := "", active := false) -> void:
	var h = hitbox.new() #for other people to see
	h.size = size
	h.active = active
	h.active_time = life_time
	h.weapon_name = weapon_name
	h.position = offset
	add_child(h)
