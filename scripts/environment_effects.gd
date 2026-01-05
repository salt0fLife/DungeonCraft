extends Node3D

func _ready():
	$near.connect("finished", _on_finished)
	_on_finished()

var lightning_chance_timer = 0.0
@export var lightning_chance = 1.0
func _process(delta):
	transform = Global.camera_transform
	rotation = Vector3.ZERO
	
	lightning_chance_timer += delta * lightning_chance
	if lightning_chance_timer > 10.0:
		lightning_chance_strike()
		lightning_chance_timer = 0.0
	
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
		for step in range(1, int(dis)):
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

func lightning_chance_strike():
	var pos = Vector2(randf_range(-1.0,1.0),randf_range(-1.0,1.0))*800.0
	Global.instance_projectile("lightning", position+Vector3(pos.x,0.0,pos.y), Vector3.UP,"weather")
	
	pass
