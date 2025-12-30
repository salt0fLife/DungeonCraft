extends Control


#func ready():
	#$VBoxContainer/FOV.connect("drag_started", controller_changed.bind($VBoxContainer/FOV.value,"desired_fov",true,$VBoxContainer/FOV2,"FOV : "))
	#$VBoxContainer/FOV.connect("value_changed",print_input)
	#pass

func controller_changed(new_val, settings_key : String, update_graphics = false, node_to_update = null, base_text = "") -> void: #[settings_key, new_val, change_node_bool, node_to_update, base_text]
	print(new_val)
	assert(Settings.user_settings.has(settings_key), "user_settings has key")
	assert(typeof(Settings.user_settings[settings_key])==typeof(new_val),"user_settings value is same type")
	Settings.user_settings[settings_key] = new_val
	if !update_graphics:
		return
	var text = base_text + str(new_val)
	assert(node_to_update != null,"node_to_update exists")
	node_to_update.text = text

func print_input(val):
	print(val)
	pass


func _on_fov_value_changed(value):
	Settings.user_settings["desired_fov"] = value
	$VBoxContainer/FOV2.text = "FOV : " + str(value)

func _on_look_sensitivity_value_changed(value):
	Settings.user_settings["look_sensitivity"] = value
	$VBoxContainer/look_sensitivity2.text = "look sensitivity : " + str(value)

func _on_speed_fov_effect_value_changed(value):
	Settings.user_settings["speed_fov_effect"] = value
	$VBoxContainer/speed_FOV_effect2.text = "speed FOV effect : " + str(value)

func _on_flying_tilt_power_value_changed(value):
	Settings.user_settings["flying_tilt_power"] = value
	$VBoxContainer/flying_tilt_power2.text = "flying camera tilt : " + str(value)

func close():
	Settings.emit_signal("updated")
	hide()

