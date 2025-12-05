extends Node
signal update_accessories
signal update_held_item
signal update_hotbar

var accessories = {
	#armor and clothes
	"cape" : "",
	"shirt" : "",
	"chestplate" : "",
	"hat" : "",
	"pants" : "",
	"leggings" : "",
	"gloveR" : "",
	"gloveL" : "",
	"shoeR" : "",
	"shoeL" : "",
	"greaves" : "",
	#jewelry
	"necklace1" : "",
	"necklace2" : "",
	"necklace3" : "",
	"necklace4" : "",
	"crown" : "",
	"braceletR" : "",
	"braceletL" : "",
	"belt" : "",
	#rings
	"ringFR" : "",
	"ringSR" : "",
	"ringVowR" : "",
	"ringPR" : "",
	"ringFL" : "",
	"ringSL" : "",
	"ringVowL" : "",
	"ringPL" : "",
	
	
	##racial changes
	"race" : "",
	"sub_race" : "",
}

var hotbar = [
	"iron_sword", #0
	"", #1
	"short_bow", #2
	"magic_bow", #3
	"", #4
	"", #5
	"", #6
	"", #7
	"debug_speed_boot_R", #8
	"" #9
]

var held_item = 0 # 0 - 9 for hotbar

var items = [
	
	
	
]

func drop_hotbar_item(index, pos):
	var val = hotbar[index]
	hotbar[index] = ""
	emit_signal("update_hotbar")
	emit_signal("update_held_item")
	Global.create_loose_item(val, pos)

func get_held_item_data():
	var key = hotbar[held_item]
	if key != "":
		return Lookup.items[hotbar[held_item]]
	else:
		return []

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
		if hotbar[i] == "":
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

func equip_accessory(acc_id : String, tag : String):
	if !accessories.has(acc_id):
		print("equipped accessory to slot that was not previously declared")
		accessories[acc_id] = tag
		pass
	elif accessories[acc_id] == "":
		accessories[acc_id] = tag
	else:
		#slot already has equipped accessory
		var existing = accessories[acc_id]
		pickup_item(existing,1)
		pass
	emit_signal("update_accessories")
	pass

func drop_all(pos):
	for k in accessories.keys():
		if accessories[k] !="":
			Global.create_loose_item(accessories[k], pos+Vector3(randf_range(-0.25, 0.25),randf_range(-0.25, 0.25)+1.25,randf_range(-0.25, 0.25)))
			accessories[k] = ""
	for i in range(0,hotbar.size()):
		if hotbar[i] != "":
			Global.create_loose_item(hotbar[i], pos+Vector3(randf_range(-0.25, 0.25),randf_range(-0.25, 0.25)+1.25,randf_range(-0.25, 0.25)))
			hotbar[i] = ""
	
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
	"chestplate" : Lookup.itemType.accessories_shirt,
	"hat" : Lookup.itemType.accessories_hat,
	"pants" : Lookup.itemType.accessories_pants,
	"leggings" : Lookup.itemType.accessories_pants,
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

