extends Node3D

func _ready():
	$near.connect("finished", _on_finished)
	_on_finished()

func _process(delta):
	transform = Global.camera_transform
	rotation = Vector3.ZERO
	if $roofCheck.is_colliding():
		$far.volume_db = lerp($far.volume_db, 0.0, delta*2.0)
		update_rain_lightweight(delta)
	else:
		$near.volume_db = lerp($near.volume_db, 0.0, delta*2.0)
		$far.volume_db = lerp($far.volume_db, -80.0, delta*2.0)

func _on_finished():
	$near.play()
	$far.play()
	pass

func update_rain_lightweight(delta):
	var vol = -80.0
	for r in $walls_check_lightweight/checks.get_children():
		var poi = r.target_position + global_position
		if r.is_colliding():
			poi = r.get_collision_point()
		var dis = (poi - global_position).length()
		#find distance_to_wall if one
		var rc = r.get_child(0).get_child(0)
		var min_dis = dis
		for step in range(0, int(dis)):
			var pos = lerp(global_position, poi, remap(float(step), 0.0, dis, 0.0, 1.0))
			rc.global_position = pos
			rc.force_raycast_update()
			if !rc.is_colliding():
				min_dis = remap(float(step), 0.0, dis, 0.0, 1.0)
				break
		#gets the nearest distance to exposed sky checking in steps of 1m
		var v = remap(min_dis, 1.0, 0.0, -80.0, 0.0)
		if v > vol:
			#print(min_dis)
			#print(dis)
			vol = v
	$near.volume_db = lerp($near.volume_db, vol, delta*4.0)
