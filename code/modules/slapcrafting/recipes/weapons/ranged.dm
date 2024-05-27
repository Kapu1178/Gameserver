//Is a flamethrower a gun? I'm still not sure.
/datum/slapcraft_recipe/flamethrower
	name = "Flamethrower"
	examine_hint = "You could craft a flamethrower, starting by attaching an igniter..."
	category = SLAP_CAT_WEAPONS
	steps = list(
		/datum/slapcraft_step/item/welder/base_only,
		/datum/slapcraft_step/item/igniter,
		/datum/slapcraft_step/item/stack/rod/one,
		/datum/slapcraft_step/tool/screwdriver/secure
	)
	result_type = /obj/item/flamethrower

/datum/slapcraft_recipe/pneumatic_cannon
	name = "Pneumatic Cannon"
	category = SLAP_CAT_WEAPONS
	steps = list(
		/datum/slapcraft_step/item/pipe,
		/datum/slapcraft_step/item/stack/rod/two,
		/datum/slapcraft_step/item/pipe/second,
		/datum/slapcraft_step/tool/welder/weld_together
	)
	result_type = /obj/item/pneumatic_cannon/ghetto
