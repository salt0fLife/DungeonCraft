@tool
extends Node3D

@export var a_time = 0.0
@export var opening = false
@export var world_path := "world1"

func open_animation():
	opening = true
	$CPUParticles3D.emitting = true
	$spiral_screen.visible = true
	pass

var spiral = 0.0
func _process(delta):
	if opening:
		a_time += delta*0.25
		if a_time < 1.0:
			spiral = 0.001
			set_shader_param("shader_parameter/symbols_cutoff", 1.0 -a_time + 0.003)
			set_shader_param("shader_parameter/spiral", spiral)
			#set_post_shader("shader_parameter/spiral", spiral*0.025)
			#set_post_shader("shader_parameter/wave", a_time - 1.0)
		else:
			spiral += spiral*delta
			set_shader_param("shader_parameter/spiral", spiral)
			#set_post_shader("shader_parameter/spiral", spiral*0.025)
			set_shader_param("shader_parameter/symbols_cutoff", 0.003)
			set_post_shader("shader_parameter/wave", (a_time - 1.0)*0.5)
			set_post_shader("shader_parameter/flash", (a_time - 1.0)*0.5)
			if a_time > 3.0:
				set_shader_param("shader_parameter/spiral", 0.0)
				set_shader_param("shader_parameter/symbols_cutoff", 1.0)
				#set_post_shader("shader_parameter/spiral", 0.0)
				#set_post_shader("shader_parameter/wave", 0.0)
				set_post_shader("smooth_reset", true)
				change_world()
	pass

@onready var mat = $portal_frame/portal_frame.get_active_material(0)
func set_shader_param(key, value) -> void:
	mat.set(key, value)

@onready var postMat = $spiral_screen.material
func set_post_shader(key, value) -> void:
	#postMat.set(key,value)
	Global.emit_signal("set_post_param",key, value)

func change_world():
	#var world = load(world_path).instantiate()
	Global.emit_signal("change_world", world_path, true)

func _on_area_3d_body_entered(body):
	open_animation()
