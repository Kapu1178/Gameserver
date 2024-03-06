/obj/item/stack/spacecash  //Don't use base space cash stacks. Any other space cash stack can merge with them, and could cause potential money duping exploits.
	name = "space cash"
	singular_name = "bill"
	icon = 'icons/obj/economy.dmi'
	icon_state = null
	amount = 1
	max_amount = INFINITY
	throwforce = 0
	throw_speed = 0.7
	throw_range = 2
	w_class = WEIGHT_CLASS_TINY
	full_w_class = WEIGHT_CLASS_TINY
	resistance_flags = FLAMMABLE
	grind_results = list(/datum/reagent/cellulose = 10)

	/// How much money one "amount" of this is worth. Use get_item_credit_value().
	VAR_PROTECTED/value = 0

/obj/item/stack/spacecash/Initialize(mapload, new_amount, merge = TRUE, list/mat_override=null, mat_amt=1)
	. = ..()
	update_desc()

/obj/item/stack/spacecash/update_desc()
	. = ..()
	var/total_worth = get_item_credit_value()
	desc = "It's worth [total_worth] credit[(total_worth > 1) ? "s" : null] in total."

/obj/item/stack/spacecash/get_item_credit_value()
	return (amount*value)

/obj/item/stack/spacecash/merge(obj/item/stack/S)
	. = ..()
	update_desc()

/obj/item/stack/spacecash/use(used, transfer = FALSE, check = TRUE)
	. = ..()
	update_desc()

/// Like use(), but for financial amounts. use_cash(20) on a stack of 10s will use 2. use_cash(22) on a stack of 10s will use 3.
/obj/item/stack/spacecash/proc/use_cash(value_to_pay)
	var/amt = ceil(value_to_pay / value)
	return use(amt)

/obj/item/stack/spacecash/update_icon_state()
	. = ..()
	switch(amount)
		if(1)
			icon_state = initial(icon_state)
		if(2 to 9)
			icon_state = "[initial(icon_state)]_2"
		if(10 to 24)
			icon_state = "[initial(icon_state)]_3"
		if(25 to INFINITY)
			icon_state = "[initial(icon_state)]_4"

/obj/item/stack/spacecash/c1
	icon_state = "spacecash1"
	singular_name = "one credit bill"
	value = 1
	merge_type = /obj/item/stack/spacecash/c1

/obj/item/stack/spacecash/c10
	icon_state = "spacecash10"
	singular_name = "ten credit bill"
	value = 10
	merge_type = /obj/item/stack/spacecash/c10

/obj/item/stack/spacecash/c20
	icon_state = "spacecash20"
	singular_name = "twenty credit bill"
	value = 20
	merge_type = /obj/item/stack/spacecash/c20

/obj/item/stack/spacecash/c100
	icon_state = "spacecash100"
	singular_name = "one hundred credit bill"
	value = 100
	merge_type = /obj/item/stack/spacecash/c100

/obj/item/stack/spacecash/c1000
	icon_state = "spacecash1000"
	singular_name = "one thousand credit bill"
	value = 1000
	merge_type = /obj/item/stack/spacecash/c1000

/obj/item/stack/spacecash/c10000
	icon_state = "spacecash10000"
	singular_name = "ten thousand credit bill"
	value = 10000
	merge_type = /obj/item/stack/spacecash/c10000
