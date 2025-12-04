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
	"necklace" : "",
	"necklace_secondary" : "",
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


func pickup_item(id, count) -> void:
	print("picked up " + str(count) + " " + str(id))
	for i in items:
		if i[0] == id:
			i[1] += count
			print("items now " + str(items)) 
			return
	items += [[id, count]]
	print("items now " + str(items)) 

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

func drop_all():
	for k in accessories.keys():
		accessories[k] = ""
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
