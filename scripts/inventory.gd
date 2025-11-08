extends Node
signal update_accessories
signal update_held_item

var accessories = {
	"cape" : "",
	"shirt" : "",
	"hat" : "",
	"pants" : "",
	"gloves" : "",
	"shoes" : ""
}

var hotbar = [
	"iron_sword", #0
	"", #1
	"", #2
	"", #3
	"", #4
	"", #5
	"", #6
	"", #7
	"", #8
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
