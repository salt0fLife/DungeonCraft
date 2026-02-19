extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready():
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	transform = Global.camera_transform
	rotation = Vector3.ZERO
	update_outside_nearness(delta)
	

var outside_nearness = 0.0


func update_outside_nearness(delta) -> void:
	var nearness = 0.0 #0 is not close 1 is outside
	for r in $walls_check_lightweight/checks.get_children():
		var poi = r.target_position + global_position
		if r.is_colliding():
			poi = r.get_collision_point()
		var dis = (poi - global_position).length()
		#find distance_to_wall if one
		var rc = r.get_child(0).get_child(0)
		var min_dis = dis
		for step in range(1, int(dis)):
			var pos = lerp(global_position, poi, remap(float(step), 0.0, dis, 0.0, 1.0))
			rc.global_position = pos
			rc.force_raycast_update()
			if !rc.is_colliding():
				min_dis = remap(float(step), 0.0, dis, 0.0, 1.0)
				break
		#gets the nearest distance to exposed sky checking in steps of 1m
		nearness = min_dis
	outside_nearness = lerp(outside_nearness,nearness,delta*4.0)
