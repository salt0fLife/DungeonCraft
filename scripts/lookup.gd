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
	accessories_chestplate,
	accessories_hat,
	accessories_pants,
	accessories_gloves,
	accessories_shoes,
	accessories_leggings,
	accessories_greaves,
	accessories_necklace,
	accessories_ring,
	accessories_crown,
	accessories_bracelet,
	accessories_belt,
	racial_changes,
	subclass_changes,
	weapons_sword, #[damage, range, damage_stab, block_defense]
	weapons_projectile #[projectile_key, animation_key]
}

const item_color_lookup = {
	itemType.crafting_throwable : Color.WHITE,
	itemType.accessories_cape : Color.SKY_BLUE,
	itemType.accessories_shirt : Color.ROYAL_BLUE,
	itemType.accessories_hat : Color.GOLDENROD,
	itemType.accessories_pants : Color.NAVY_BLUE,
	itemType.accessories_gloves : Color.DARK_RED,
	itemType.accessories_shoes : Color.BROWN,
	itemType.weapons_sword : Color.RED,
	itemType.weapons_projectile : Color.YELLOW_GREEN,
}

const accessories_types = [
	itemType.accessories_cape,
	itemType.accessories_shirt,
	itemType.accessories_hat,
	itemType.accessories_pants,
	itemType.accessories_gloves,
	itemType.accessories_shoes,
]

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
	lightning,
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
	"purple",
	"aqua"
]

const items= { #[display_name, graphics_path, type_enum, data, 2dImage, set_bonus_key(if applicable)]
	##crafting
	"simple_rock" : ["rock", "res://assets/itemGraphics/rock_graphics.tscn", itemType.crafting_throwable, [10.0], ""],
	
	##accessories
	"devil_wings" : ["devil wings", "res://accessories/cape/wings.tscn", itemType.accessories_cape, [[["res://accessories/cape/wings.tscn", 0]], {"can_fly":true,"flying_speed":+2.0,"jump_velocity":+3.0, "speed" : +0.25}], ""],
	"debug_cape" : ["devil wings", "res://accessories/cape/debug_cape.tscn", itemType.accessories_cape, [[["res://accessories/cape/debug_cape.tscn", 0]], {"can_fly":true,"flying_speed":+1.0, "speed" : +0.25}], ""],
	"speed_boots" : ["speed boots", "res://accessories/boots/leather_boot_graphics.tscn", itemType.accessories_shoes, [[["res://accessories/boots/leather_boot_graphics.tscn", 2],["res://accessories/boots/leather_boot_graphics.tscn", 4]], {"speed" : +2.0, "speed_multiplier" : +0.5, "defense_footL" : +0.1, "defense_footR" : +0.1}], ""],
	"debug_speed_boot_L" : ["speed boots 2", "res://accessories/boots/leather_boot_graphics.tscn", itemType.accessories_shoes, [[["res://accessories/boots/leather_boot_graphics.tscn", 2]], {"speed" : +0.25, "speed_multiplier" : +0.5, "defense_footL" : +0.1}], "","debug_speed_boots"],
	"debug_speed_boot_R" : ["speed boots 2", "res://accessories/boots/leather_boot_graphics.tscn", itemType.accessories_shoes, [[["res://accessories/boots/leather_boot_graphics.tscn", 4]], {"speed" : +0.25, "speed_multiplier" : +0.5, "defense_footR" : +0.1}], "","debug_speed_boots"],
	
	##armor
	"rusted_copper_helmet" : ["rusted copper helmet", "res://assets/itemGraphics/armor/rustedCopper/rustedCopperHelmet.glb", itemType.accessories_hat, [[["res://assets/itemGraphics/armor/rustedCopper/rustedCopperHelmet.glb", 5]], {"defense_head" : +0.1, "speed": -0.1}], "res://assets/textures/items/rusted copper helmet tn.png"],
	"copper_helmet" : ["copper helmet", "res://assets/itemGraphics/armor/copper/copperHelmet.glb", itemType.accessories_hat, [[["res://assets/itemGraphics/armor/copper/copperHelmet.glb", 5]], {"defense_head" : +0.2, "speed": -0.1}], "res://assets/textures/items/copper helmet tn.png"],
	"rusted_iron_helmet" : ["rusted iron helmet", "res://assets/itemGraphics/armor/rustedIron/rustedIronHelmet.glb", itemType.accessories_hat, [[["res://assets/itemGraphics/armor/rustedIron/rustedIronHelmet.glb", 5]], {"defense_head" : +0.2, "speed": -0.15}], "res://assets/textures/items/rusted iron helmet tn.png"],
	"iron_helmet" : ["iron helmet", "res://assets/itemGraphics/armor/iron/ironHelmet.glb", itemType.accessories_hat, [[["res://assets/itemGraphics/armor/iron/ironHelmet.glb", 5]], {"defense_head" : +0.4, "speed": -0.15}], "res://assets/textures/items/iron helmet tn.png"],
	"copper_chestplate" : ["copper chestplate", "res://assets/itemGraphics/armor/copper/CopperChestplate.glb", itemType.accessories_chestplate, [[["res://assets/itemGraphics/armor/copper/CopperChestplate.glb", 0],["res://assets/itemGraphics/armor/copper/CopperPauldronL.glb", 6],["res://assets/itemGraphics/armor/copper/CopperPauldronR.glb", 8]], {"defense_body" : +0.2,"defense_arms" : +0.2, "speed": -0.2}], "res://assets/textures/items/copper chestplate tn.png"],
	"rusted_copper_leggings" : ["rusted copper leggings", "res://assets/itemGraphics/armor/rustedCopper/rustedCopperGreavesR.glb", itemType.accessories_leggings, [[["res://assets/itemGraphics/armor/rustedCopper/rustedCopperGreavesR.glb", 1],["res://assets/itemGraphics/armor/rustedCopper/rustedCopperGreavesL.glb", 3]], {"defense_legs" : +0.1, "speed": -0.2}], "res://assets/textures/items/rusted copper greaves tn.png"],
	
	
	##racial accessories
	"debug_tail" : ["debug tail", "res://accessories/racial/tail_debug.tscn", itemType.racial_changes, [[["res://accessories/racial/tail_debug.tscn", 0]], {"size" = -0.25}], ""],
	
	##weapons
	"iron_sword" : ["iron sword", "res://assets/itemGraphics/iron_sword.tscn", itemType.weapons_sword, [[[damageType.slash, 5.0]],3.0,[[damageType.stab, 2.5]]], "res://assets/textures/items/ironSword.png"],
	"short_bow" : ["short bow", "res://assets/itemGraphics/oak_bow.tscn", itemType.weapons_projectile, ["arrow", "punch"], ""],
	"magic_bow" : ["spark wand", "res://assets/itemGraphics/spark_wand.tscn", itemType.weapons_projectile, ["spark_bolt", "punch"], "res://assets/textures/items/sparkWand.png"]
}

const set_bonus = { #[[item1,item2,item3],{attribute modifiers}]
	"debug_speed_boots" : [{"shoeL" : "debug_speed_boot_L", "shoeR" : "debug_speed_boot_R"}, {"speed" : +1.5, "speed_multiplier" : +1.0}]
}

enum statusEffectType {
	burning,
	poisoned,
	cursed,
	bleeding,
	frozen,
	tripping
}

enum interact_return_code {
	dont_do_anything, #returns null
	is_item, #returns item_key that should be picked up
	print, #returns a string that should be printed
}
