extends MultiplayerSpawner

@export var playerScene : PackedScene
signal player_died

var players = {}

func boot(host: bool):
	print("level spawned in")
	spawn_function = spawn_player
	if host:
		print("level is multiplayer authority")
		spawn(1)
		multiplayer.peer_connected.connect(spawn)
		multiplayer.peer_disconnected.connect(remove_player)
	else:
		print("level is not multiplayer authority")

func spawn_player(data):
	print("spawn player called in level")
	var p = playerScene.instantiate()
	p.set_multiplayer_authority(data)
	players[data] = p
	p.connect("died",_on_player_died)
	return p

func remove_player(data):
	#players[data].queue_free()
	players[data].despawn()
	players[data].despawn.rpc()
	players.erase(data)
	emit_signal("player_died") #so if the last alive disconnects it rechecks and no one is softlocked :3

func get_living_players() -> Array:
	var list = []
	for k in players.keys():
		var alive = !players[k].ghost
		if alive:
			list += [k]
	return list #all living players multiplayer_authority

func get_player_or_null(multi_auth : int):
	if players.has(multi_auth):
		return players[multi_auth]
	else:
		return null

func _on_player_died() -> void:
	emit_signal("player_died")
