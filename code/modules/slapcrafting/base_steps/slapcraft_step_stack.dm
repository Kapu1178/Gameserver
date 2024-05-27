/// This step requires an amount of a stack items which will be split off and put into the assembly.
/datum/slapcraft_step/item/stack
	abstract_type = /datum/slapcraft_step/item/stack
	insert_item = TRUE
	item_types = list(/obj/item/stack)
	/// Amount of the stack items to be put into the assembly.
	var/amount = 1

/datum/slapcraft_step/item/stack/can_perform(mob/living/user, obj/item/item, obj/item/slapcraft_assembly/assembly, list/error_list = list())
	. = ..()

	var/obj/item/stack/stack = item
	if(istype(stack) && stack.amount < amount)
		if(item.gender == PLURAL) //this looks really funny if you dont know byond
			error_list += "There are not enough [initial(item.name)] (need [amount])."
		else
			error_list += "There is not enough [initial(item.name)] (need [amount])."
		. = FALSE

/datum/slapcraft_step/item/stack/move_item_to_assembly(mob/living/user, obj/item/item, obj/item/slapcraft_assembly/assembly)
	var/obj/item/stack/stack = item
	if(!istype(stack)) // Children of this type may not actually pass stacks
		return ..()

	var/obj/item/item_to_move
	// Exactly how much we needed, just put the entirety in the assembly
	if(stack.amount == amount)
		item_to_move = stack
	else
		// We have more than we need, split the stacks off
		var/obj/item/stack/split_stack = stack.split_stack(null, amount, null)
		item_to_move = split_stack
	item = item_to_move
	return ..()

/datum/slapcraft_step/item/stack/make_list_desc()
	var/obj/item/stack/stack_cast = item_types[1]
	if(istype(stack_cast))
		return "[amount]x [initial(stack_cast.singular_name)]"
	return ..()

/// Can be a stack, another stack, or another item.
/datum/slapcraft_step/item/stack/or_other
	abstract_type = /datum/slapcraft_step/item/stack/or_other
	/// An associative list of stack_type : amount.
	var/list/amounts
	// Do not set this on or_other, its set dynamically!
	amount = 0

/datum/slapcraft_step/item/stack/or_other/New()
	. = ..()
	for(var/path in amounts)
		var/required_amt = amounts[path]
		var/list/path_tree = subtypesof(path)
		for(var/child in path_tree)
			path_tree[child] = required_amt

		amounts += path_tree

/datum/slapcraft_step/item/stack/or_other/can_perform(mob/living/user, obj/item/item, obj/item/slapcraft_assembly/assembly, list/error_list = list())
	. = ..()

	if(isstack(item))
		var/obj/item/stack/S = item
		if(S.amount < amounts[S.type])
			error_list += "There are not enough [initial(item.name)] (need [amounts[S.type]])."
			. = FALSE

/datum/slapcraft_step/item/stack/or_other/move_item_to_assembly(mob/living/user, obj/item/item, obj/item/slapcraft_assembly/assembly)
	amount = amounts[item.type]
	. = ..()
	amount = 0

/datum/slapcraft_step/item/stack/or_other/binding
	desc = "Tie the assembly together."
	todo_desc = "You could use something to tie this the assembly together..."
	item_types = list(
		/obj/item/stack/sticky_tape,
		/obj/item/stack/cable_coil,
		/obj/item/stack/sheet/cloth
	)
	amounts = list(
		/obj/item/stack/sticky_tape = 2,
		/obj/item/stack/sheet/cloth = 1,
		/obj/item/stack/cable_coil = 10,
	)


/datum/slapcraft_step/item/stack/rod/one
	desc = "Add a rod to the assembly."
	todo_desc = "You could add a rod..."
	item_types = list(/obj/item/stack/rods)
	amount = 1

	start_msg = "%USER% begins inserts a rod to the %TARGET%."
	start_msg_self = "You begin inserting a rod to the %TARGET%."
	finish_msg = "%USER% inserts a rod to the %TARGET%."
	finish_msg_self = "You insert a rod to the %TARGET%."

/datum/slapcraft_step/item/stack/rod/two
	desc = "Add two rods to the assembly."
	todo_desc = "You could add some rods..."
	item_types = list(/obj/item/stack/rods)
	amount = 2

	start_msg = "%USER% adds some rods to the %TARGET%."
	start_msg_self = "You add some rods to the %TARGET%."
	finish_msg = "%USER% adds some rods to the %TARGET%."
	finish_msg_self = "You add some rods to the %TARGET%."

/datum/slapcraft_step/item/stack/iron/one
	desc = "Add a sheet of metal to the assembly."
	todo_desc = "You could add a sheet of metal..."
	item_types = list(/obj/item/stack/sheet/iron)
	amount = 1

	start_msg = "%USER% begins adds a sheet of metal to the %TARGET%."
	start_msg_self = "You begin adds a sheet of metal to the %TARGET%."
	finish_msg = "%USER% adds a sheet of metal to the %TARGET%."
	finish_msg_self = "You adds a sheet of metal to the %TARGET%."

/datum/slapcraft_step/item/stack/iron/five
	desc = "Add 5 sheets of metal to the assembly."
	todo_desc = "You could add some metal sheets..."
	item_types = list(/obj/item/stack/sheet/iron)
	amount = 5

	start_msg = "%USER% starts adding some metal to the %TARGET%."
	start_msg_self = "You begin adds some metal to the %TARGET%."
	finish_msg = "%USER% adds some metal to the %TARGET%."
	finish_msg_self = "You add some metal to the %TARGET%."

/datum/slapcraft_step/item/stack/cable/one
	desc = "Add a cable to the assembly."
	todo_desc = "You could add a cable..."
	item_types = list(/obj/item/stack/cable_coil)
	amount = 1

	start_msg = "%USER% begins attaching some cable to the %TARGET%."
	start_msg_self = "You begin inserting some cable to the %TARGET%."
	finish_msg = "%USER% attaches some cable to the %TARGET%."
	finish_msg_self = "You attach some cable to the %TARGET%."

/datum/slapcraft_step/item/stack/cable/five
	desc = "Add 5 cable to the assembly."
	todo_desc = "You could add some cable..."
	item_types = list(/obj/item/stack/cable_coil)
	amount = 5

	start_msg = "%USER% begins attaching some cable to the %TARGET%."
	start_msg_self = "You begin inserting some cable to the %TARGET%."
	finish_msg = "%USER% attaches some cable to the %TARGET%."
	finish_msg_self = "You attach some cable to the %TARGET%."

/datum/slapcraft_step/item/stack/cable/ten
	desc = "Add 10 cable to the assembly."
	item_types = list(/obj/item/stack/cable_coil)
	amount = 10

	start_msg = "%USER% begins attaching some cable to the %TARGET%."
	start_msg_self = "You begin inserting some cable to the %TARGET%."
	finish_msg = "%USER% attaches some cable to the %TARGET%."
	finish_msg_self = "You attach some cable to the %TARGET%."

/datum/slapcraft_step/item/stack/cable/fifteen
	desc = "Add 15 cable to the assembly."
	item_types = list(/obj/item/stack/cable_coil)
	amount = 15

	start_msg = "%USER% begins attaching some cable to the %TARGET%."
	start_msg_self = "You begin inserting some cable to the %TARGET%."
	finish_msg = "%USER% attaches some cable to the %TARGET%."
	finish_msg_self = "You attach some cable to the %TARGET%."

/datum/slapcraft_step/item/stack/cardboard/one
	desc = "Add a sheet of cardboard to the assembly."
	todo_desc = "You could add a sheet of cardboard..."
	item_types = list(/obj/item/stack/sheet/cardboard)
	amount = 1
	perform_time = 0

	finish_msg = "%USER% adds a sheet of cardboard to the %TARGET%."
	finish_msg_self = "You add a sheet of cardboard to the %TARGET%."

/datum/slapcraft_step/item/stack/wood/one
	desc = "Add a plank of wood to the assembly."
	todo_desc = "You could add a plank of wood..."
	item_types = list(/obj/item/stack/sheet/mineral/wood)
	amount = 1

	start_msg = "%USER% begins attaching a wooden plank to the %TARGET%."
	start_msg_self = "You begin attaching a wooden plank  to the %TARGET%."
	finish_msg = "%USER% attaches a wooden plank to the %TARGET%."
	finish_msg_self = "You attach a wooden plank to the %TARGET%."
