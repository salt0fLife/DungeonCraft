extends Node3D




func _on_area_3d_body_entered(body):
	var c = load("res://entities/blue_slime.tscn").instantiate()#load("res://debug/debug_enemy.tscn").instantiate()
	Global.emit_signal("spawnCreature", c, global_position)

