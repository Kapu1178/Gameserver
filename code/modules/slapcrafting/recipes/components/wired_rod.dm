/datum/slapcraft_recipe/wirerod
	name = "Wired Rod"
	examine_hint = "With ten cable, you could attach something to this rod..."
	category = SLAP_CAT_COMPONENTS
	steps = list(
		/datum/slapcraft_step/item/stack/rod/one,
		/datum/slapcraft_step/item/stack/cable/ten
	)
	result_type = /obj/item/wirerod

/datum/slapcraft_recipe/wirerod_dissasemble
	name = "Wired Rod (Disassemble)"
	examine_hint = "You could cut the wire off with wirecutters..."
	category = SLAP_CAT_COMPONENTS
	steps = list(
		/datum/slapcraft_step/item/wirerod,
		/datum/slapcraft_step/tool/wirecutter,
	)
	result_list = list(
		/obj/item/stack/rods,
		/obj/item/stack/cable_coil/ten
	)
