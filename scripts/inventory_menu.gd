extends Control

const time_till_hide = 10.0
var unused_hide_timer = 0.0
var moving_indicator = false
var desired_pos = 0.0
var moving_time = 0.0
var hide_want = true
var held_item = Inventory.empty_item

func update_held_item_graphics():
	if held_item[0] == "":
		$held_item.hide()
	else:
		$held_item.show()
		if held_item[3].keys().has("custom_texture_path"):
			$held_item.texture = load(held_item[3]["custom_texture_path"])
		else:
			$held_item.texture = Inventory.get_item_texture(held_item[0])
		if held_item[3].keys().has("enchantments"):
			if held_item[3]["enchantments"].size() > 0:
				var col = Color.BLUE_VIOLET
				if held_item[3].keys().has("enchantment_color"):
					col = held_item[3]["enchantment_color"]
				$held_item.material.set("shader_parameter/enchanted_col", col)
			else:
				$held_item.material.set("shader_parameter/enchanted_col", Color.BLACK)
		else:
			$held_item.material.set("shader_parameter/enchanted_col", Color.BLACK)

var mat = load("res://assets/materials/item_slot_mat.tres")
func _ready():
	#_on_hotbar_slot_changed()
	update_hotbar_graphics()
	Inventory.connect("update_held_item", _on_hotbar_slot_changed)
	Inventory.connect("update_hotbar", update_hotbar_graphics)
	Inventory.connect("update_status_effect_graphics",_on_update_status_effect_graphics)
	Global.connect("update_skin", load_skin)
	for i in range(0,$hotbar/slots/itemIcons.get_children().size()):
		var n = $hotbar/slots/itemIcons.get_child(i)
		n.connect("mouse_entered", preview_hotbar_indx.bind(i))
		n.connect("mouse_exited", preview_hide)
		n.connect("button_down", _on_hotbar_pressed.bind(i))
		n.material = mat.duplicate(true)
	for k in accessory_buttons.keys():
		var b = accessory_buttons[k]
		b.connect("mouse_entered", preview_equipment_key.bind(k))
		b.connect("mouse_exited", preview_hide)
		b.connect("button_down", _on_equipment_pressed.bind(k))
		b.material = mat.duplicate(true)
	$held_item.material = mat.duplicate(true)
	$held_item.material.set("shader_parameter/transparent_background",true)
	pass

func preview_equipment_key(k: String):
	var key = Inventory.accessories[k][0]
	if key == "":
		return
	$itemPreview.visible = true
	$itemPreview.update_graphics_from_key(key)
	pass

func preview_hotbar_indx(i: int):
	var key = Inventory.hotbar[i][0]
	if key == "":
		return
	$itemPreview.visible = true
	$itemPreview.update_graphics_from_key(key)
	pass

func preview_hide():
	$itemPreview.visible = false

#func update_hotbar_graphics_old():
	##update item graphics :3
	#for i in Inventory.hotbar.size():
		#var k = Inventory.hotbar[i]
		#var node = $hotbar/slots/itemIcons.get_child(i)
		#if k == "":
			##node.hide()
			#node.texture_normal = null
		#else:
			#node.texture_normal = Inventory.get_item_texture(k)
			#node.visible = true
	#pass

func update_hotbar_graphics():
	#update item graphics :3
	for i in Inventory.hotbar.size():
		var k = Inventory.hotbar[i]
		var node = $hotbar/slots/itemIcons.get_child(i)
		if k[0] == "":
			#node.hide()
			node.texture_normal = null
		else:
			node.visible = true
			if k[3].keys().has("custom_texture_path"):
				node.texture_normal = load(k[3]["custom_texture_path"])
			else:
				node.texture_normal = Inventory.get_item_texture(k[0])
			if k[3].keys().has("enchantments"):
				if k[3]["enchantments"].size() > 0:
					var col = Color.BLUE_VIOLET
					if k[3].keys().has("enchantment_color"):
						col = k[3]["enchantment_color"]
					node.material.set("shader_parameter/enchanted_col", col)
				else:
					node.material.set("shader_parameter/enchanted_col", Color.BLACK)
			else:
				node.material.set("shader_parameter/enchanted_col", Color.BLACK)
	pass

func _on_hotbar_pressed(index):
	print(index)
	var temp = held_item
	held_item = Inventory.hotbar[index]
	Inventory.hotbar[index] = temp
	update_held_item_graphics()
	update_hotbar_graphics()
	preview_hotbar_indx(index)

func _on_equipment_pressed(key):
	print(key)
	if held_item[0] != "":
		if !Inventory.can_item_go_in_accessory(held_item[0], key):
			return # makes sure you cant put equipment in wrong slots
	var temp = held_item
	held_item = Inventory.accessories[key]
	Inventory.accessories[key] = temp
	update_held_item_graphics()
	load_accessories()
	preview_equipment_key(key)

func show_hotbar():
	unused_hide_timer = time_till_hide
	var t = get_tree().create_tween()
	t.tween_property($hotbar, "position", Vector2(0.0,0.0), 0.1)
	pass

func hide_hotbar():
	var t = get_tree().create_tween()
	t.tween_property($hotbar, "position", Vector2(0.0,80.0), 0.1)

func _on_hotbar_slot_changed():
	show_hotbar()
	desired_pos = Inventory.held_item * 64.0
	moving_indicator = true
	#$hotbar/slots/below.position.x = x
	#$hotbar/slots/above.position.x = x
	pass

func _process(delta):
	if $held_item.visible:
		$held_item.position = get_viewport().get_mouse_position() - Vector2(32.0,32.0)
	if $accessories.visible:
		var pos = get_viewport().get_mouse_position() - Vector2(get_viewport_rect().size.x*0.5,get_viewport_rect().size.y*0.17)
		pos = pos/get_viewport_rect().size
		avatar.head_angle = Vector2(pos.y*PI*0.5,pos.x*PI*0.5)
		pass
	if $itemPreview.visible:
		$itemPreview.position = get_viewport().get_mouse_position() + Vector2(0.0,-216.0)
	if moving_indicator:
		if moving_time > 0.0:
			moving_time -= delta
		else:
			moving_time = 0.1
			moving_indicator = false
			$hotbar/slots/below.position.x = desired_pos
			$hotbar/slots/above.position.x = desired_pos
		$hotbar/slots/above.position.x = lerp($hotbar/slots/below.position.x, desired_pos, moving_time*10.0)
		$hotbar/slots/below.position.x = lerp($hotbar/slots/below.position.x, desired_pos, moving_time*10.0)
	if unused_hide_timer > 0.0 and hide_want:
		unused_hide_timer -= delta
		if unused_hide_timer <= 0.0:
			unused_hide_timer = 0.0
			hide_hotbar()

func show_accessories():
	$accessories.show()
	var t = get_tree().create_tween()
	t.tween_property($accessories, "scale", Vector2(1.0,1.0),0.25)

func hide_accessories():
	var t = get_tree().create_tween()
	t.tween_property($accessories, "scale", Vector2(1.0,0.0),0.25)
	await t.finished
	$accessories.hide()

func open():
	hide_want = false
	show_hotbar()
	show_accessories()
	load_accessories()
	pass

func close():
	hide_want = true
	hide_accessories()
	$itemPreview.hide()
	Inventory.emit_signal("update_hotbar")
	Inventory.emit_signal("update_held_item")
	Inventory.emit_signal("update_accessories")
	for k in accessory_buttons:
		accessory_buttons[k].release_focus()
	for b in $hotbar/slots/itemIcons.get_children():
		b.release_focus()

@onready var accessory_buttons = {
	#armor and clothes
	"cape" : $accessories/gearR/TabContainer/clothes2/cape,
	"shirt" : $accessories/gearL/TabContainer/clothes/shirt,
	"chestplate" : $accessories/gearL/TabContainer/clothes/chestplate,
	"hat" : $accessories/gearL/TabContainer/clothes/hat,
	"pants" : $accessories/gearL/TabContainer/clothes/pants,
	"leggings" : $accessories/gearL/TabContainer/clothes/leggings,
	"gloveR" : $accessories/gearR/TabContainer/clothes2/gloveR,
	"gloveL" : $accessories/gearR/TabContainer/clothes2/gloveL,
	"shoeR" : $accessories/gearR/TabContainer/clothes2/shoeR,
	"shoeL" : $accessories/gearR/TabContainer/clothes2/shoeL,
	"greaves" : $accessories/gearL/TabContainer/clothes/greaves,
	#jewelry
	"necklace1" : $accessories/gearL/TabContainer/jewelry/necklace1,
	"necklace2" : $accessories/gearL/TabContainer/jewelry/necklace2,
	"necklace3" : $accessories/gearL/TabContainer/jewelry/necklace3,
	"necklace4" : $accessories/gearL/TabContainer/jewelry/necklace4,
	"crown" : $accessories/gearL/TabContainer/jewelry/crown,
	"braceletR" : $accessories/gearL/TabContainer/jewelry/braceletR,
	"braceletL" : $accessories/gearL/TabContainer/jewelry/braceletL,
	"belt" : $accessories/gearL/TabContainer/jewelry/belt,
	#rings
	"ringFR" : $accessories/gearR/TabContainer/rings/ringFR,
	"ringSR" : $accessories/gearR/TabContainer/rings/ringSR,
	"ringVowR" : $accessories/gearR/TabContainer/rings/ringVowR,
	"ringPR" : $accessories/gearR/TabContainer/rings/ringPR,
	"ringFL" : $accessories/gearR/TabContainer/rings/ringFL,
	"ringSL" : $accessories/gearR/TabContainer/rings/ringSL,
	"ringVowL" : $accessories/gearR/TabContainer/rings/ringPL,
	"ringPL" : $accessories/gearR/TabContainer/rings/ringVowL,
}

var accessories_paths = {}
@onready var avatar = $accessories/preview_window/SubViewport/SubViewport/playerAvatar/genericAvatar
func load_accessories(a = Inventory.accessories):
	for k in a.keys():
		var enchant_col = Color.BLACK
		var val = a[k]
		if val[3].keys().has("enchantments"):
			if val[3]["enchantments"].size() > 0:
				var col = Color.BLUE_VIOLET
				if val[3].keys().has("enchantment_color"):
					col = val[3]["enchantment_color"]
				enchant_col = col
		#gets enchant_col
		if accessories_paths.has(k):
			if accessories_paths[k] != null:
				for p in accessories_paths[k]:
					p.queue_free()
				accessories_paths[k] = null
		if val[0] != "":
			accessories_paths[k] = []
			for g in Lookup.items[val[0]][3][0]:
				var s = load(g[0]).instantiate()
				var bi = g[1]
				if k == "shoeR" and bi == 2:
					bi = 4
				elif k == "shoeL" and bi == 4:
					bi = 2 #swaps the feet for shoes
				elif (k == "gloveR" or k == "braceletR") and bi == 7:
					bi = 9
				elif (k == "gloveL" or k == "braceletL") and bi == 9:
					bi = 7 #swaps hands for bracelets and gloves
				avatar.bone_paths[bi].add_child(s)
				accessories_paths[k] += [s]
				if s is MeshInstance3D:
					var m = s.get_active_material(0).duplicate()
					m.set("shader_parameter/enchanted_col",enchant_col)
					s.set_surface_override_material(0,m)
				elif s.has_method("set_enchanted_col"):
					s.set_enchanted_col(enchant_col)
			
			
			if accessory_buttons.has(k):
				var tn = accessory_buttons[k]
				#tn.show()
				tn.texture_normal = Inventory.get_item_texture(val[0])
				tn.material.set("shader_parameter/enchanted_col", enchant_col)
		elif accessory_buttons.has(k):
			var tn = accessory_buttons[k]
			#tn.hide()
			tn.texture_normal = null
			#adding graphics to menu

func load_skin():
	var t = [Global.ears, Global.tail, Global.snout, Global.slim, Global.eyeColor, Global.mouthData]
	var skin_img = Global.data_to_image(Global.skin)
	avatar.load_skin(skin_img, t[0],t[1],t[2],t[3],t[4],t[5])




func _on_update_status_effect_graphics():
	var se = Inventory.active_status_effects
	#handles burning
	avatar.set_burning(se.has(Lookup.statusEffectType.burning), Lookup.fire_colors[0])
	#handles blighted
	if se.has(Lookup.statusEffectType.blighted):
		if se.has(Lookup.statusEffectType.burning):
			avatar.set_burning(se.has(Lookup.statusEffectType.blighted), Lookup.fire_colors[2])
		else:
			avatar.set_burning(se.has(Lookup.statusEffectType.blighted), Lookup.fire_colors[1])
	#poisoned
	avatar.set_poisoned(se.has(Lookup.statusEffectType.poisoned))
	#cursed
	avatar.set_cursed(se.has(Lookup.statusEffectType.cursed))
	#blessed
	avatar.set_blessed(se.has(Lookup.statusEffectType.blessed))


