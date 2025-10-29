extends TextureRect
var smooth_reset = false

func _ready():
	Global.connect("set_post_param", _on_global_set_post_param)

func _on_global_set_post_param(key, value) -> void:
	if key == "smooth_reset":
		smooth_reset = value
		return
	material.set(key, value)

func _process(delta):
	if !smooth_reset:
		return
	var val = material.get("shader_parameter/wave") - delta
	if val < 0.0:
		val = 0.0
		smooth_reset = false
	material.set("shader_parameter/wave", val)
	material.set("shader_parameter/flash", val)
	pass
