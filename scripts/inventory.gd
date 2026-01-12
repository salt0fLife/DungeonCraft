extends Node
signal update_accessories
signal update_held_item
signal update_hotbar
signal update_status_effect_graphics
var active_status_effects = []
var empty_item = ["",0,-1,{}] #key, stack, type, custom data

#var accessories = {
	##armor and clothes
	#"cape" : "",
	#"shirt" : "",
	#"chestplate" : "",
	#"hat" : "",
	#"pants" : "",
	#"leggings" : "",
	#"gloveR" : "",
	#"gloveL" : "",
	#"shoeR" : "",
	#"shoeL" : "",
	#"greaves" : "",
	##jewelry
	#"necklace1" : "",
	#"necklace2" : "",
	#"necklace3" : "",
	#"necklace4" : "",
	#"crown" : "",
	#"braceletR" : "",
	#"braceletL" : "",
	#"belt" : "",
	##rings
	#"ringFR" : "",
	#"ringSR" : "",
	#"ringVowR" : "",
	#"ringPR" : "",
	#"ringFL" : "",
	#"ringSL" : "",
	#"ringVowL" : "",
	#"ringPL" : "",
	#
	#
	###racial changes
	#"race" : "",
	#"sub_race" : "",
#}

var accessories = {
	#armor and clothes
	"cape" : key_to_item("devil_wings"),
	"shirt" : empty_item,
	"chestplate" : empty_item,
	"hat" : key_to_item("iron_helmet"),
	"pants" : empty_item,
	"leggings" : empty_item,
	"gloveR" : empty_item,
	"gloveL" : empty_item,
	"shoeR" : empty_item,
	"shoeL" : empty_item,
	"greaves" : empty_item,
	#jewelry
	"necklace1" : empty_item,
	"necklace2" : empty_item,
	"necklace3" : empty_item,
	"necklace4" : empty_item,
	"crown" : key_to_item("crown_of_god"),
	"braceletR" : empty_item,
	"braceletL" : empty_item,
	"belt" : empty_item,
	#rings
	"ringFR" : empty_item,
	"ringSR" : empty_item,
	"ringVowR" : empty_item,
	"ringPR" : empty_item,
	"ringFL" : empty_item,
	"ringSL" : empty_item,
	"ringVowL" : empty_item,
	"ringPL" : empty_item,
	
	
	##racial changes
	"race" : empty_item,
	"sub_race" : empty_item,
}


var hotbar = [
	["iron_sword",1,Lookup.itemType.weapons_sword,{"enchantment_color": Color.GREEN, "enchantments" : [Lookup.enchantments.perfect_mastery,Lookup.enchantments.advanced_resiliance], "custom_texture_path" : "res://assets/textures/icons/silverMinnow.png"}], #0
	["longsword_debug",3,Lookup.itemType.weapons_longsword,{"storage" : [key_to_item("mace_debug"),key_to_item("mace_debug"),key_to_item("iron_sword"),empty_item, key_to_item("iron_helmet"),empty_item,empty_item]}], #1
	["mace_debug",2,Lookup.itemType.weapons_mace,{"enchantments" : [0]}], #2
	["bow_debug",1,Lookup.itemType.weapons_bow,{"enchantments" : [3,2,1]}], #3
	["spear_debug",1,Lookup.itemType.weapons_spear,{}], #4
	["glaive_debug",1,Lookup.itemType.weapons_glaive,{"enchantments" : [0],"enchantment_color": Color.ROYAL_BLUE}], #5
	["scythe_debug",1,Lookup.itemType.weapons_scythe,{"enchantments": [0]}], #6
	["wand_debug",1,Lookup.itemType.weapons_wand,{}], #7
	["spellbook_debug",1,Lookup.itemType.weapons_spellbook,{}], #8
	["fishing_rod_debug",1,Lookup.itemType.weapons_fishing_rod,{"enchantments": [1,2],}] #9
]

var held_item = 0 # 0 - 9 for hotbar

var items = [
	
	
	
]

func drop_hotbar_item(index, pos):
	var val = hotbar[index]
	hotbar[index] = empty_item
	emit_signal("update_hotbar")
	emit_signal("update_held_item")
	Global.create_loose_item(val, pos)

func get_held_item_data() -> Array:
	var key = hotbar[held_item][0]
	if key != "":
		return Lookup.items[key]
	else:
		return []

func get_held_item() -> Array:
	return hotbar[held_item]

func change_held_item(index):
	held_item = index
	emit_signal("update_held_item")
	pass

func pickup_item(id, replace_held) -> bool:
	if replace_held:
		var temp = hotbar[held_item]
		hotbar[held_item] = id
		emit_signal("update_held_item")
		emit_signal("update_hotbar")
		return true #finished replace_held
	for i in range(0,hotbar.size()):
		if hotbar[i][0] == "":
			hotbar[i] = id
			emit_signal("update_held_item")
			emit_signal("update_hotbar")
			return true#found empty slot filled it and left
	#did not find empty slot so dropping the item
	return false
	
	
	
	#items no longer stack
	#print("picked up " + str(count) + " " + str(id))
	#for i in items:
		#if i[0] == id:
			#i[1] += count
			#print("items now " + str(items)) 
			#return
	#items += [[id, count]]
	#print("items now " + str(items)) 

#func equip_accessory_old(acc_id : String, tag : String):
	#if !accessories.has(acc_id):
		#print("equipped accessory to slot that was not previously declared")
		#accessories[acc_id] = tag
		#pass
	#elif accessories[acc_id] == "":
		#accessories[acc_id] = tag
	#else:
		##slot already has equipped accessory
		#var existing = accessories[acc_id]
		#pickup_item(existing,1)
		#pass
	#emit_signal("update_accessories")
	#pass

func equip_accessory(acc_id : String, data : Array):
	if !accessories.has(acc_id):
		print("equipped accessory to slot that was not previously declared")
		accessories[acc_id] = data
		pass
	elif accessories[acc_id][0] == "":
		accessories[acc_id] = data
	else:
		#slot already has equipped accessory
		var existing = accessories[acc_id]
		pickup_item(existing,1)
		accessories[acc_id] = data
	emit_signal("update_accessories")
	pass

func drop_all(pos):
	for k in accessories.keys():
		if accessories[k][0] !="": #TGIC
			Global.create_loose_item(accessories[k], pos+Vector3(randf_range(-0.25, 0.25),randf_range(-0.25, 0.25)+1.25,randf_range(-0.25, 0.25)))
			accessories[k] = Inventory.empty_item #TGIC
	for i in range(0,hotbar.size()):
		if hotbar[i][0] != "": #TGIC
			Global.create_loose_item(hotbar[i], pos+Vector3(randf_range(-0.25, 0.25),randf_range(-0.25, 0.25)+1.25,randf_range(-0.25, 0.25)))
			hotbar[i] = Inventory.empty_item #TGIC
	
	emit_signal("update_held_item")
	emit_signal("update_hotbar")
	emit_signal("update_accessories")
	pass

func get_item_texture(key : String) -> Texture:
	if !Lookup.items.has(key):
		return load("res://assets/textures/items/missingItemTexture.png")
	var data = Lookup.items[key]
	var image_path = ""
	if data.size() > 4: #makes sure item has entry
		image_path = data[4]
	if image_path == "": #placeholder for textures that have not been made yet
		image_path = "res://assets/textures/items/missingItemTexture.png"
	return load(image_path)

func can_item_go_in_accessory(item_key : String, accessory_key : String):
	return accessories_accepted_item_types[accessory_key] == Lookup.items[item_key][2]

const accessories_accepted_item_types = {
	#armor and clothes
	"cape" : Lookup.itemType.accessories_cape,
	"shirt" : Lookup.itemType.accessories_shirt,
	"chestplate" : Lookup.itemType.accessories_chestplate,
	"hat" : Lookup.itemType.accessories_hat,
	"pants" : Lookup.itemType.accessories_pants,
	"leggings" : Lookup.itemType.accessories_leggings,
	"gloveR" : Lookup.itemType.accessories_gloves,
	"gloveL" : Lookup.itemType.accessories_gloves,
	"shoeR" : Lookup.itemType.accessories_shoes,
	"shoeL" : Lookup.itemType.accessories_shoes,
	"greaves" : Lookup.itemType.accessories_greaves,
	#jewelry
	"necklace1" : Lookup.itemType.accessories_necklace,
	"necklace2" : Lookup.itemType.accessories_necklace,
	"necklace3" : Lookup.itemType.accessories_necklace,
	"necklace4" : Lookup.itemType.accessories_necklace,
	"crown" : Lookup.itemType.accessories_crown,
	"braceletR" : Lookup.itemType.accessories_bracelet,
	"braceletL" : Lookup.itemType.accessories_bracelet,
	"belt" : Lookup.itemType.accessories_belt,
	#rings
	"ringFR" : Lookup.itemType.accessories_ring,
	"ringSR" : Lookup.itemType.accessories_ring,
	"ringVowR" : Lookup.itemType.accessories_ring,
	"ringPR" : Lookup.itemType.accessories_ring,
	"ringFL" : Lookup.itemType.accessories_ring,
	"ringSL" : Lookup.itemType.accessories_ring,
	"ringVowL" : Lookup.itemType.accessories_ring,
	"ringPL" : Lookup.itemType.accessories_ring,
}

func key_to_item(key : String) -> Array:
	return [key, 1, Lookup.items[key][2], {}]
