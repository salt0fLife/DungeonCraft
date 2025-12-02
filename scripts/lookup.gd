extends Node

#const Accessories = {
	#"devil wings" : ["res://accessories/cape/wings.tscn", {"can_fly":true,"flying_speed":+2.0,"jump_velocity":+3.0, "speed" : +0.25}],
	#"iron chestpiece" : ["res://accessories/shirt/iron_chestpiece.tscn", {"speed" : -0.1, "jump_velocity":-0.1}],
	#"iron helmet" : ["res://accessories/hat/iron_helmet.tscn", {"speed" : -0.05}],
	#"iron leggings" : ["res://accessories/pants/iron_leggings.tscn", {"speed" : -0.2, "jump_velocity":-0.1}],
	#"iron gauntlets" : ["res://accessories/gloves/iron_gauntlets.tscn", {"speed" : - 0.01}],
	#"leather boots" : ["res://accessories/boots/leather_boots.tscn", {"speed" : +0.25}]
#}

@onready var Projectiles = {
	"arrow" : preload("res://entities/projectiles/arrow.tscn"),
	"spark_bolt" : preload("res://entities/projectiles/spark_bolt.tscn")
}

const worlds = {
	"world1" : ["res://world/world_1.tscn", 1.0],
	"peaceful_island" : ["res://world/peaceful_island.tscn", 0.0],
	"world2" : ["res://world/world_2.tscn", 0.2],
	"debug" : ["res://debug/debug_world.tscn", 0.0],
	"gm_construct" : ["res://world/gm_construct.tscn", 0.4],
	"skywas_test" : ["res://world/skywars_prot_rainy.tscn", 0.0]
}

enum itemType {
	crafting_throwable, #[damage]
	accessories_cape, #[[[scene_path, bone_parent_index],[scene_path, bone_parent_index]], {attribute_modifiers}]
	accessories_shirt,
	accessories_hat,
	accessories_pants,
	accessories_gloves,
	accessories_shoes,
	r_accessories_tail,
	r_accessories_ears,
	weapons_sword, #[damage, range, damage_stab, block_defense]
	weapons_projectile #[projectile_key, animation_key]
}

#damage = [[damageType.generic, amount],[damageType.stab, amount]]
enum damageType {
	generic,
	stab,
	slash,
	blunt,
	fire,
	ice,
	toxic,
	explosion,
	magic,
}

const damageType_color_lookup = [
	"white",
	"light_gray",
	"light_blue",
	"dark_red",
	"orange",
	"blue",
	"green",
	"red",
	"purple"
]

const items= { #[display_name, graphics_path, type_enum, data]
	##crafting
	"simple_rock" : ["rock", "res://assets/itemGraphics/rock_graphics.tscn", itemType.crafting_throwable, [10.0]],
	
	##accessories
	"devil_wings" : ["devil wings", "res://accessories/cape/wings.tscn", itemType.accessories_cape, [[["res://accessories/cape/wings.tscn", 0]], {"can_fly":true,"flying_speed":+2.0,"jump_velocity":+3.0, "speed" : +0.25}]],
	"debug_cape" : ["devil wings", "res://accessories/cape/debug_cape.tscn", itemType.accessories_cape, [[["res://accessories/cape/debug_cape.tscn", 0]], {"can_fly":true,"flying_speed":+1.0, "speed" : +0.25}]],
	"speed_boots" : ["speed boots", "res://accessories/boots/leather_boot_graphics.tscn", itemType.accessories_shoes, [[["res://accessories/boots/leather_boot_graphics.tscn", 2],["res://accessories/boots/leather_boot_graphics.tscn", 4]], {"speed" : +2.0, "speed_multiplier" : +0.5, "defense_footL" : +0.1, "defense_footR" : +0.1}]],
	"debug_speed_boots" : ["speed boots 2", "res://accessories/boots/leather_boot_graphics.tscn", itemType.accessories_shoes, [[["res://accessories/boots/leather_boot_graphics.tscn", 2],["res://accessories/boots/leather_boot_graphics.tscn", 4]], {"speed" : +1.0, "speed_multiplier" : +2.0, "defense_footL" : +0.1, "defense_footR" : +0.1}]],
	
	##racial accessories
	"debug_tail" : ["debug tail", "res://accessories/racial/tail_debug.tscn", itemType.r_accessories_tail, [[["res://accessories/racial/tail_debug.tscn", 0]], {"size" = -0.25}]],
	
	
	
	##weapons
	"iron_sword" : ["iron sword", "res://assets/itemGraphics/iron_sword.tscn", itemType.weapons_sword, [[[damageType.slash, 5.0]],3.0,[[damageType.stab, 2.5]]]],
	"short_bow" : ["short bow", "res://assets/itemGraphics/oak_bow.tscn", itemType.weapons_projectile, ["arrow", "punch"]],
	"magic_bow" : ["spark wand", "res://assets/itemGraphics/spark_wand.tscn", itemType.weapons_projectile, ["spark_bolt", "punch"]]
}

enum statusEffectType {
	burning,
	poisoned,
	cursed,
	bleeding,
	frozen,
	tripping
}

