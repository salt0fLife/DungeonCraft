extends Node3D
var activated = false
@export var world_key: String

func _ready():
	await get_tree().process_frame #so all the players can spawn in too
	check_players_status()
	Global.connect("player_death",check_players_status)

var valid_players = 0 # i know this is not a perfect way to do this but it works and they will all be teleported regardless

func _on_area_3d_body_entered(body):
	valid_players += 1
	check_players_status()
	pass # Replace with function body.

func _on_area_3d_body_exited(body):
	valid_players -= 1
	check_players_status()
	pass # Replace with function body.

@onready var candelabra = $candelabra
func check_players_status():
	#print(Global.living_players)
	if activated:
		return
	candelabra.heads = get_living_player_count()#Global.living_players.size()
	candelabra.lit_count = valid_players
	candelabra.update_graphics()
	if !is_multiplayer_authority():
		return
	
	if valid_players == candelabra.heads:
		print("go to new world!!!")
		activate()
		activate.rpc()

func get_living_player_count():
	var count = 0
	for p in get_tree().get_nodes_in_group("player"):
		if !p.ghost:
			count += 1
	return count

@rpc("reliable")
func activate():
	activated = true
	$AnimationPlayer.play("activate")
	print("activated")
	$StaticBody3D.set_collision_layer_value(1,true)
	
	if is_multiplayer_authority():
		await  get_tree().create_timer(3.0).timeout
		Global.emit_signal("change_world",world_key) #yay! :D
	pass
