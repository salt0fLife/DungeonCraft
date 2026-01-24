extends Control
#"debug_speed_boot_R" : ["speed boots 2", "res://accessories/boots/leather_boot_graphics.tscn", itemType.accessories_shoes, [[["res://accessories/boots/leather_boot_graphics.tscn", 4]], {"speed" : +0.25, "speed_multiplier" : +0.5, "defense_footR" : +0.1}], "","debug_speed_boots"],

func _ready():
	#update_graphics_from_key("debug_speed_boot_R")
	pass
@onready var node_handler = $workingArea/PanelContainer/HFlowContainer
func update_graphics_from_key(key):
	if key == "":
		return
	var data = Lookup.items[key]
	for n in node_handler.get_children(false):
		n.queue_free() #removes last items info
	$item_name.text = data[0]
	var dt = TextureRect.new()
	dt.texture = Inventory.get_item_texture(key)
	node_handler.add_child(dt)
	#$workingArea/HFlowContainer/textureDisplay.texture = Inventory.get_item_texture(key)
	var type = data[2]
	var n_l = Label.new()
	n_l.text = data[0]
	node_handler.add_child(n_l)
	
	if Lookup.items_lore.has(key):
		var l_l = Label.new()
		l_l.text = Lookup.items_lore[key]
		l_l.modulate = Color.GOLD
		node_handler.add_child(l_l)
	
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
			node_handler.add_child(l)
		if data.size() == 6: #checks for set_bonus key
			var sb_key = data[5]
			var sb_data = Lookup.set_bonus[sb_key]
			var header = Label.new()
			header.text = "part of set "
			header.modulate = Color.AQUA
			node_handler.add_child(header)
			for nk in sb_data[0].keys():
				var n = sb_data[0][nk]
				var h = Label.new()
				h.text = ", " + str(n)
				var t = Lookup.items[n][2]
				h.modulate = Lookup.item_color_lookup[t]
				node_handler.add_child(h)
			var b = Label.new()
			b.text = "full set bonuses"
			b.modulate = Color.BLUE
			node_handler.add_child(b)
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
				node_handler.add_child(l)
	else:
		match type:
			Lookup.itemType.weapons_sword:
				
				pass
			Lookup.itemType.weapons_projectile:
				
				pass
	
	
	
	
	pass

var anchor_up = true
func set_anchor_up(val):
	anchor_up = val
	if !val:
		$workingArea.set_anchors_and_offsets_preset(PRESET_CENTER_BOTTOM,false)
		$workingArea/PanelContainer.set_anchors_and_offsets_preset(PRESET_CENTER_BOTTOM,false)
		$workingArea.position.y = -8.0
	else:
		$workingArea.set_anchors_and_offsets_preset(PRESET_CENTER_TOP ,false)
		$workingArea/PanelContainer.set_anchors_and_offsets_preset(PRESET_CENTER_TOP ,false)
		$workingArea.position.y = 8.0

func add_graphics_from_custom_data(data : Dictionary) -> void:
	if data.keys().has("enchantments"):
		var evil_mat = load("res://assets/materials/max_stat_mat.tres").duplicate()
		evil_mat.set("shader_parameter/shaky",true)
		evil_mat.set("shader_parameter/enchanted_col", Color.CRIMSON)
		evil_mat.set("shader_parameter/wavy",false)
		for ench in data["enchantments"]:
			var l = Label.new()
			l.set("theme_override_fonts/font", load("res://assets/fonts/NOTOSANSOLDTURKIC-REGULAR.TTF"))
			l.text = Lookup.enchantment_names[ench]#str(ench)
			l.modulate = Lookup.enchantment_colors[ench]
			if Lookup.good_enchantments.has(ench):
				l.material = load("res://assets/materials/legendary_stat_mat.tres")
			elif Lookup.godly_enchantments.has(ench):
				l.material = load("res://assets/materials/max_stat_mat.tres")
			elif Lookup.evil_enchantments.has(ench):
				l.material = evil_mat
			node_handler.add_child(l)
	if data.keys().has("storage"):
		#var p = PanelContainer.new()
		#node_handler.add_child(p)
		for i in data["storage"]:
			var t_r = TextureRect.new()
			t_r.texture = Inventory.get_item_texture(i[0])
			node_handler.add_child(t_r)
