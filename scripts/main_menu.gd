extends Control

var lobbyID = 0
var peer = SteamMultiplayerPeer.new()
var localPeer = ENetMultiplayerPeer.new()
var playerName = str(Steam.getPersonaName())

func host_local():
	print("host called")
	var error = localPeer.create_server(8081, 12)
	if error:
		return error
	multiplayer.multiplayer_peer = localPeer
	multiplayer.server_relay = true


func join_local(address = ""):
	if address.is_empty():
		address = "192.168.87.247"
	peer = ENetMultiplayerPeer.new()
	var error = peer.create_client(address, 8081)
	if error:
		return error
	multiplayer.multiplayer_peer = peer
