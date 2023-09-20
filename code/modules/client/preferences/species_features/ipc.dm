/datum/preference/choiced/ipc_screen
	explanation = "Screen"
	savefile_key = "ipc_screen"
	savefile_identifier = PREFERENCE_CHARACTER
	relevant_external_organ = /obj/item/organ/ipc_screen

/datum/preference/choiced/ipc_screen/init_possible_values()
	return GLOB.ipc_screens_list

/datum/preference/choiced/ipc_screen/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["ipc_screen"] = value

/datum/preference/choiced/ipc_antenna
	explanation = "Antenna"
	savefile_key = "ipc_antenna"
	savefile_identifier = PREFERENCE_CHARACTER
	relevant_external_organ = /obj/item/organ/ipc_antenna
	sub_preference = /datum/preference/color/mutcolor/ipc_antenna

/datum/preference/choiced/ipc_antenna/init_possible_values()
	return GLOB.ipc_antenna_list

/datum/preference/choiced/ipc_antenna/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["ipc_antenna"] = value

/datum/preference/color/mutcolor/ipc_antenna
	explanation = "Antenna Color"
	savefile_key = "ipc_antenna_color"
	savefile_identifier = PREFERENCE_CHARACTER
	relevant_external_organ = /obj/item/organ/ipc_antenna
	is_sub_preference = TRUE

	color_key = MUTCOLORS_KEY_IPC_ANTENNA

/datum/preference/color/mutcolor/ipc_antenna/create_default_value()
	return "#b4b4b4"

/datum/preference/choiced/ipc_brand
	explanation = "Chassis Brand"
	savefile_key = "ipc_brand"
	savefile_identifier = PREFERENCE_CHARACTER
	relevant_species_trait = BRANDEDPROSTHETICS
	priority = PREFERENCE_PRIORITY_BRANDED_PROSTHETICS

/datum/preference/choiced/ipc_brand/create_default_value()
	return "None"

/// Global list of player-friendly name to iconstate prefix.
GLOBAL_REAL_VAR(ipc_chassis_options) = list(
	"None" = "None",
	"Aether Mk.I" = "bsh",
	"Aether Mk.II" = "bs2",
	"Dionysus" = "hsi",
	"Sentinel" = "sgm",
	"RUST-E" = "xmg",
	"RUST-G" = "xm2",
	"Wayfarer Mk.I" = "wtm",
	"Wayfarer Mk.II" = "mcg",
	"Gamma (Gen 3)" = "zhp",
)

/datum/preference/choiced/ipc_brand/init_possible_values()
	return global.ipc_chassis_options

/datum/preference/choiced/ipc_brand/apply_to_human(mob/living/carbon/human/target, value)
	var/state = global.ipc_chassis_options[value]
	state = state == "None" ? "ipc" : "[state]ipc"
	for(var/obj/item/bodypart/BP as anything in target.bodyparts)
		if(BP.is_stump || IS_ORGANIC_LIMB(BP))
			continue

		BP.change_appearance(id = state, update_owner = FALSE)

	target.dna.species.examine_limb_id = state == "ipc" ? SPECIES_IPC : state
	target.update_body_parts()

