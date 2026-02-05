extends Node3D
var connected_pos = Vector3.ZERO
var connected = false
var max_length = 10.0
var time_between_checks = 0.5
var check_timer = 0.0
@export var desired_target_pos = Vector3.ZERO
var target_pos = Vector3.ZERO

# Called when the node enters the scene tree for the first time.
func _ready():
	target_pos = desired_target_pos
	check.target_position = target_pos
	max_length = target_pos.length()*1.5
	pass # Replace with function body.

@onready var check = $RayCast3D
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if connected:
		graphics.visible = true
		var dif = connected_pos- global_position
		var dis = dif.length()
		#graphics.update_graphics(dif)
		graphics.target_pos = dif
		if dis > max_length:
			if check.is_colliding():
				connected_pos = check.get_collision_point()
			else:
				connected = false
	check_timer += delta
	if check_timer > time_between_checks:
		if !connected:
			if check.is_colliding():
				connected_pos = check.get_collision_point()
				connected = true
			else:
				target_pos += rand_vector()
				if target_pos.length() > max_length: #keep it in check a little
					target_pos = desired_target_pos
	#graphics.update_graphics(test_pos)

@onready var graphics = $electricity_graphics
#func update_graphics(dif : Vector3) -> void:
	#$test_cube.position = dif
	##graphics.rotation.z = atan2(dif.y,dif.x)-PI*0.5
	##graphics.rotation.x = -atan2(dif.y,dif.z)+PI*0.5
	#graphics.rotation.y = atan2(dif.x,dif.z)
	#var h_l = Vector2(dif.x,dif.z).length()
	#graphics.rotation.x = atan2(h_l,dif.y)
	#var dis = dif.length()
	#graphics.scale.y = dis

func rand_vector() -> Vector3:
	return Vector3(randf_range(-1.0,1.0),randf_range(-1.0,1.0),randf_range(-1.0,1.0))
