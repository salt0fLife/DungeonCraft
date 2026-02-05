extends Node3D
@onready var main = get_parent().get_parent()
@onready var tree_2 = preload("res://assets/environmentPieces/trees/tree_pine_2.tscn")
@onready var waystone = preload("res://debug/debug_waystone.tscn")
@onready var tree_noise = main.tree_noise

func update_from_pos(pos : Vector2i) -> void:
	position = Vector3(pos.x*64.0,0.0,pos.y*64.0)
	for x in range(0,64):
		for y in range(0,64):
			if !(x %8 == 0 and y%8==0):
				continue #save a little time and keep trees apart
			var coord = Vector2(x+pos.x*64.0,y+pos.y*64.0)
			add_tree(coord)
			#var t_noise = tree_noise.get_noise_2d(coord.x*10.0,coord.y*10.0)+0.5
			#if t_noise < 0.0:
				#add_tree(coord)
			#elif x== 0:
				#print(t_noise)
	pass

@onready var treeHandler = $treeHandler
func add_tree(pos : Vector2) -> void:
	var tree_pos = Vector3(float(pos.x),main.get_rounded_height_from_pos(Vector2(float(pos.x),float(pos.y))),float(pos.y))
	var t = tree_2.instantiate()
	treeHandler.add_child(t)
	t.global_position = tree_pos
	
	#var waystone_pos = Vector3(float(pos.x),main.get_rounded_height_from_pos(Vector2(float(pos.x),float(pos.y))),float(pos.y))
	#var w = waystone.instantiate()
	#treeHandler.add_child(w)
	#w.global_position = waystone_pos



