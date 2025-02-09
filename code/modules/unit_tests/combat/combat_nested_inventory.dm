/datum/unit_test/nested_inventory
	name = "COMBAT/INTERACTION: Clikc-Dragging Nested Inventory Shall Not Delete Items"

/datum/unit_test/nested_inventory/Run()
	var/mob/living/carbon/human/consistent/user = ALLOCATE_BOTTOM_LEFT()
	var/obj/item/storage/backpack/backpack = ALLOCATE_BOTTOM_LEFT()
	var/obj/item/storage/box/survival/box = ALLOCATE_BOTTOM_LEFT()

	var/datum/client_interface/mock_client = new
	user.mock_client = mock_client
	user.create_mob_hud()

	box.forceMove(backpack)
	user.equip_to_slot_if_possible(backpack, ITEM_SLOT_BACK)

	TEST_ASSERT(user.get_item_by_slot(ITEM_SLOT_BACK) == backpack, "Mob did not equip the backpack.")

	var/obj/item/nested_item = box.contents[1]
	var/atom/movable/screen/inventory/hand/hand_inventory = user.hud_used.hand_slots["[user.active_hand_index]"]

	hand_inventory.MouseDroppedOn(nested_item)

	TEST_ASSERT(!user.is_holding(nested_item), "Mob equipped the item.")
	TEST_ASSERT(!QDELETED(nested_item), "Item was qdeleted.")
	TEST_ASSERT(nested_item.loc == box, "Item ended up outside the box, inside [nested_item.loc || "NULLSPACE"].")
