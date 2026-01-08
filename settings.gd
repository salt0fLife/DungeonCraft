extends Node
signal updated
signal update_combat_boxes

var user_settings = {
	"auto_flying_perspective" : false,
	"desired_flying_perspective" : 1,
	"look_sensitivity" : 2.5,
	"desired_fov" : 90.0,
	"speed_fov_effect" : 20.0,
	"flying_tilt_power" : 1.0,
}

var show_combat_boxes = true
