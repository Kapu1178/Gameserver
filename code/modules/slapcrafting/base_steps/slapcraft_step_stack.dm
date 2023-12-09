/// This step requires an amount of a stack items which will be split off and put into the assembly.
/datum/slapcraft_step/stack
	abstract_type = /datum/slapcraft_step/stack
	insert_item = TRUE
	item_types = list(/obj/item/stack)
	/// Amount of the stack items to be put into the assembly.
	var/amount = 1

/datum/slapcraft_step/stack/can_perform(mob/living/user, obj/item/item)
	var/obj/item/stack/stack = item
	if(stack.amount < amount)
		return FALSE
	return TRUE

/datum/slapcraft_step/stack/move_item_to_assembly(mob/living/user, obj/item/item, obj/item/slapcraft_assembly/assembly)
	var/obj/item/stack/stack = item
	var/obj/item/item_to_move
	// Exactly how much we needed, just put the entirety in the assembly
	if(stack.amount == amount)
		item_to_move = stack
	else
		// We have more than we need, split the stacks off
		var/obj/item/stack/split_stack = stack.split_stack(null, amount)
		item_to_move = split_stack
	item = item_to_move
	return ..()

/datum/slapcraft_step/stack/make_list_desc()
	var/obj/item/stack/stack_cast = item_types[1]
	return "[amount]x [initial(stack_cast.singular_name)]"


/datum/slapcraft_step/stack/rod/one
	desc = "Add a rod to the assembly."
	todo_desc = "You could add a rod..."
	item_types = list(/obj/item/stack/rods)
	amount = 1

	start_msg = "%USER% begins inserts a rod to the %TARGET%."
	start_msg_self = "You begin inserting a rod to the %TARGET%."
	finish_msg = "%USER% inserts a rod to the %TARGET%."
	finish_msg_self = "You insert a rod to the %TARGET%."

/datum/slapcraft_step/stack/cable/one
	desc = "Add a cable to the assembly."
	todo_desc = "You could add a cable..."
	item_types = list(/obj/item/stack/cable_coil)
	amount = 1

	start_msg = "%USER% begins attaching some cable to the %TARGET%."
	start_msg_self = "You begin inserting some cable to the %TARGET%."
	finish_msg = "%USER% attaches some cable to the %TARGET%."
	finish_msg_self = "You attach some cable to the %TARGET%."

/datum/slapcraft_step/stack/cable/fifteen
	desc = "Add 15 cable to the assembly."
	todo_desc = "You could add some cable..."
	item_types = list(/obj/item/stack/cable_coil)
	amount = 15
