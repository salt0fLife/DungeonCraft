extends Node3D
@export var entity_base : NodePath
@export var entity_avatar : NodePath
signal died
var hitmarker = preload("res://assets/effects/hitmarker.tscn")

@rpc("any_peer","reliable")
func damage(data, id, attacker, weapon_name = "", knockback = Vector3.ZERO, count_attacker = false):
	var hh = get_node(entity_base)
	var a = hh.attributes
	var total = 0.0
	var primary_dt = 0
	var dr = 0.0
	for d in data:
		var h = hitmarker.instantiate()
		h.val = d[1]
		h.type = d[0]
		get_parent().get_parent().add_child(h)
		h.global_position = global_position
		match d[0]:# d = [damage_type, amount]
			Lookup.damageType.generic:
				total += d[1] / (a["generic_defense"]*a["true_defense"])
			Lookup.damageType.stab:
				total += d[1] / (a["stab_defense"]*a["true_defense"])
			Lookup.damageType.slash:
				total += d[1] / (a["slash_defense"]*a["true_defense"])
			Lookup.damageType.blunt:
				total += d[1] / (a["blunt_defense"]*a["true_defense"])
			Lookup.damageType.fire:
				total += d[1] / (a["fire_defense"]*a["true_defense"])
			Lookup.damageType.ice:
				total += d[1] / (a["ice_defense"]*a["true_defense"])
			Lookup.damageType.toxic:
				total += d[1] / (a["toxic_defense"]*a["true_defense"])
			Lookup.damageType.explosion:
				total += d[1] / (a["explosion_defense"]*a["true_defense"])
			Lookup.damageType.magic:
				total += d[1] / (a["magic_defense"]*a["true_defense"])
			Lookup.damageType.lightning:
				total += d[1] / (a["lightning_defense"]*a["true_defense"])
			Lookup.damageType.holy:
				total += d[1] / (a["holy_defense"]*a["true_defense"])
			Lookup.damageType.blight:
				total += d[1] / (a["blight_defense"]*a["true_defense"])
			_:
				printerr("unknown_damage_id of : " + str(d[0]))
				total += d[1] / a["true_defense"]
		if a["health"] - total < 0.25:
			hh.die(attacker,weapon_name)
			hh.velocity += knockback * Vector3(100.0,100.0,100.0)
		else:
			hh.set_health(a["health"]-total)

var status_effects = {}

func add_status_effect(id,time):
	if status_effects.has(id):
		status_effects[id] += time
	else:
		status_effects[id] = time
	update_status_effect_graphics(status_effects)
	update_status_effect_graphics.rpc(status_effects)

@rpc("any_peer","reliable")
func update_status_effect_graphics(se):
	var avatar = get_node(entity_avatar)
	#handles burning
	var burning = se.has(Lookup.statusEffectType.burning)
	var fire_col = Lookup.fire_colors[0]
	avatar.set_burning(burning,Lookup.fire_colors[0])
	#handles blighted
	if se.has(Lookup.statusEffectType.blighted):
		if burning:
			avatar.set_burning(se.has(Lookup.statusEffectType.blighted), Lookup.fire_colors[2])
			fire_col = Lookup.fire_colors[2]
			burning = true
		else:
			avatar.set_burning(se.has(Lookup.statusEffectType.blighted), Lookup.fire_colors[4])
			fire_col = Lookup.fire_colors[4]
			burning = true
	#poisoned
	avatar.set_poisoned(se.has(Lookup.statusEffectType.poisoned))
	#cursed
	avatar.set_cursed(se.has(Lookup.statusEffectType.cursed))
	#blessed
	avatar.set_blessed(se.has(Lookup.statusEffectType.blessed))

func _process(delta):
	if !clear_status_effects:
		for k in status_effects.keys():
			match k:
				Lookup.statusEffectType.burning:
					status_effects[k] -= delta
					damage([[Lookup.damageType.fire,delta]], "status_effect", "", "burning")
					if status_effects[k] < 0.0:
						status_effects.erase(k)
						update_status_effect_graphics(status_effects)
						update_status_effect_graphics.rpc(status_effects)
				Lookup.statusEffectType.blighted:
					status_effects[k] -= delta
					damage([[Lookup.damageType.blight,delta*2.5]], "status_effect", "", "blighted")
					if status_effects[k] < 0.0:
						status_effects.erase(k)
						update_status_effect_graphics(status_effects)
						update_status_effect_graphics.rpc(status_effects)
				Lookup.statusEffectType.poisoned:
					status_effects[k] -= delta
					damage([[Lookup.damageType.toxic,delta*1.75]], "status_effect", "", "poisoned")
					if status_effects[k] < 0.0:
						status_effects.erase(k)
						update_status_effect_graphics(status_effects)
						update_status_effect_graphics.rpc(status_effects)
				Lookup.statusEffectType.cursed:
					status_effects[k] -= delta
					damage([[Lookup.damageType.magic,delta*1.0]], "status_effect", "", "cursed")
					if status_effects[k] < 0.0:
						status_effects.erase(k)
						update_status_effect_graphics(status_effects)
						update_status_effect_graphics.rpc(status_effects)
				Lookup.statusEffectType.blessed:
					status_effects[k] -= delta
					#healing function here
					damage([[Lookup.damageType.magic,-delta*1.0]], "status_effect", "", "blessed")
					if status_effects[k] < 0.0:
						status_effects.erase(k)
						update_status_effect_graphics(status_effects)
						update_status_effect_graphics.rpc(status_effects)
	else:
		print("clearing status effects")
		for k in status_effects.keys():
			print(k)
			status_effects.erase(k)
		clear_status_effects = false
var clear_status_effects = true
