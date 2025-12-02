extends Node3D

func _enter_tree():
	if is_multiplayer_authority():
		settup()

func settup():
	Global.connect("player_death", check_roster)
	scatter_players()
	pass

func check_roster():
	var dead = []
	var alive = []
	for p in get_tree().get_nodes_in_group("player"):
		if p.ghost:
			dead += [p]
		else:
			alive += [p]
	print("dead = " + str(dead))
	print("alive = " + str(alive))
	if alive.size() < 2:
		if alive.size() > 0:
			print(alive[0].display_name + " wins!")
		else:
			print("tie!")
		get_tree().reload_current_scene()


func scatter_players():
	print("scattered players")
	var spawn_points = get_tree().get_nodes_in_group("player_spawn")
	var players = get_tree().get_nodes_in_group("player")
	for i in range(0, players.size()):
		var pos = Vector3.ZERO
		if i >= spawn_points.size():
			pos = Vector3.ZERO
		else:
			pos = spawn_points[i].global_position
		players[i].tp(pos)
		players[i].tp.rpc(pos)
