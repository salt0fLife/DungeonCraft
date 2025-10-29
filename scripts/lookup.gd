extends Node

const Accessories = {
	"devil wings" : ["res://accessories/cape/wings.tscn", {"can_fly":true,"flying_speed":+2.0,"jump_velocity":+3.0, "speed" : +0.25}],
	"iron chestpiece" : ["res://accessories/shirt/iron_chestpiece.tscn", {"speed" : -0.1, "jump_velocity":-0.1}],
	"iron helmet" : ["res://accessories/hat/iron_helmet.tscn", {"speed" : -0.05}],
	"iron leggings" : ["res://accessories/pants/iron_leggings.tscn", {"speed" : -0.2, "jump_velocity":-0.1}],
	"iron gauntlets" : ["res://accessories/gloves/iron_gauntlets.tscn", {"speed" : - 0.01}],
	"leather boots" : ["res://accessories/boots/leather_boots.tscn", {"speed" : +0.25}]
}

const Projectiles = {
	"arrow" : "res://entities/projectiles/arrow.tscn"
	
}

const worlds = {
	"world1" : ["res://world/world_1.tscn", 1.0],
	"peaceful_island" : ["res://world/peaceful_island.tscn", 0.0],
	"world2" : ["res://world/world_2.tscn", 0.2],
	"debug" : ["res://debug/debug_world.tscn", 0.0]
}

enum itemType {
	crafting_throwable #[damage]
}

const items= { #[display_name, graphics_path, weight_lbs, radius, type_enum, data]
	"simple_rock" : ["rock", "res://assets/itemGraphics/rock_graphics.tscn", 2.0, 0.25, itemType.crafting_throwable, [10.0]]
}
