extends Node

var lobbyID = 0
var peer = SteamMultiplayerPeer.new()
var localPeer = ENetMultiplayerPeer.new()
var playerName = str(Steam.getPersonaName())
@onready var playerSync = $playerSync
@onready var key_selector = $Control/skinKey
var hosting = false

var skin_key = "default"
var skins = ["default"]

const naming = [["cruel", "laughable", "evil", "friendly", "small", "diabolical"], ["Jonathan", "Julius", "Jessica", "Jeremy", "Jerimiah", "Justin", "Josiah", "James", "Dave"]]

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	Global.connect("spawn_projectile", _on_spawn_projectile)
	Global.connect("spawnCreature", _on_spawn_creature)
	Global.connect("change_world", _on_change_world)
	skin_key = load_file("", "skin_key.dat")
	print("loaded skin_key " + str(skin_key))
	if skin_key == null:
		skin_key = "default"
		save_file("", "skin_key.dat", skin_key)
	update_skins()
	peer.lobby_created.connect(_on_lobby_created)
	Steam.lobby_match_list.connect(on_lobby_match_list)
	open_lobby_list()
	multiplayer.server_relay = true
	multiplayer.connect("server_disconnected", _on_lost_connection)
	load_skin_info()

func load_skin_info():
	print("loaded skin with key " + str(skin_key))
	var skinInfo = {}#load_file("skins/", skin_key)
	if skin_key == "default":
		var file = FileAccess.open("res://defaultSkinInfo.txt", FileAccess.READ)
		skinInfo = file.get_var()
		file.close()
	else:
		skinInfo = load_file("skins/", skin_key)
	if !skinInfo == null:
		Global.ears = skinInfo["ears"]
		Global.tail = skinInfo["tail"]
		Global.snout = skinInfo["snout"]
		Global.skin = skinInfo["skin"]
		if skinInfo.has("mouthData"):
			Global.mouthData = skinInfo["mouthData"]
		else:
			printerr("skin has no mouthData")
		if skinInfo.has("eyeColor"):
			Global.eyeColor = skinInfo["eyeColor"]
		else:
			printerr("skin has no eyeColor")
		if skinInfo.has("slim"):
			Global.slim = skinInfo["slim"]
		else:
			printerr("skin has no slim")
		Global.display_name = skinInfo["display_name"]
		$Control/nameInput.text = Global.display_name
		$Control/skinPreview.texture = Global.data_to_image(Global.skin)
		$Control/importDialogue.text = "loaded from last save"
	else:
		generate_random_name()
		Global.ears = 0
		Global.tail = 0
		Global.snout = 0
		$Control/filepathInput.text = "res://assets/playerSkins/defaultSkin.png"
		_on_skin_import_button_down()

func generate_random_name():
	Global.display_name = str(naming[0].pick_random() + " " + naming[1].pick_random())
	$Control/nameInput.text = Global.display_name
	pass

func host_local():
	Global.is_host = true
	hosting = true
	set_display_name(0)
	print(str(Steam.getPersonaName()))
	print("host called")
	var error = localPeer.create_server(8081, 12)
	if error:
		return error
	multiplayer.multiplayer_peer = localPeer
	multiplayer.server_relay = true
	playerSync.boot(true)
	hide_menu()
	_on_change_world("debug")

func join_local(address = ""):
	Global.is_host = false
	set_display_name(1)
	playerSync.boot(false)
	if address.is_empty():
		address = "192.168.87.247"
	peer = ENetMultiplayerPeer.new()
	var error = peer.create_client(address, 8081)
	if error:
		return error
	multiplayer.multiplayer_peer = peer
	hide_menu()

func hide_menu():
	$Control.visible = false
	pass

##buttons
func _on_host_local_button_down():
	host_local()

func _on_join_local_button_down():
	join_local()

##steam lobbies
func open_lobby_list():
	Steam.addRequestLobbyListDistanceFilter(Steam.LOBBY_DISTANCE_FILTER_WORLDWIDE)
	Steam.requestLobbyList()

func on_lobby_match_list(lobbies):
	if lobbies.size() < 1:
		print("found no lobbies")
	
	for lobby in lobbies:
		var lobbyName = Steam.getLobbyData(lobby, "name")
		var memCount = Steam.getNumLobbyMembers(lobby)
		
		var but = Button.new()
		
		but.set_text(str(lobbyName) + " :  " + str(memCount) +"/12")
		but.set_size(Vector2(438,5))
		but.connect("pressed", Callable(self, "_on_lobby_button_pressed").bind(lobby))
		$Control/lobbyButtons.add_child(but)

func _on_lobby_created(LobbyConnect, id):
	if LobbyConnect:
		lobbyID = id
		playerName = Steam.getPersonaName()
		Steam.setLobbyData(lobbyID, "name", playerName + "'s lobby")
		Steam.setLobbyJoinable(lobbyID, true)
		print("lobby created with id == " + str(lobbyID))
	pass

func _on_lost_connection() -> void:
	peer.close()
	peer = SteamMultiplayerPeer.new()
	print("lost connection to host")
	if get_tree() != null:
		get_tree().change_scene_to_file("res://main.tscn")

func _on_lobby_button_pressed(id):
	print("pressed lobby button with lobby id == " + str(id))
	join_lobby(id)
	pass

func join_lobby(id):
	Global.is_host = false
	set_display_name(Steam.getNumLobbyMembers(id))
	playerSync.boot(false)
	await get_tree().process_frame
	await get_tree().process_frame
	peer.connect_lobby(id)
	multiplayer.multiplayer_peer = peer
	lobbyID = id
	hide_menu()

func host():
	Global.is_host = true
	hosting = true
	set_display_name(0)
	multiplayer.server_relay = true
	peer.create_lobby(SteamMultiplayerPeer.LOBBY_TYPE_PUBLIC)
	multiplayer.multiplayer_peer = peer
	multiplayer.server_relay = true
	playerSync.boot(true)
	hide_menu()
	_on_change_world("debug")

func refresh():
	for i in $Control/lobbyButtons.get_children(false):
		i.queue_free()
	open_lobby_list()

func _on_refresh_list_button_down():
	refresh()

func _on_host_button_down():
	host()

func _on_cosmetics_test_toggled(toggled_on):
	if toggled_on:
		Global.skin_id = 1
	else:
		Global.skin_id = 0

func set_display_name(playerCount = 0):
	var txt = $Control/nameInput.text
	if txt.is_empty():
		txt = Global.display_name
	if txt.is_empty():
		if playerCount == 0:
			txt = "HOST"
		else:
			txt = "guest" + str(playerCount)
	Global.display_name = txt

func _on_skin_import_button_down():
	var path = $Control/filepathInput.text
	if FileAccess.file_exists(path):
		var image = Image.load_from_file(path)
		var data = image.get_data()
		var format = image.get_format()
		var x = image.get_width()
		var y = image.get_height()
		if x > 256 or y > 256:
			$Control/importDialogue.text = "invalid size"
			return
		var mip = image.has_mipmaps()
		Global.skin = [x,y,mip,format,data]
		$Control/skinPreview.texture = Global.data_to_image(Global.skin)
		$Control/importDialogue.text = "success!"
		var info = {
			"skin" : Global.skin,
			"ears" : Global.ears,
			"tail" : Global.tail,
			"snout" : Global.snout,
			"display_name" : Global.display_name
			}
		var count = skins.size()
		skin_key = "imported"+str(count)
		save_file("skins/", skin_key, info)
		update_skins()
	else:
		$Control/importDialogue.text = "file not found"

func save_file(subFolder : String, fileName : String, data) -> void:
	if !DirAccess.dir_exists_absolute(Global.savePath+subFolder):
		DirAccess.make_dir_recursive_absolute(Global.savePath+subFolder)
	var path = Global.savePath+subFolder+fileName
	var file = FileAccess.open(path, FileAccess.WRITE)
	file.store_var(data)
	file.close()
	print("saved " + fileName)

func load_file(subFolder : String, fileName : String):
	var path = Global.savePath+subFolder+fileName
	if !DirAccess.dir_exists_absolute(Global.savePath+subFolder):
		printerr("tried to load from nonexistant directory")
		return null
	if FileAccess.file_exists(path):
		var file = FileAccess.open(path, FileAccess.READ)
		var data = file.get_var()
		file.close()
		print("loaded " + fileName)
		return data
	else:
		printerr("tried to load nonexistant file " + fileName)
		return null

func _on_ears_toggled(toggled_on):
	Global.ears = toggled_on
	save_skin_info()

func _on_tail_toggled(toggled_on):
	Global.tail = toggled_on
	save_skin_info()

func _on_snout_toggled(toggled_on):
	Global.snout = toggled_on
	save_skin_info()

func save_skin_info():
	var data = {
		"skin" : Global.skin,
		"ears" : Global.ears,
		"tail" : Global.tail,
		"snout" : Global.snout,
		"display_name" : Global.display_name,
		"slim" : Global.slim,
		"mouthInfo" : Global.mouthInfo,
		"eyeColor" : Global.eyeColor
	}
	save_file("skins/", skin_key, data)
	pass

func _on_randomize_name_button_down():
	generate_random_name()

func _on_name_input_text_changed():
	Global.display_name = $Control/nameInput.text
	pass # Replace with function body.

func update_skins():
	skins = Global.get_skin_list()
	for i in range(0, key_selector.item_count):
		key_selector.remove_item(i)
	key_selector.add_item("default")
	for s in skins:
		key_selector.add_item(s)

func _on_skin_key_item_selected(index):
	skin_key = key_selector.get_item_text(index)
	save_file("", "skin_key.dat", skin_key)
	load_skin_info()

func _on_save_button_down():
	Global.display_name = $Control/nameInput.text
	save_skin_info()
	pass # Replace with function body.

func _on_quit_button_down():
	get_tree().quit(3)
	pass # Replace with function body.

@onready var skinEditor = load("res://tools/skin_editor.tscn")
func _on_skin_editor_button_down():
	add_child(skinEditor.instantiate())
	pass # Replace with function body.

##pause menu stuffs
var is_paused = false
@onready var pause_menu = $pauseMenu
func _input(event):
	if Input.is_action_just_pressed("pause"):
		if $Control.visible:
			return
		if is_paused:
			is_paused = false
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			Global.disable_avatar = false
			pause_menu.hide()
		else:
			is_paused = true
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			Global.disable_avatar = true
			pause_menu.show()

func _on_resume_button_down():
	is_paused = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	Global.disable_avatar = false
	pause_menu.hide()

func _on_leave_button_down():
	Global.disable_avatar = false
	pause_menu.hide()
	disconnect_multiplayer()

@rpc("any_peer", "call_remote")
func disconnect_multiplayer() -> void:
	print("disconnect called")
	if multiplayer == null:
		printerr("WARNING: multiplayer == null")
		return
	if hosting:
		hosting = false
		disconnect_multiplayer.rpc()
		print("disconnect rpc sent")
	multiplayer.multiplayer_peer.disconnect_peer(1)
	peer.close()
	peer = SteamMultiplayerPeer.new()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	get_tree().change_scene_to_file("res://main.tscn")

##spawning creatures
@onready var creatureSync = $creatureSync
func _on_spawn_creature(creature, location, require_host = true):
	if !hosting and require_host:
		return
	print("spawn_creature_called")
	creatureSync.add_child(creature, true)
	creature.position = location
	pass

@onready var worldSync = $worldSync
func _on_change_world(key, require_host = false):
	for e in creatureSync.get_children(false):
		e.queue_free()
	for i in worldSync.get_children(false):
		i.queue_free()
	worldSync.add_child(load(Lookup.worlds[key][0]).instantiate(), true)
	Global.inside = Lookup.worlds[key][1]
	for p in get_tree().get_nodes_in_group("player"):
		p.tp(Vector3.ZERO)
		p.tp.rpc(Vector3.ZERO)
	pass

@onready var projectileSync = $projectileSync
func _on_spawn_projectile(proj, pos, dir, owned_by = ""):
	if multiplayer.get_unique_id() != 1:
		spawn_projectile.rpc_id(1, proj, pos, dir, owned_by)
		#rpc_id(1, "spawn_projectile", proj, pos, dir)
	else:
		spawn_projectile(proj, pos, dir, owned_by)

const projectile_limit = 256
@rpc("any_peer", "reliable")
func spawn_projectile(key, pos, dir, owned_by):
	if projectileSync.get_child_count(false) > (projectile_limit - 1):
		projectileSync.get_child(0).queue_free()
	var proj = load(Lookup.Projectiles[key]).instantiate()
	proj.dir = dir
	proj.owned_by = owned_by
	projectileSync.add_child(proj, true)
	proj.position = pos
	proj.velocity = proj.dir*proj.speed
