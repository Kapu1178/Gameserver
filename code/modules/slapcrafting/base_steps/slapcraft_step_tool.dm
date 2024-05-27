/// This step requires an item with a specific tool behaviour.
/datum/slapcraft_step/tool
	abstract_type = /datum/slapcraft_step/tool
	insert_item = FALSE
	check_types = FALSE
	check_if_mob_can_drop_item = FALSE

	/// What tool behaviour do we need for this step.
	var/tool_behaviour
	/// How much fuel is required, only relevant for welding tools.
	var/required_fuel = 0

/datum/slapcraft_step/tool/can_perform(mob/living/user, obj/item/item, obj/item/slapcraft_assembly/assembly, list/error_list = list())
	. = ..()

	if(item.tool_behaviour != tool_behaviour)
		. = FALSE

	if(!item.tool_use_check(user, required_fuel))
		. = FALSE

/datum/slapcraft_step/tool/perform_do_after(mob/living/user, obj/item/item, obj/item/slapcraft_assembly/assembly, time_to_do)
	// This will play the tool sound aswell. Rackety
	if(!item.use_tool(assembly, user, time_to_do, volume = 50))
		return FALSE
	return TRUE

// Only relevant for welding tools I believe.
/datum/slapcraft_step/tool/on_perform(mob/living/user, obj/item/item, obj/item/slapcraft_assembly/assembly)
	item?.use(required_fuel)

/datum/slapcraft_step/tool/crowbar
	list_desc = "crowbar"
	tool_behaviour = TOOL_CROWBAR

/datum/slapcraft_step/tool/multitool
	list_desc = "multitool"
	tool_behaviour = TOOL_MULTITOOL

/datum/slapcraft_step/tool/screwdriver
	list_desc = "screwdriver"
	tool_behaviour = TOOL_SCREWDRIVER

/datum/slapcraft_step/tool/screwdriver/secure
	desc = "Secure the parts with a screwdriver."
	todo_desc = "You could secure the parts with a screwdriver..."

	start_msg = "%USER% begins to secure the %TARGET%."
	start_msg_self = "You begin to secure the %TARGET%."
	finish_msg = "%USER% secures the %TARGET%."
	finish_msg_self = "You secure the %TARGET%."

/datum/slapcraft_step/tool/wirecutter
	list_desc = "wirecutter"
	tool_behaviour = TOOL_WIRECUTTER

/datum/slapcraft_step/tool/wrench
	list_desc = "wrench"
	tool_behaviour = TOOL_WRENCH

/datum/slapcraft_step/tool/welder
	list_desc = "welding tool"
	tool_behaviour = TOOL_WELDER
	required_fuel = 2

/datum/slapcraft_step/tool/welder/weld_together
	desc = "Weld the assembly together."
	todo_desc = "You need to weld the assembly together..."
	required_fuel = 3
	perform_time = 4 //this is intended to be a "finishing" step

	start_msg = "%USER% begins to secure the %TARGET%."
	start_msg_self = "You begin to secure the %TARGET%."
	finish_msg = "%USER% secures the %TARGET%."
	finish_msg_self = "You secure the %TARGET%."

/datum/slapcraft_step/tool/saw
	list_desc = "saw"
	tool_behaviour = TOOL_SAW

/datum/slapcraft_step/tool/drill
	list_desc = "drill"
	tool_behaviour = TOOL_DRILL

/datum/slapcraft_step/tool/knife
	list_desc = "knife"
	tool_behaviour = TOOL_KNIFE

/datum/slapcraft_step/tool/rolling_pin
	list_desc = "rolling pin"
	tool_behaviour = TOOL_ROLLINGPIN
