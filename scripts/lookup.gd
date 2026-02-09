extends Node

#const Accessories = {
	#"devil wings" : ["res://accessories/cape/wings.tscn", {"can_fly":true,"flying_speed":+2.0,"jump_velocity":+3.0, "speed" : +0.25}],
	#"iron chestpiece" : ["res://accessories/shirt/iron_chestpiece.tscn", {"speed" : -0.1, "jump_velocity":-0.1}],
	#"iron helmet" : ["res://accessories/hat/iron_helmet.tscn", {"speed" : -0.05}],
	#"iron leggings" : ["res://accessories/pants/iron_leggings.tscn", {"speed" : -0.2, "jump_velocity":-0.1}],
	#"iron gauntlets" : ["res://accessories/gloves/iron_gauntlets.tscn", {"speed" : - 0.01}],
	#"leather boots" : ["res://accessories/boots/leather_boots.tscn", {"speed" : +0.25}]
#}
#func _ready():
	###load itemData
	#var folder = DirAccess.open("res://assets/itemData/")
	#for file in folder.get_files():
		#var f = FileAccess.open("res://assets/itemData/"+file,FileAccess.READ)
		#var data = f.get_var(false)#JSON.parse_string(f.get_var(false))
		#print(data)
		#f.close()
		#var key = file.left(file.length() - 5)
		#print(file)
		#items[file] = data
	###save itemData
	#for item in items.keys():
		#var f = FileAccess.open("res://assets/itemData/"+item+".json",FileAccess.WRITE)
		#var data = items[item]#JSON.stringify(items[item])
		#f.store_var(data)
		#print(data)
		#f.close()
		##var key = file.left(file.length() - 4)
		#pass
	#pass


@onready var Projectiles = {
	"arrow" : preload("res://entities/projectiles/arrow.tscn"),
	"spark_bolt" : preload("res://entities/projectiles/spark_bolt.tscn"),
	"lightning" : preload("res://entities/lightning_bolt.tscn"),
	"lightning_seed" : preload("res://entities/projectiles/lightning_seed.tscn"),
}

const worlds = {
	"world1" : ["res://world/world_1.tscn", 1.0],
	"peaceful_island" : ["res://world/peaceful_island.tscn", 0.0],
	"world2" : ["res://world/world_2.tscn", 0.2],
	"debug" : ["res://debug/debug_world.tscn", 0.0],
	"gm_construct" : ["res://world/gm_construct.tscn", 0.4],
	"skywas_test" : ["res://world/skywars_prot_rainy.tscn", 0.0],
	"dungeon_world" : ["res://world/dungeon_world.tscn", 0.0],
	"wayland" : ["res://world/wayland_main.tscn",0.0],
	"elder_tree_temple" : ["res://world/elder_tree_temple.tscn", 0.0],
	"test_modular" : ["res://world/test_modular_world.tscn",1.0],
	"the_moor" : ["res://world/the_moor.tscn",0.0],
	"maze_world" : ["res://world/maze_world.tscn",1.0]
}

enum itemType {
	crafting_throwable, #[damage]
	book, #[path to real book] book handles its own page_turning because its so complex
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
	weapons_longsword,
	weapons_mace,
	weapons_fishing_rod,
	weapons_bow,
	weapons_spear,
	weapons_glaive,
	weapons_scythe,
	weapons_wand,
	weapons_spellbook,
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
	itemType.accessories_chestplate,
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
	holy,
	blight
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
	"aqua",
	"yellow",
	"web_purple"
]

var items= { #[display_name, graphics_path, type_enum, data, 2dImage, set_bonus_key(if applicable)]
	##debug
	"crown_of_god" : ["immortal king", "res://debug/blockRenderTestDebug.tscn", itemType.accessories_crown, [[], 
	{"can_fly":true,
	"flying_can_hover" : true, 
	"flying_speed":+99999.0,
	"jump_velocity":max_attributes["jump_velocity"]*0.25, 
	"speed" : max_attributes["speed"]*0.5,
	"speed_multiplier" : max_attributes["speed"]*0.75,
	"air_acceleration": 99999.0,
	"flying_control" : 99999.0,
	"max_health" : 99999.0,
	"max_mana" : 99999.0,
	"mana_regen_speed" : 99999.0,
	"max_stamina" : 99999.0,
	"stamina_regen_speed": 99999.0,
	"flying_can_glide" : true,
	"strength" : 99999.0,
	#"size" : 99999.0, default is expert, just dont mess with this very much because kinda wacky :/
	"localized defenses" : "dark red", #
	"defense_head" : 99999.0,
	"defense_torso" : 99999.0,
	"defense_arms" : 99999.0,
	"defense_handL" : 99999.0,
	"defense_handR" : 99999.0,
	"defense_legs" : 99999.0,
	"defense_footR" : 99999.0,
	"defense_footL" : 99999.0,
	"true_defense" : 99999.0, #only changed through race and subclass, effects all damage
	"generic_defense" : 99999.0,
	"stab_defense" : 99999.0,
	"slash_defense" : 99999.0,
	"blunt_defense" : 99999.0,
	"fire_defense" : 99999.0,
	"ice_defense" : 99999.0,
	"toxic_defense" : 99999.0,
	"explosion_defense" : 99999.0,
	"magic_defense" : 99999.0,
	"lightning_defense" : 99999.0,
	"holy_defense" : 99999.0,
	"blight_defense" : 99999.0
	}], ""],
	
	##crafting
	"simple_rock" : ["rock", "res://assets/itemGraphics/rock_graphics.tscn", itemType.crafting_throwable, [10.0], ""],
	
	##story
	"players_manual" : ["player's manual", "res://assets/itemGraphics/books/players_manual.tscn", itemType.book, ["res://assets/itemGraphics/books/players_manual.tscn"], ""],
	
	##accessories
	"debug_wings" : ["admin wings", "res://accessories/cape/wings.tscn", itemType.accessories_cape, [[["res://accessories/cape/wings.tscn", 0]], {"can_fly":true,"flying_can_hover" : true, "flying_speed":+2.0,"jump_velocity":+3.0, "speed" : +0.25}], ""],
	"devil_wings" : ["devil wings", "res://accessories/cape/devil_wings.tscn", itemType.accessories_cape, [[["res://accessories/cape/devil_wings.tscn", 0]], {"can_fly":true,"flying_can_glide":true, "flying_speed":+2.0,"jump_velocity":+2.0, "speed" : +0.25}], ""],
	"fairy_wings" : ["fairy wings", "res://accessories/cape/fairy_wings.tscn", itemType.accessories_cape, [[["res://accessories/cape/fairy_wings.tscn", 0]], {"can_fly":true,"flying_can_hover":true, "flying_speed":+1.0}], ""],
	"debug_cape" : ["devil wings", "res://accessories/cape/debug_cape.tscn", itemType.accessories_cape, [[["res://accessories/cape/debug_cape.tscn", 0]], {"can_fly":true,"flying_speed":+1.0, "speed" : +0.25}], ""],
	"speed_boots" : ["speed boots", "res://accessories/boots/leather_boot_graphics.tscn", itemType.accessories_shoes, [[["res://accessories/boots/leather_boot_graphics.tscn", 2],["res://accessories/boots/leather_boot_graphics.tscn", 4]], {"speed" : +2.0, "speed_multiplier" : +0.5, "defense_footL" : +0.1, "defense_footR" : +0.1}], ""],
	"debug_speed_boot_L" : ["left speedy boot", "res://accessories/boots/leather_boot_graphics.tscn", itemType.accessories_shoes, [[["res://accessories/boots/leather_boot_graphics.tscn", 2]], {"speed" : +0.25, "speed_multiplier" : +0.5, "defense_footL" : +0.1}], "","debug_speed_boots"],
	"debug_speed_boot_R" : ["right speedy boot", "res://accessories/boots/leather_boot_graphics.tscn", itemType.accessories_shoes, [[["res://accessories/boots/leather_boot_graphics.tscn", 4]], {"speed" : +0.25, "speed_multiplier" : +0.5, "defense_footR" : +0.1}], "","debug_speed_boots"],
	
	##armor
	"copper_helmet" : ["copper helmet", "res://assets/itemGraphics/armor/copper/copperHelmet.glb", itemType.accessories_hat, [[["res://assets/itemGraphics/armor/copper/copperHelmet.glb", 5]], {"defense_head" : +0.2, "speed": -0.1}], "res://assets/textures/items/copper helmet tn.png"],
	"rusted_iron_helmet" : ["rusted iron helmet", "res://assets/itemGraphics/armor/rustedIron/rustedIronHelmet.glb", itemType.accessories_hat, [[["res://assets/itemGraphics/armor/rustedIron/rustedIronHelmet.glb", 5]], {"defense_head" : +0.2, "speed": -0.15}], "res://assets/textures/items/rusted iron helmet tn.png"],
	"copper_chestplate" : ["copper chestplate", "res://assets/itemGraphics/armor/copper/CopperChestplate.glb", itemType.accessories_chestplate, [[["res://assets/itemGraphics/armor/copper/CopperChestplate.glb", 0],["res://assets/itemGraphics/armor/copper/CopperPauldronL.glb", 6],["res://assets/itemGraphics/armor/copper/CopperPauldronR.glb", 8]], {"defense_body" : +0.2,"defense_arms" : +0.2, "speed": -0.2}], "res://assets/textures/items/copper chestplate tn.png"],
	
	#rusted copper
	#helmet
	"rusted_copper_helmet" : ["rusted copper helmet", 
	"res://assets/itemGraphics/armor/rustedCopper/rusted_copper_helmet.tscn", 
	itemType.accessories_hat, [[
		["res://assets/itemGraphics/armor/rustedCopper/rusted_copper_helmet.tscn", 5]], 
		{"defense_legs" : +0.1, "speed": -0.2}], 
		""], # no texture yet
	#chestplate
	"rusted_copper_chestplate" : ["rusted copper chestplate", 
	"res://assets/itemGraphics/armor/rustedCopper/rusted_copper_chestplate.tscn", 
	itemType.accessories_chestplate, [[
		["res://assets/itemGraphics/armor/rustedCopper/rusted_copper_chestplate.tscn", 0],
		["res://assets/itemGraphics/armor/rustedCopper/rusted_copper_chestplate_r.tscn", 8],
		["res://assets/itemGraphics/armor/rustedCopper/rusted_copper_chestplate_l.tscn", 6],
		["res://assets/itemGraphics/armor/rustedCopper/rusted_copper_chestplate_arm_2_r.tscn", 9],
		["res://assets/itemGraphics/armor/rustedCopper/rusted_copper_chestplate_arm_2_l.tscn", 7]], 
		{"defense_legs" : +0.1, "speed": -0.2}], 
		""], # no texture yet
	#leggings
	"rusted_copper_leggings" : ["rusted copper leggings", 
	"res://assets/itemGraphics/armor/rustedCopper/rusted_copper_leggings.tscn", 
	itemType.accessories_leggings, [[
		["res://assets/itemGraphics/armor/rustedCopper/rusted_copper_leggings_r.tscn", 1],
		["res://assets/itemGraphics/armor/rustedCopper/rusted_copper_leggings_l.tscn", 3],
		["res://assets/itemGraphics/armor/rustedCopper/rusted_copper_leggings_r_2.tscn", 1],
		["res://assets/itemGraphics/armor/rustedCopper/rusted_copper_leggings_l_2.tscn", 3],
		["res://assets/itemGraphics/armor/rustedCopper/rusted_copper_leggings.tscn", 0]], 
		{"defense_legs" : +0.1, "speed": -0.2}], 
		""], # no texture yet
	#greaves
	"rusted_copper_greaves" : ["rusted copper greaves", 
	"res://assets/itemGraphics/armor/rustedCopper/rusted_copper_leggings.tscn", 
	itemType.accessories_greaves, [[
		["res://assets/itemGraphics/armor/rustedCopper/rusted_copper_greave_l.tscn", 2],
		["res://assets/itemGraphics/armor/rustedCopper/rusted_copper_greave_r.tscn", 4]], 
		{"defense_legs" : +0.1, "speed": -0.2}], 
		""], # no texture yet
	#boots
	"rusted_copper_boot_l" : ["rusted copper left boot", 
	"res://assets/itemGraphics/armor/rustedCopper/rusted_copper_boot_l.tscn", 
	itemType.accessories_shoes, [[
		["res://assets/itemGraphics/armor/rustedCopper/rusted_copper_boot_l.tscn", 2]], 
		{"defense_legs" : +0.1, "speed": -0.2}], 
		""], # no texture yet
	"rusted_copper_boot_r" : ["rusted copper right boot", 
	"res://assets/itemGraphics/armor/rustedCopper/rusted_copper_boot_r.tscn", 
	itemType.accessories_shoes, [[
		["res://assets/itemGraphics/armor/rustedCopper/rusted_copper_boot_r.tscn", 4]], 
		{"defense_legs" : +0.1, "speed": -0.2}], 
		""], # no texture yet
	#gloves
	"rusted_copper_glove_l" : ["rusted copper left glove", 
	"res://assets/itemGraphics/armor/rustedCopper/rusted_copper_glove_l.tscn", 
	itemType.accessories_gloves, [[
		["res://assets/itemGraphics/armor/rustedCopper/rusted_copper_glove_l.tscn", 7]], 
		{"defense_legs" : +0.1, "speed": -0.2}], 
		""], # no texture yet
	"rusted_copper_glove_r" : ["rusted copper right glove", 
	"res://assets/itemGraphics/armor/rustedCopper/rusted_copper_glove_r.tscn", 
	itemType.accessories_gloves, [[
		["res://assets/itemGraphics/armor/rustedCopper/rusted_copper_glove_r.tscn", 9]], 
		{"defense_legs" : +0.1, "speed": -0.2}], 
		""], # no texture yet
	
	
	##debug armor
	#helmet
	"debug_helmet" : ["iron helmet", 
	"res://assets/itemGraphics/armor/iron/iron_helmet.tscn", 
	itemType.accessories_hat, [[
		["res://assets/itemGraphics/armor/iron/iron_helmet.tscn", 5]], 
		{"defense_head" : +0.3, "speed": -0.1}], 
		"res://assets/textures/items/iron helmet tn.png"], # no texture yet
	#chestplate
	"debug_chestplate" : ["iron chestplate", 
	"res://assets/itemGraphics/armor/iron/iron_chestplate.tscn", 
	itemType.accessories_chestplate, [[
		["res://assets/itemGraphics/armor/iron/iron_chestplate.tscn", 0],
		["res://assets/itemGraphics/armor/iron/iron_chestplate_r_1.tscn", 8],
		["res://assets/itemGraphics/armor/iron/iron_chestplate_l_1.tscn", 6],
		["res://assets/itemGraphics/armor/iron/iron_chestplate_r_2.tscn", 9],
		["res://assets/itemGraphics/armor/iron/iron_chestplate_l_2.tscn", 7]], 
		{"defense_legs" : +0.3, "speed": -0.25}], 
		""], # no texture yet
	
	##iron armor
	#helmet
	"iron_helmet" : ["iron helmet", 
	"res://assets/itemGraphics/armor/textured_iron/textured_iron_helmet.tscn", 
	itemType.accessories_hat, [[
		["res://assets/itemGraphics/armor/textured_iron/textured_iron_helmet.tscn", 5]], 
		{"defense_head" : +0.3, "speed": -0.1, "true_defense" : 100.0}], 
		"res://assets/textures/items/iron helmet tn.png"], # no texture yet
	#chestplate
	"iron_chestplate" : ["iron chestplate", 
	"res://assets/itemGraphics/armor/iron/iron_chestplate.tscn", 
	itemType.accessories_chestplate, [[
		["res://assets/itemGraphics/armor/textured_iron/textured_iron_chestplate.tscn", 0],
		["res://assets/itemGraphics/armor/textured_iron/textured_iron_chestplate_r_1.tscn", 8],
		["res://assets/itemGraphics/armor/textured_iron/textured_iron_chestplate_l_1.tscn", 6],
		["res://assets/itemGraphics/armor/textured_iron/textured_iron_chestplate_r_2.tscn", 9],
		["res://assets/itemGraphics/armor/textured_iron/textured_iron_chestplate_l_2.tscn", 7]], 
		{"defense_chest" : +0.3, "speed": -0.25}], 
		""], # no texture yet
	
	
	
	
	
	
	##racial accessories
	"debug_tail" : ["debug tail", "res://accessories/racial/tail_debug.tscn", itemType.racial_changes, [[["res://accessories/racial/tail_debug.tscn", 0]], {"size" = -0.25}], ""],
	
	##weapons
	"iron_sword" : ["iron sword", "res://assets/itemGraphics/iron_sword.tscn", itemType.weapons_sword, [[[damageType.slash, 5.0]],3.0,[[damageType.stab, 2.5]]], "res://assets/textures/items/ironSword.png"],
	"short_bow" : ["short bow", "res://assets/itemGraphics/oak_bow.tscn", itemType.weapons_projectile, ["arrow", "punch"], ""],
	"magic_bow" : ["spark wand", "res://assets/itemGraphics/spark_wand.tscn", itemType.weapons_projectile, ["spark_bolt", "punch"], "res://assets/textures/items/sparkWand.png"],
	"longsword_debug" : ["longsword", "res://assets/itemGraphics/weapons/longsword_standin.tscn", itemType.weapons_longsword, [[[damageType.slash, 7.5]],4.0,[[damageType.stab, 4.0]]], ""],
	"mace_debug" : ["mace", "res://assets/itemGraphics/weapons/longsword_standin.tscn", itemType.weapons_mace, [[[damageType.slash, 7.5]],4.0,[[damageType.stab, 4.0]]], ""],
	"fishing_rod_debug" : ["fishing rod", "res://assets/itemGraphics/weapons/longsword_standin.tscn", itemType.weapons_fishing_rod, [[[damageType.slash, 7.5]],4.0,[[damageType.stab, 4.0]]], ""],
	"bow_debug" : ["bow", "res://assets/itemGraphics/weapons/longsword_standin.tscn", itemType.weapons_bow, [[[damageType.slash, 7.5]],4.0,[[damageType.stab, 4.0]]], ""],
	"spear_debug" : ["spear", "res://assets/itemGraphics/weapons/spear_standin.tscn", itemType.weapons_spear, [[[damageType.slash, 7.5]],4.0,[[damageType.stab, 4.0]]], ""],
	"glaive_debug" : ["glaive", "res://assets/itemGraphics/weapons/longsword_standin.tscn", itemType.weapons_glaive, [[[damageType.slash, 7.5]],4.0,[[damageType.stab, 4.0]]], ""],
	"scythe_debug" : ["scythe", "res://assets/itemGraphics/weapons/longsword_standin.tscn", itemType.weapons_scythe, [[[damageType.slash, 7.5]],4.0,[[damageType.stab, 4.0]]], ""],
	"wand_debug" : ["wand", "res://assets/itemGraphics/weapons/longsword_standin.tscn", itemType.weapons_wand, [[[damageType.slash, 7.5]],4.0,[[damageType.stab, 4.0]]], ""],
	"spellbook_debug" : ["spellbook", "res://assets/itemGraphics/weapons/longsword_standin.tscn", itemType.weapons_spellbook, [[[damageType.slash, 7.5]],4.0,[[damageType.stab, 4.0]]], ""],
	"blood_sythe" : ["crystal scythe", "res://assets/itemGraphics/weapons/scythes/crystal_scythe.tscn", itemType.weapons_scythe, [[[damageType.slash, 7.5]],4.0,[[damageType.stab, 4.0]]], "res://assets/textures/items/deathSythe.png"],
	"old_sword" : ["old sword", "res://assets/itemGraphics/weapons/swords/old_sword.tscn", itemType.weapons_sword, [[[damageType.slash, 2.5]],3.0,[[damageType.stab, 3.0]]], "res://assets/textures/items/oldSword.png"],
	
	#jewelry
	"mana_gen_necklace" : ["arcane necklace", "res://assets/itemGraphics/spark_wand.tscn", itemType.accessories_necklace, [[], {"mana_regen_speed" : +2.5, "max_health": -0.2}], ""], # no texture yet
	"pendant_of_titans" : ["titan pendant", "res://assets/itemGraphics/spark_wand.tscn", itemType.accessories_necklace, [[], {"size" : +0.2, "max_health": +10.0}], ""], # no texture yet
	"ring_of_dragons" : ["ring of dragons", "res://assets/itemGraphics/iron_sword.tscn", itemType.accessories_ring, [[], {"max_health": +5.0, "speed_multiplier" : 0.5}], ""], # no texture yet]
	"grace_pendant" : ["grace pendant", "res://assets/itemGraphics/jewelry/necklaces/grace_pendant.tscn", itemType.accessories_necklace, [[["res://assets/itemGraphics/jewelry/necklaces/grace_pendant.tscn", 0]], {"mana_regen": +2.0, "max_mana" : + 20.0, "blight_defense" : 3.0}], ""],
	"ruby_amulet" : ["ruby amulet", "res://assets/itemGraphics/jewelry/necklaces/ruby_amulet.tscn", itemType.accessories_necklace, [[["res://assets/itemGraphics/jewelry/necklaces/ruby_amulet.tscn", 0]], {"health_regen": +2.0, "max_health" : + 20.0, "true_defense" : 0.05}], ""],
	"arcane_amulet" : ["arcane amulet", "res://assets/itemGraphics/jewelry/necklaces/ruby_amulet.tscn", itemType.accessories_necklace, [[["res://assets/itemGraphics/jewelry/necklaces/ruby_amulet.tscn", 0]], {"arcane_affinity" : 50.0}], ""],
	"chaotic_amulet" : ["chaotic amulet", "res://assets/itemGraphics/jewelry/necklaces/ruby_amulet.tscn", itemType.accessories_necklace, [[["res://assets/itemGraphics/jewelry/necklaces/ruby_amulet.tscn", 0]], {"chaotic_affinity" : 50.0}], ""],
	"divine_amulet" : ["divine amulet", "res://assets/itemGraphics/jewelry/necklaces/ruby_amulet.tscn", itemType.accessories_necklace, [[["res://assets/itemGraphics/jewelry/necklaces/ruby_amulet.tscn", 0]], {"divine_affinity" : 50.0}], ""],
}

const items_lore = {
	"devil_wings" : "sick ass pair of wings",
	"crown_of_god" : "no one was ever meant to have this",
	"blood_sythe" : "yeah",
}

const set_bonus = { #[[item1,item2,item3],{attribute modifiers}, [[model_path,bone_id]]]
	"debug_speed_boots" : [{"shoeL" : "debug_speed_boot_L", "shoeR" : "debug_speed_boot_R"}, {"speed" : +1.5, "speed_multiplier" : +1.0}, []],
	"ring_of_dragons" : [{"ringVowR" : "ring_of_dragons"}, {"can_fly" : true, "size" : 1.0}, []]
}

enum statusEffectType {
	burning,
	poisoned,
	cursed,
	blighted,
	blessed,
	bleeding,
	frozen,
	lofty,
}

const status_effect_names = [
	"burning",
	"poisoned",
	"cursed",
	"blighted",
	"blessed",
	"bleeding",
	"frozen",
	"lofty"
]

enum interact_return_code {
	dont_do_anything, #returns null
	is_item, #returns item_key that should be picked up
	print, #returns a string that should be printed
	is_doorway, #returns [tp_pos, new_rot] that should be traveled to (rot should be added not set)
	is_ladder, #returns [xz_pos, height_min_max,facing_rot]
}

const fire_colors = [Color.ORANGE_RED, Color.AQUA, Color.DARK_RED,Color.SPRING_GREEN,Color.WEB_PURPLE]

const creatures = {
	"young_spider" : "res://entities/youngSpider.tscn",
	"lightning" : "res://entities/lightning_bolt.tscn",
	"debug" : "res://entities/mechanical/debug_creature.tscn",
	"debug_v2" : "res://entities/mechanical/debug_creature_v_2.tscn",
}

const base_player_attributes = {
	##vision
	"dark_vision" : 0.0,
	"ghost_communication" : false,
	##movement
	#ground
	"speed" : 3.0,
	"speed_multiplier" : 1.0,
	"jump_velocity" : 6.0,
	"air_acceleration": 1.0,
	#air
	"can_fly" : false,
	"flying_speed" : 5.0,
	"flying_control" : 1.0,
	"flying_can_glide" : false,
	"flying_can_hover" : false,
	##bars and such
	"max_health" : 10.0,
	"max_mana" : 10.0,
	"max_stamina" : 10.0,
	"mana_regen_speed" : 1.0,
	"stamina_regen_speed": 1.0,
	##damage enhancements
	"strength" : 1.0, #increases physical attacks
	"chaotic_affinity" : 1.0, #increases blight explosion and lightning attacks
	"divine_affinity" : 1.0, #increases holy and fire attacks attacks
	"arcane_affinity" : 1.0, #increases magic ice and toxic attacks (magic ie curses and spells or something)
	"size" : 1.0,
	##defenses
	#localized_generic_defense
	"defense_head" : 1.0,
	"defense_torso" : 1.0,
	"defense_arms" : 1.0,
	"defense_handL" : 1.0,
	"defense_handR" : 1.0,
	"defense_legs" : 1.0,
	"defense_footR" : 1.0,
	"defense_footL" : 1.0,
	#real_defense
	"true_defense" : 1.0, #only changed through race and subclass, effects all damage
	"generic_defense" : 1.0,
	"stab_defense" : 1.0,
	"slash_defense" : 1.0,
	"blunt_defense" : 1.0,
	"fire_defense" : 1.0,
	"ice_defense" : 1.0,
	"toxic_defense" : 1.0,
	"explosion_defense" : 1.0,
	"magic_defense" : 1.0,
	"lightning_defense" : 1.0,
	"holy_defense" : 1.0,
	"blight_defense" : 1.0
	#
}

const max_attributes = {
	##movement
	#ground
	"speed" : 10.0,
	"speed_multiplier" : 3.0,
	"jump_velocity" : 50.0,
	"air_acceleration": 50.0,
	"flying_speed" : 50.0,
	"flying_control" : 50.0,
	"max_health" : 500.0,
	"max_mana" : 500.0,
	"mana_regen_speed" : 100.0,
	"max_stamina" : 500.0,
	"stamina_regen_speed": 100.0,
	"strength" : 100.0,
	"chaotic_affinity" : 100.0,
	"divine_affinity" : 100.0, 
	"arcane_affinity" : 100.0,
	"defense_head" : 100.0,
	"defense_torso" : 100.0,
	"defense_arms" : 100.0,
	"defense_handL" : 100.0,
	"defense_handR" : 100.0,
	"defense_legs" : 100.0,
	"defense_footR" : 100.0,
	"defense_footL" : 100.0,
	"true_defense" : 500.0, #yeah good luck with that >:3c
	"generic_defense" : 100.0,
	"stab_defense" : 100.0,
	"slash_defense" : 100.0,
	"blunt_defense" : 100.0,
	"fire_defense" : 100.0,
	"ice_defense" : 100.0,
	"toxic_defense" : 100.0,
	"explosion_defense" : 100.0,
	"magic_defense" : 100.0,
	"lightning_defense" : 100.0,
	"holy_defense" : 100.0,
	"blight_defense" : 100.0
}

enum enchantments {
	resilience, #improves all defensive attributes by small amounts
	advanced_resiliance, #better resiliance resiliance
	desolation, #applies blight and increases damage attributes decreases defensive effects
	mastery, #improves everything by a little bit
	advanced_mastery, #better mastery
	perfect_mastery, #better better mastery
	weightless, #removes movement debuffs and knockback resistance if applicable #weightlessness?
	density, #increases movment debuffs and knockback resistance if applicable
	swiftness, #increases attack speed and all ground movement speed
	blessing, #increases blight and holy defense
	divine_blessing, #better blessed
	eyes_of_the_dead, #allows you too talk to dead players
}

const enchantment_names = [
	"𐰓𐰏𐰇", #"resilience", #improves all defensive attributes by small amounts
	#"𐰋𐰓𐰜 𐰓𐰏𐰇", #better resiliance
	"𐰑𐰨𐰃𐰍 𐰓𐰏𐰇", #best resiliance
	"𐰪𐰃𐰍", #"desolation", bad/evil, #applies blight and increases damage attributes decreases defensive effects
	"𐰋𐰓𐰜", #big powerful great "mastery", #improves everything by a little bit
	"𐰑𐰨𐰃𐰍 𐰋𐰓𐰜", #better mastery
	"𐰋𐰭𐰏𐰇", #eternal, #"perfect_mastery", #better better mastery
	"𐰚𐰃𐰲𐰏", #small little young, #"weightless", #removes movement debuffs and knockback resistance if applicable #weightlessness?
	"𐰖𐰆𐰍𐰣", # #"𐰍𐰺",# dense thick tough, density", #increases movment debuffs and knockback resistance if applicable
	"𐱆𐰕𐰃𐰐", #"swiftness",
	"𐰃𐰑𐰸", #holy or blessing, adds holy damage or blight defense
	"𐰑𐰨𐰃𐰍 𐰃𐰑𐰸", #better holy
	"dead eyes", #allows ghost_communication
]

const enchantment_colors = [
	Color.ROYAL_BLUE, #improves all defensive attributes by small amounts
	Color.ROYAL_BLUE, #better resilience
	Color.INDIGO, #applies blight and increases damage attributes decreases defensive effects
	Color.CRIMSON, #improves everything by a little bit
	Color.CRIMSON, #better mastery
	Color.CRIMSON, #better better mastery
	Color.AQUAMARINE, #removes movement debuffs and knockback resistance if applicable #weightlessness?
	Color.MIDNIGHT_BLUE, #increases movment debuffs and knockback resistance if applicable
	Color.PALE_TURQUOISE,
	Color.GOLD,
	Color.GOLDENROD,
	Color.WEB_PURPLE,
]

const good_enchantments =[
	enchantments.advanced_resiliance,
	enchantments.advanced_mastery,
	enchantments.weightless
]

const godly_enchantments =[
	enchantments.perfect_mastery,
	enchantments.swiftness
]

const evil_enchantments = [
	enchantments.desolation,
	enchantments.eyes_of_the_dead
]
