extends Node3D


@export var accessory_to_edit: = "cape"
@export var value: = ""



func _on_area_3d_body_entered(body):
	print("body_entered")
	Inventory.equip_accessory(accessory_to_edit, value)
