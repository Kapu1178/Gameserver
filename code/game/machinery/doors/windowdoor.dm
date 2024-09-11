/obj/machinery/door/window
	name = "interior door"
	desc = "A strong door."
	icon = 'icons/obj/doors/windoor.dmi'
	icon_state = "left"
	layer = ABOVE_WINDOW_LAYER
	closingLayer = ABOVE_WINDOW_LAYER
	resistance_flags = ACID_PROOF
	var/base_state = "left"
	max_integrity = 150 //If you change this, consider changing ../door/window/brigdoor/ max_integrity at the bottom of this .dm file
	integrity_failure = 0
	armor = list(BLUNT = 20, PUNCTURE = 50, SLASH = 90, LASER = 50, ENERGY = 50, BOMB = 10, BIO = 100, FIRE = 70, ACID = 100)
	visible = FALSE
	flags_1 = ON_BORDER_1
	opacity = FALSE
	pass_flags_self = PASSGLASS
	can_atmos_pass = CANPASS_PROC
	interaction_flags_machine = INTERACT_MACHINE_WIRES_IF_OPEN | INTERACT_MACHINE_ALLOW_SILICON | INTERACT_MACHINE_OPEN_SILICON | INTERACT_MACHINE_REQUIRES_SILICON | INTERACT_MACHINE_OPEN
	set_dir_on_move = FALSE
	auto_dir_align = FALSE

	var/obj/item/electronics/airlock/electronics = null
	var/reinf = 0
	var/shards = 2
	var/rods = 2
	var/cable = 1

/obj/machinery/door/window/Initialize(mapload, set_dir, unres_sides)
	. = ..()
	flags_1 &= ~PREVENT_CLICK_UNDER_1
	if(set_dir)
		setDir(set_dir)
	if(LAZYLEN(req_access))
		icon_state = "[icon_state]"
		base_state = icon_state

	if(unres_sides)
		//remove unres_sides from directions it can't be bumped from
		switch(dir)
			if(NORTH,SOUTH)
				unres_sides &= ~EAST
				unres_sides &= ~WEST
			if(EAST,WEST)
				unres_sides &= ~NORTH
				unres_sides &= ~SOUTH

	src.unres_sides = unres_sides
	update_appearance(UPDATE_ICON)

	var/static/list/loc_connections = list(
		COMSIG_ATOM_EXIT = PROC_REF(on_exit),
	)

	AddElement(/datum/element/connect_loc, loc_connections)

	zas_update_loc()
	become_atmos_sensitive()

/obj/machinery/door/window/Destroy()
	set_density(FALSE)
	if(atom_integrity == 0)
		playsound(src, SFX_SHATTER, 70, TRUE)
	electronics = null
	lose_atmos_sensitivity()
	return ..()

/obj/machinery/door/window/update_icon_state()
	. = ..()
	icon_state = "[base_state][density ? null : "open"]"

	if(hasPower() && unres_sides)
		set_light(l_outer_range = 2, l_power = 1)
		return

	set_light(l_outer_range = 0)

/obj/machinery/door/window/update_overlays()
	. = ..()

	if(!hasPower() || !unres_sides)
		return

	switch(dir)
		if(NORTH,SOUTH)
			if(unres_sides & NORTH)
				var/image/side_overlay = image(icon='icons/obj/doors/airlocks/station/overlays.dmi', icon_state="unres_n")
				side_overlay.pixel_y = dir == NORTH ? 31 : 6
				. += side_overlay
			if(unres_sides & SOUTH)
				var/image/side_overlay = image(icon='icons/obj/doors/airlocks/station/overlays.dmi', icon_state="unres_s")
				side_overlay.pixel_y = dir == NORTH ? -6 : -31
				. += side_overlay
		if(EAST,WEST)
			if(unres_sides & EAST)
				var/image/side_overlay = image(icon='icons/obj/doors/airlocks/station/overlays.dmi', icon_state="unres_e")
				side_overlay.pixel_x = dir == EAST ? 31 : 6
				. += side_overlay
			if(unres_sides & WEST)
				var/image/side_overlay = image(icon='icons/obj/doors/airlocks/station/overlays.dmi', icon_state="unres_w")
				side_overlay.pixel_x = dir == EAST ? -6 : -31
				. += side_overlay

/obj/machinery/door/window/proc/open_and_close()
	if(!open())
		return
	autoclose = TRUE
	if(check_access(null))
		sleep(50)
	else //secure doors close faster
		sleep(20)
	if(!density && autoclose) //did someone change state while we slept?
		close()

/obj/machinery/door/window/BumpedBy(atom/movable/AM)
	if(operating || !density)
		return
	if(!ismob(AM))
		if(ismecha(AM))
			var/obj/vehicle/sealed/mecha/mecha = AM
			for(var/O in mecha.occupants)
				var/mob/living/occupant = O
				if(allowed(occupant))
					open_and_close()
					return
			do_animate("deny")
		return
	if(!SSticker)
		return
	var/mob/M = AM
	if(HAS_TRAIT(M, TRAIT_HANDS_BLOCKED) || ((isdrone(M) || iscyborg(M)) && M.stat != CONSCIOUS))
		return
	bumpopen(M)

/obj/machinery/door/window/bumpopen(mob/user)
	if(operating || !density)
		return
	add_fingerprint(user)
	if(!requiresID())
		user = null

	if(allowed(user))
		open_and_close()
	else
		do_animate("deny")
	return

/obj/machinery/door/window/CanAllowThrough(atom/movable/mover, border_dir)
	. = ..()
	if(.)
		return

	if(border_dir == dir)
		return FALSE

	if(istype(mover, /obj/structure/window))
		var/obj/structure/window/moved_window = mover
		return valid_window_location(loc, moved_window.dir, is_fulltile = moved_window.fulltile)

	if(istype(mover, /obj/structure/windoor_assembly) || istype(mover, /obj/machinery/door/window))
		return valid_window_location(loc, mover.dir, is_fulltile = FALSE)

	return TRUE

/obj/machinery/door/window/zas_canpass(turf/T)
	if(QDELETED(src))
		return AIR_ALLOWED
	if(get_dir(loc, T) == dir)
		return density ? (AIR_BLOCKED|ZONE_BLOCKED) : ZONE_BLOCKED
	else
		return ZONE_BLOCKED

//used in the AStar algorithm to determinate if the turf the door is on is passable
/obj/machinery/door/window/CanAStarPass(to_dir, datum/can_pass_info/pass_info)
	return !density || (dir != to_dir) || (check_access_list(pass_info.access) && hasPower() && !pass_info.no_id)

/obj/machinery/door/window/proc/on_exit(datum/source, atom/movable/leaving, direction)
	SIGNAL_HANDLER
	if(leaving.movement_type & PHASING)
		return

	if(leaving == src)
		return // Let's not block ourselves.

	if((pass_flags_self & leaving.pass_flags) || ((pass_flags_self & LETPASSTHROW) && leaving.throwing))
		return

	if(direction == dir && density)
		leaving.Bump(src)
		return COMPONENT_ATOM_BLOCK_EXIT

/obj/machinery/door/window/open(forced=FALSE)
	if (operating) //doors can still open when emag-disabled
		return 0
	if(!forced)
		if(!hasPower())
			return 0
	if(forced < 2)
		if(obj_flags & EMAGGED)
			return 0
	if(!operating) //in case of emag
		operating = TRUE
	do_animate("opening")
	playsound(src, 'sound/machines/windowdoor.ogg', 100, TRUE)
	icon_state ="[base_state]open"
	sleep(10)
	set_density(FALSE)
	update_appearance(UPDATE_ICON_STATE)
	update_freelook_sight()

	if(operating == 1) //emag again
		operating = FALSE
	return 1

/obj/machinery/door/window/close(forced=FALSE)
	if (operating)
		return 0
	if(!forced)
		if(!hasPower())
			return 0
	if(forced < 2)
		if(obj_flags & EMAGGED)
			return 0
	operating = TRUE
	do_animate("closing")
	playsound(src, 'sound/machines/windowdoor.ogg', 100, TRUE)
	icon_state = base_state

	set_density(TRUE)
	update_appearance(UPDATE_ICON_STATE)
	update_freelook_sight()
	sleep(10)

	operating = FALSE
	return 1

/obj/machinery/door/window/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			playsound(src, 'sound/effects/glasshit.ogg', 90, TRUE)
		if(BURN)
			playsound(src, 'sound/items/welder.ogg', 100, TRUE)


/obj/machinery/door/window/deconstruct(disassembled = TRUE)
	if(!(flags_1 & NODECONSTRUCT_1) && !disassembled)
		for(var/i in 1 to shards)
			drop_debris(new /obj/item/shard(src))
		if(rods)
			drop_debris(new /obj/item/stack/rods(src, rods))
		if(cable)
			drop_debris(new /obj/item/stack/cable_coil(src, cable))
	qdel(src)

/obj/machinery/door/window/proc/drop_debris(obj/item/debris)
	debris.forceMove(loc)
	transfer_fingerprints_to(debris)

/obj/machinery/door/window/narsie_act()
	add_atom_colour("#7D1919", FIXED_COLOUR_PRIORITY)

/obj/machinery/door/window/atmos_expose(datum/gas_mixture/air, exposed_temperature)
	if((exposed_temperature > T0C + (reinf ? 1600 : 800)))
		take_damage(round(exposed_temperature / 200), BURN, 0, 0)

/obj/machinery/door/window/fire_act(exposed_temperature, exposed_volume)
	take_damage(round(exposed_temperature / 200), BURN, 0, 0)

/obj/structure/window/take_damage(damage_amount, damage_type = BRUTE, damage_flag = 0, sound_effect = 1)
	var/initial_damage_percentage = get_integrity_percentage()
	. = ..()
	if(.) //received damage
		if(atom_integrity > 0)
			playsound(src, get_sfx(SFX_GLASS_CRACK), 100, TRUE)
			var/damage_percentage = get_integrity_percentage()
			if (damage_percentage >= 75 && initial_damage_percentage < 75)
				visible_message(span_warning("\The [src] looks like it's about to shatter!"))
				playsound(loc, get_sfx(SFX_GLASS_CRACK), 100, 1)
			else if (damage_percentage >= 50 && initial_damage_percentage < 50)
				visible_message(span_warning("\The [src] looks seriously damaged!"))
				playsound(loc, get_sfx(SFX_GLASS_CRACK), 100, 1)
			else if (damage_percentage >= 25 && initial_damage_percentage < 25)
				visible_message(span_warning("Cracks begin to appear in \the [src]!"))
				playsound(loc, get_sfx(SFX_GLASS_CRACK), 100, 1)

/obj/machinery/door/window/emag_act(mob/user)
	if(!operating && density && !(obj_flags & EMAGGED))
		obj_flags |= EMAGGED
		operating = TRUE
		z_flick("[base_state]spark", src)
		playsound(src, SFX_SPARKS, 75, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
		sleep(6)
		operating = FALSE
		desc += "<BR>[span_warning("Its access panel is smoking slightly.")]"
		open(2)

/obj/machinery/door/window/screwdriver_act(mob/living/user, obj/item/tool)
	. = ..()
	if(flags_1 & NODECONSTRUCT_1)
		return
	if(density || operating)
		to_chat(user, span_warning("You need to open the door to access the maintenance panel!"))
		return
	tool.leave_evidence(user, src)
	tool.play_tool_sound(src)
	panel_open = !panel_open
	to_chat(user, span_notice("You [panel_open ? "open" : "close"] the maintenance panel."))
	return TRUE

/obj/machinery/door/window/crowbar_act(mob/living/user, obj/item/tool)
	. = ..()
	if(flags_1 & NODECONSTRUCT_1)
		return
	if(!panel_open || density || operating)
		return
	tool.leave_evidence(user, src)
	user.visible_message(span_notice("[user] removes the electronics from the [name]."), \
	span_notice("You start to remove electronics from the [name]..."))
	if(!tool.use_tool(src, user, 40, volume=50))
		return
	if(!panel_open || density || operating || !loc)
		return
	var/obj/structure/windoor_assembly/windoor_assembly = new /obj/structure/windoor_assembly(loc)
	switch(base_state)
		if("left")
			windoor_assembly.facing = "l"
		if("right")
			windoor_assembly.facing = "r"
		if("leftsecure")
			windoor_assembly.facing = "l"
			windoor_assembly.secure = TRUE
		if("rightsecure")
			windoor_assembly.facing = "r"
			windoor_assembly.secure = TRUE
	windoor_assembly.set_anchored(TRUE)
	windoor_assembly.state= "02"
	windoor_assembly.setDir(dir)
	windoor_assembly.update_appearance()
	windoor_assembly.created_name = name
	if(obj_flags & EMAGGED)
		to_chat(user, span_warning("You discard the damaged electronics."))
		qdel(src)
		return
	to_chat(user, span_notice("You remove the airlock electronics."))
	var/obj/item/electronics/airlock/dropped_electronics
	if(!electronics)
		dropped_electronics = new/obj/item/electronics/airlock(drop_location())
		if(req_one_access)
			dropped_electronics.one_access = 1
			dropped_electronics.accesses = req_one_access
		else
			dropped_electronics.accesses = req_access
	else
		dropped_electronics = electronics
		electronics = null
		dropped_electronics.forceMove(drop_location())
	qdel(src)
	return TRUE

/obj/machinery/door/window/interact(mob/user) //for sillycones
	try_to_activate_door(user)

/obj/machinery/door/window/try_to_activate_door(mob/user, access_bypass = FALSE, obj/item/attackedby)
	if (..())
		autoclose = FALSE

/obj/machinery/door/window/unrestricted_side(mob/opener)
	if(get_turf(opener) == loc)
		return turn(dir,180) & unres_sides
	return ..()

/obj/machinery/door/window/try_to_crowbar(obj/item/I, mob/user)
	if(!hasPower())
		if(density)
			open(2)
		else
			close(2)
	else
		to_chat(user, span_warning("The door's motors resist your efforts to force it!"))

/obj/machinery/door/window/do_animate(animation)
	switch(animation)
		if("opening")
			z_flick("[base_state]opening", src)
		if("closing")
			z_flick("[base_state]closing", src)
		if("deny")
			z_flick("[base_state]deny", src)

/obj/machinery/door/window/rcd_vals(mob/user, obj/item/construction/rcd/the_rcd)
	switch(the_rcd.mode)
		if(RCD_DECONSTRUCT)
			return list("mode" = RCD_DECONSTRUCT, "delay" = 50, "cost" = 32)
	return FALSE

/obj/machinery/door/window/rcd_act(mob/user, obj/item/construction/rcd/the_rcd, passed_mode)
	switch(passed_mode)
		if(RCD_DECONSTRUCT)
			to_chat(user, span_notice("You deconstruct the windoor."))
			qdel(src)
			return TRUE
	return FALSE


/obj/machinery/door/window/brigdoor
	name = "secure door"
	icon_state = "leftsecure"
	base_state = "leftsecure"
	var/id = null
	max_integrity = 300 //Stronger doors for prison (regular window door health is 200)
	reinf = 1
	explosion_block = 1

/obj/machinery/door/window/brigdoor/security/cell
	name = "cell door"
	desc = "For keeping in criminal scum."
	req_access = list(ACCESS_BRIG)

/obj/machinery/door/window/brigdoor/security/holding
	name = "holding cell door"
	req_one_access = list(ACCESS_BRIG_ENTRANCE) //lawyer also gets brig_entrance

MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/door/window/left, 0)
MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/door/window/right, 0)

/obj/machinery/door/window/right
	icon_state = "right"
	base_state = "right"

MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/door/window/brigdoor/left, 0)
MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/door/window/brigdoor/right, 0)

/obj/machinery/door/window/brigdoor/right
	icon_state = "rightsecure"
	base_state = "rightsecure"

MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/door/window/brigdoor/security/cell/left, 0)
MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/door/window/brigdoor/security/cell/right, 0)

/obj/machinery/door/window/brigdoor/security/cell/right
	icon_state = "rightsecure"
	base_state = "rightsecure"

MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/door/window/brigdoor/security/holding/left, 0)
MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/door/window/brigdoor/security/holding/right, 0)

/obj/machinery/door/window/brigdoor/security/holding/right
	icon_state = "rightsecure"
	base_state = "rightsecure"
