extends MultiplayerSpawner

@export var playerScene : PackedScene

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
	return p

func remove_player(data):
	#players[data].queue_free()
	players[data].despawn()
	players[data].despawn.rpc()
	players.erase(data)

