extends Control
#"debug_speed_boot_R" : ["speed boots 2", "res://accessories/boots/leather_boot_graphics.tscn", itemType.accessories_shoes, [[["res://accessories/boots/leather_boot_graphics.tscn", 4]], {"speed" : +0.25, "speed_multiplier" : +0.5, "defense_footR" : +0.1}], "","debug_speed_boots"],

func _ready():
	#update_graphics_from_key("debug_speed_boot_R")
	pass

func update_graphics_from_key(key):
	if key == "":
		return
	var data = Lookup.items[key]
	$item_name.text = data[0]
	$workingArea/HFlowContainer/textureDisplay.texture = Inventory.get_item_texture(key)
	var type = data[2]
	
	if Lookup.accessories_types.has(type):
		#is accessory
		#[[["res://accessories/boots/leather_boot_graphics.tscn", 4]], {"speed" : +0.25, "speed_multiplier" : +0.5, "defense_footR" : +0.1}], "","debug_speed_boots"
		for k in data[3][1].keys():
			var l = Label.new()
			l.text = ""
			var val = data[3][1][k]
			if typeof(val) == TYPE_BOOL:
				if val:
					l.text = "enables " + str(k)
					l.modulate = Color.WEB_GREEN
				else:
					l.text = "disables " + str(k)
					l.modulate = Color.INDIAN_RED
			else:
				if val > 0.0:
					l.text = str(k) + " + " + str(val)
					l.modulate = Color.WEB_GREEN
				else:
					l.text = str(k) + " - " + str(val)
					l.modulate = Color.INDIAN_RED
			$workingArea/HFlowContainer.add_child(l)
		if data.size() == 6: #checks for set_bonus key
			var sb_key = data[5]
			var sb_data = Lookup.set_bonus[sb_key]
			var header = Label.new()
			header.text = "part of set "
			header.modulate = Color.AQUA
			$workingArea/HFlowContainer.add_child(header)
			for nk in sb_data[0].keys():
				var n = sb_data[0][nk]
				var h = Label.new()
				h.text = ", " + str(n)
				var t = Lookup.items[n][2]
				h.modulate = Lookup.item_color_lookup[t]
				$workingArea/HFlowContainer.add_child(h)
			var b = Label.new()
			b.text = "full set bonuses"
			b.modulate = Color.BLUE
			$workingArea/HFlowContainer.add_child(b)
			for sbk in sb_data[1].keys():
				var l = Label.new()
				l.text = ""
				var val = sb_data[1][sbk]
				if typeof(val) == TYPE_BOOL:
					if val:
						l.text = "enables " + str(sbk)
						l.modulate = Color.STEEL_BLUE
					else:
						l.text = "disables " + str(sbk)
						l.modulate = Color.MEDIUM_PURPLE
				else:
					if val > 0.0:
						l.text = str(sbk) + " + " + str(val)
						l.modulate = Color.STEEL_BLUE
					else:
						l.text = str(sbk) + " - " + str(val)
						l.modulate = Color.MEDIUM_PURPLE
				$workingArea/HFlowContainer.add_child(l)
	else:
		match type:
			Lookup.itemType.weapons_sword:
				
				pass
			Lookup.itemType.weapons_projectile:
				
				pass
	
	
	
	
	pass
