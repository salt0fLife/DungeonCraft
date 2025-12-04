extends Control

const time_till_hide = 10.0
var unused_hide_timer = 0.0
var moving_indicator = false
var desired_pos = 0.0
var moving_time = 0.0
var hide_want = true

func _ready():
	#_on_hotbar_slot_changed()
	update_hotbar_graphics()
	Inventory.connect("update_held_item", _on_hotbar_slot_changed)
	Inventory.connect("update_hotbar", update_hotbar_graphics)
	Global.connect("update_skin", load_skin)
	for i in range(0,$hotbar/slots/itemIcons.get_children().size()):
		var n = $hotbar/slots/itemIcons.get_child(i)
		n.connect("mouse_entered", preview_hotbar_indx.bind(i))
		#n.connect("mouse_exited", preview_hide)
	pass

func preview_hotbar_indx(i: int):
	var key = Inventory.hotbar[i]
	if key == "":
		return
	$itemPreview.visible = true
	$itemPreview.update_graphics_from_key(key)
	pass

func preview_hide():
	$itemPreview.visible = false

func update_hotbar_graphics():
	#update item graphics :3
	for i in Inventory.hotbar.size():
		var k = Inventory.hotbar[i]
		var node = $hotbar/slots/itemIcons.get_child(i)
		if k == "":
			node.hide()
		else:
			node.texture = Inventory.get_item_texture(k)
			node.visible = true
	pass

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
	if $accessories.visible:
		var pos = get_viewport().get_mouse_position() - get_viewport_rect().size*0.1
		pos = pos/get_viewport_rect().size
		avatar.head_angle = Vector2(pos.y*PI*0.5,pos.x*PI*0.5)
		pass
	if $itemPreview.visible:
		$itemPreview.position = get_viewport().get_mouse_position()
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
	pass

var accessories_paths = {}
@onready var avatar = $accessories/SubViewport/SubViewport/playerAvatar/genericAvatar
func load_accessories(a = Inventory.accessories):
	for k in a.keys():
		var val = a[k]
		if accessories_paths.has(k):
			if accessories_paths[k] != null:
				for p in accessories_paths[k]:
					p.queue_free()
				accessories_paths[k] = null
		if val != "":
			accessories_paths[k] = []
			for g in Lookup.items[val][3][0]:
				var s = load(g[0]).instantiate()
				avatar.bone_paths[g[1]].add_child(s)
				accessories_paths[k] += [s]

func load_skin():
	var t = [Global.ears, Global.tail, Global.snout, Global.slim, Global.eyeColor, Global.mouthData]
	var skin_img = Global.data_to_image(Global.skin)
	avatar.load_skin(skin_img, t[0],t[1],t[2],t[3],t[4],t[5])
