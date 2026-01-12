extends Control
enum locations {
	HOTBAR,
	EQUIPMENT,
	OTHER
}

@export var item_location : locations
@export var item_key : String = ""
@export var item_index : int = 0

func get_item_data() -> Array:
	match  item_location:
		locations.HOTBAR:
			return Inventory.hotbar[item_index]
		locations.EQUIPMENT:
			return Inventory.accessories[item_key]
		locations.OTHER:
			return Inventory.empty_item
		_:
			return Inventory.empty_item

func _on_takeselector_value_changed(value):
	$backdrop/VBoxContainer/take.text = "take " + str(value) + "%"
	pass # Replace with function body.

func display():
	var data = get_item_data()
	visible = true
	var custom_data = data[3]
	$backdrop/VBoxContainer/open.visible = custom_data.keys().has("inventory")
	$backdrop/VBoxContainer/take.visible = data[1] > 1
	$backdrop/VBoxContainer/takeselector.visible = $backdrop/VBoxContainer/take.visible

func _on_mouse_exited():
	visible = false
	pass # Replace with function body.

func _on_focus_exited():
	visible = false
	pass # Replace with function body.

signal preview_item_data
func _on_preview_button_down():
	emit_signal("preview_item_data",get_item_data())
