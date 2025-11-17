extends Control

var mouse_vel = Vector2.ZERO
var last_mouse_movement = Vector2.ZERO
var offset_pos = Vector2.ZERO

func _input(event):
	if event is InputEventMouseMotion:
		last_mouse_movement = Vector2((event.relative.x / 300),(event.relative.y / 300))

func _process(delta):
	mouse_vel += last_mouse_movement * delta
	last_mouse_movement = Vector2.ZERO
	mouse_vel -= mouse_vel * 0.5 * delta
	offset_pos += mouse_vel
	#$AudioStreamPlayer2.volume_db = clamp(remap(mouse_vel.length(), 0.0, 0.05, -50.0, 0.0), -80.0, 0.0)
	$background1.material.set("shader_parameter/offset_percent",offset_pos)

func _on_play_button_down():
	get_tree().change_scene_to_file("res://main.tscn")


func _on_settings_button_down():
	printerr("haha no settings yet idiot >:3")


func _on_quit_button_down():
	get_tree().quit(3)
