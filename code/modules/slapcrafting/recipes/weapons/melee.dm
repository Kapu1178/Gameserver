//Spears
/datum/slapcraft_recipe/spear
	name = "makeshift spear"
	examine_hint = "You could attach a shard of glass to make a crude spear..."
	category = SLAP_CAT_WEAPONS
	steps = list(
		/datum/slapcraft_step/item/wirerod,
		/datum/slapcraft_step/item/glass_shard/insert //this is for different glass types
	)
	result_type = /obj/item/spear

/datum/slapcraft_recipe/explosive_lance
	name = "explosive lance"
	examine_hint = "You could attach a grenade, though that might be a bad idea..."
	category = SLAP_CAT_WEAPONS
	steps = list(
		/datum/slapcraft_step/spear,
		/datum/slapcraft_step/item/grenade,
		/datum/slapcraft_step/stack/or_other/binding
	)
	result_type = /obj/item/spear/explosive

/datum/slapcraft_step/spear
	desc = "Start with a spear."
	item_types = list(/obj/item/spear)

/datum/slapcraft_recipe/explosive_lance/create_product(product_path, obj/item/slapcraft_assembly/assembly)
	var/obj/item/spear/explosive/spear = ..()
	var/obj/item/grenade/G = locate() in assembly
	spear.set_explosive(G)
	return spear


//Stunprods
/datum/slapcraft_recipe/stunprod
	name = "stunprod"
	examine_hint = "You could attach an igniter to use as a stunprod..."
	category = SLAP_CAT_WEAPONS
	steps = list(
		/datum/slapcraft_step/item/wirerod,
		/datum/slapcraft_step/item/igniter
	)
	result_type = /obj/item/melee/baton/security/cattleprod

/datum/slapcraft_recipe/teleprod
	name = "teleprod"
	examine_hint = "A bluespace crystal could fit in the igniter..."
	category = SLAP_CAT_WEAPONS
	steps = list(
		/datum/slapcraft_step/item/cattleprod,
		/datum/slapcraft_step/stack/teleprod_crystal
	)
	result_type = /obj/item/melee/baton/security/cattleprod/teleprod

/datum/slapcraft_step/item/cattleprod
	desc = "Start with a stunprod."
	item_types = list(/obj/item/melee/baton/security/cattleprod)

/datum/slapcraft_step/stack/teleprod_crystal
	desc = "Attach a bluespace crystal to the igniter."
	item_types = list(/obj/item/stack/ore/bluespace_crystal)


//shivs
/datum/slapcraft_recipe/glass_shiv
	name = "glass shiv"
	examine_hint = "With some cloth or tape wrapped around the base, this could work as a shiv..."
	category = SLAP_CAT_WEAPONS
	steps = list(
		/datum/slapcraft_step/item/glass_shard/insert, //this is for different glass types
		/datum/slapcraft_step/stack/or_other/shiv_wrap

	)
	result_type = /obj/item/knife/shiv

/datum/slapcraft_step/stack/or_other/shiv_wrap
	desc = "Wrap some cloth or tape around the base."
	todo_desc = "You could use some cloth or tape to hold the shard without cutting your hand..."
	item_types = list(
		/obj/item/stack/sticky_tape,
		/obj/item/stack/sheet/cloth
	)
	amounts = list(
		/obj/item/stack/sticky_tape = 3,
		/obj/item/stack/sheet/cloth = 1,
	)

//misc. weapons
/datum/slapcraft_recipe/mace
	name = "iron mace"
	examine_hint = "You could attach a metal ball to make a crude mace..."
	category = SLAP_CAT_WEAPONS
	steps = list(
		/datum/slapcraft_step/stack/rod/one,
		/datum/slapcraft_step/item/metal_ball,
		/datum/slapcraft_step/tool/welder/weld_together
	)
	result_type = /obj/item/mace
