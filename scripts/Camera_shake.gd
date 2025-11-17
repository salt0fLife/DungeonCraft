extends Camera3D

func _ready():
	Global.connect("camera_impact", _on_impact)
	pass

func _on_impact(pos, power):
	print("camera recieved impact")
	print(pos)
	print(power)
	var dis = (global_position - pos).length()
	if dis > max_distance:
		dis = max_distance
	var true_pow = power * (1.0 - remap(dis, 0.0, max_distance, 0.0, 1.0))
	amplitude = remap(true_pow, 0.0, 1.0, 0.0, max_amplitude)
	pass

const max_amplitude = 0.2
const max_distance = 50.0
var frequency = 64.0
var decay = 2.0
var amplitude = 0.0
var time = 0.0
func _process(delta):
	time += delta
	if time > 64*PI:
		time -= 64*PI
	rotation.x = sin(time*frequency)*amplitude * PI *0.25
	rotation.y = sin(time*frequency*0.9)*amplitude * PI *0.25
	rotation.z = sin(time*frequency*1.1)*amplitude * PI *0.05
	amplitude -= amplitude * decay * delta
	pass
