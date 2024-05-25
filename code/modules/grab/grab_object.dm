/obj/item/hand_item/grab
	name = "grab"
	item_flags = DROPDEL | ABSTRACT | HAND_ITEM | NOBLUDGEON

	/// The initiator of the grab
	var/mob/living/assailant = null
	/// The thing being grabbed
	var/atom/movable/affecting = null

	/// The grab datum currently being used
	var/datum/grab/current_grab

	/// Cooldown for actions
	COOLDOWN_DECLARE(action_cd)
	/// Cooldown for upgrade times
	COOLDOWN_DECLARE(upgrade_cd)
	/// Indicates if the current grab has special interactions applied to the target organ (eyes and mouth at time of writing)
	var/special_target_functional = TRUE
	/// Used to avoid stacking interactions that sleep during /decl/grab/proc/on_hit_foo() (ie. do_after() is used)
	var/is_currently_resolving_hit = FALSE
	/// Records a specific bodypart that was targetted by this grab.
	var/target_zone
	/// Used by struggle grab datum to keep track of state.
	var/done_struggle = FALSE

/obj/item/hand_item/grab/Initialize(mapload, atom/movable/target, datum/grab/grab_type, use_offhand)
	. = ..()
	current_grab = GLOB.all_grabstates[grab_type]
	if(isnull(current_grab))
		stack_trace("Bad grab type requested: [grab_type || "NULL"]")
		return INITIALIZE_HINT_QDEL

	assailant = loc
	if(!istype(assailant))
		assailant = null
		return INITIALIZE_HINT_QDEL

	affecting = target
	if(!istype(assailant) || !assailant.add_grab(src, use_offhand = use_offhand))
		return INITIALIZE_HINT_QDEL

	target_zone = deprecise_zone(assailant.zone_selected)

	if(!current_grab.setup(src))
		return INITIALIZE_HINT_QDEL

	/// Apply any needed updates to the assailant
	LAZYADD(affecting.grabbed_by, src) // This is how we handle affecting being deleted.
	LAZYOR(assailant.active_grabs, src)

	assailant.update_pull_hud_icon()

	/// Do flavor things like pixel offsets, animation, sound
	adjust_position()
	assailant.animate_interact(affecting, INTERACT_GRAB)

	var/sound = 'sound/weapons/thudswoosh.ogg'
	if(iscarbon(assailant))
		var/mob/living/carbon/C = assailant
		if(C.dna.species.grab_sound)
			sound = C.dna.species.grab_sound

	playsound(affecting.loc, sound, 50, 1, -1)

	/// Spread diseases
	if(isliving(affecting))
		var/mob/living/affecting_mob = affecting
		for(var/datum/disease/D as anything in assailant.diseases)
			if(D.spread_flags & DISEASE_SPREAD_CONTACT_SKIN)
				affecting_mob.ContactContractDisease(D)

		for(var/datum/disease/D as anything in affecting_mob.diseases)
			if(D.spread_flags & DISEASE_SPREAD_CONTACT_SKIN)
				assailant.ContactContractDisease(D)

	/// Setup the effects applied by grab
	current_grab.update_stage_effects(src, null)
	current_grab.special_bodyzone_effects(src)

	var/mob/living/L = get_affecting_mob()
	if(L && assailant.combat_mode)
		upgrade(TRUE)

	/// Update appearance
	update_appearance(UPDATE_ICON_STATE)

	/// Setup signals
	var/obj/item/bodypart/BP = get_targeted_bodypart()
	if(BP)
		name = "[initial(name)] ([BP.plaintext_zone])"
		RegisterSignal(affecting, COMSIG_CARBON_REMOVED_LIMB, PROC_REF(on_limb_loss))

	RegisterSignal(assailant, COMSIG_PARENT_QDELETING, PROC_REF(target_or_owner_del))
	if(affecting != assailant)
		RegisterSignal(affecting, COMSIG_PARENT_QDELETING, PROC_REF(target_or_owner_del))
	RegisterSignal(affecting, COMSIG_MOVABLE_PRE_THROW, PROC_REF(target_thrown))
	RegisterSignal(affecting, COMSIG_ATOM_ATTACK_HAND, PROC_REF(intercept_attack_hand))

	RegisterSignal(assailant, COMSIG_MOB_SELECTED_ZONE_SET, PROC_REF(on_target_change))

/obj/item/hand_item/grab/Destroy()
	if(affecting)
		LAZYREMOVE(affecting.grabbed_by, src)
		affecting.update_offsets()

	if(affecting && assailant && current_grab)
		current_grab.let_go(src)

	if(assailant)
		LAZYREMOVE(assailant.active_grabs, src)
		assailant.after_grab_release(affecting)

	affecting = null
	assailant = null
	return ..()

/obj/item/hand_item/grab/examine(mob/user)
	. = ..()
	var/mob/living/L = get_affecting_mob()
	var/obj/item/bodypart/BP = get_targeted_bodypart()
	if(L && BP)
		to_chat(user, "A grab on \the [L]'s [BP.plaintext_zone].")

/obj/item/hand_item/grab/update_icon_state()
	. = ..()
	icon = current_grab.icon
	if(current_grab.icon_state)
		icon_state = current_grab.icon_state

/obj/item/hand_item/grab/attack_self(mob/user)
	if (!assailant)
		return

	if(assailant.combat_mode)
		upgrade()
	else
		downgrade()


/obj/item/hand_item/grab/melee_attack_chain(mob/user, atom/target, params)
	if (QDELETED(src) || !assailant || !current_grab)
		return

	if(target.attack_grab(assailant, affecting, src, params2list(params)))
		return

	current_grab.hit_with_grab(src, target, params2list(params))

/*
	This section is for newly defined useful procs.
*/

/obj/item/hand_item/grab/proc/on_target_change(datum/source, new_sel)
	SIGNAL_HANDLER

	if(src != assailant.get_active_held_item())
		return // Note that because of this condition, there's no guarantee that target_zone = old_sel

	new_sel = deprecise_zone(new_sel)
	if(target_zone == new_sel)
		return

	var/obj/item/bodypart/BP

	if(affecting == assailant && iscarbon(assailant))
		BP = assailant.get_bodypart(new_sel)
		var/using_slot = assailant.get_held_index_of_item(src)
		if(assailant.has_hand_for_held_index(using_slot) == BP)
			to_chat(assailant, span_warning("You can't grab your own [BP.plaintext_zone] with itself!"))
			return

	var/old_zone = target_zone
	target_zone = new_sel
	BP = get_targeted_bodypart()

	if (!BP)
		to_chat(assailant, span_warning("You fail to grab \the [affecting] there as they do not have that bodypart!"))
		return

	name = "[initial(name)] ([BP.plaintext_zone])"
	to_chat(assailant, span_notice("You are now holding \the [affecting] by \the [BP.plaintext_zone]."))

	if(!isbodypart(get_targeted_bodypart()))
		current_grab.let_go(src)
		return

	current_grab.on_target_change(src, old_zone, target_zone)

/obj/item/hand_item/grab/proc/on_limb_loss(mob/victim, obj/item/bodypart/lost)
	SIGNAL_HANDLER

	if(affecting != victim)
		stack_trace("A grab switched affecting targets without properly re-registering for dismemberment updates.")
		return
	var/obj/item/bodypart/BP = get_targeted_bodypart()
	if(!istype(BP))
		current_grab.let_go(src)
		return // Sanity check in case the lost organ was improperly removed elsewhere in the code.
	if(lost != BP)
		return
	current_grab.let_go(src)

/// Intercepts attack_hand() calls on our target.
/obj/item/hand_item/grab/proc/intercept_attack_hand(atom/movable/source, user, list/modifiers)
	SIGNAL_HANDLER
	if(user != assailant)
		return

	if(current_grab.resolve_openhand_attack(src))
		return COMPONENT_CANCEL_ATTACK_CHAIN

// Returns the bodypart of the grabbed person that the grabber is targeting
/obj/item/hand_item/grab/proc/get_targeted_bodypart()
	RETURN_TYPE(/obj/item/bodypart)
	var/mob/living/L = get_affecting_mob()
	return (L?.get_bodypart(deprecise_zone(target_zone)))

/obj/item/hand_item/grab/proc/resolve_item_attack(mob/living/M, obj/item/I, target_zone)
	if((M && ishuman(M)) && I)
		return current_grab.resolve_item_attack(src, M, I, target_zone)
	else
		return 0

/obj/item/hand_item/grab/proc/action_used()
	COOLDOWN_START(src, action_cd, current_grab.action_cooldown)
	leave_forensic_traces()

/obj/item/hand_item/grab/proc/leave_forensic_traces()
	if (!affecting)
		return
	var/mob/living/carbon/carbo = get_affecting_mob()
	if(istype(carbo))
		var/obj/item/clothing/C = carbo.get_item_covering_zone(target_zone)
		if(istype(C))
			C.add_fingerprint(assailant)
			return

	affecting.add_fingerprint(assailant) //If no clothing; add fingerprint to mob proper.

/obj/item/hand_item/grab/proc/upgrade(bypass_cooldown, silent)
	if(!COOLDOWN_FINISHED(src, upgrade_cd) && !bypass_cooldown)
		if(!silent)
			to_chat(assailant, span_warning("You must wait [round(COOLDOWN_TIMELEFT(src, upgrade_cd) * 0.1, 0.1)] seconds to upgrade."))
		return

	var/datum/grab/upgrab = current_grab.upgrade(src)
	if(!upgrab)
		return

	if(is_grab_unique(current_grab))
		current_grab.remove_unique_grab_effects(src)

	current_grab = upgrab

	COOLDOWN_START(src, upgrade_cd, current_grab.upgrade_cooldown)

	leave_forensic_traces()

	if(QDELETED(src))
		return

	if(!current_grab.enter_as_up(src, silent))
		return

	if(is_grab_unique(current_grab))
		current_grab.apply_unique_grab_effects(src)

	adjust_position()
	update_appearance()

/obj/item/hand_item/grab/proc/downgrade(silent)
	var/datum/grab/downgrab = current_grab.downgrade(src)
	if(!downgrab)
		return

	if(is_grab_unique(current_grab))
		current_grab.remove_unique_grab_effects(src)

	current_grab = downgrab

	if(!current_grab.enter_as_down(src))
		return

	if(is_grab_unique(current_grab))
		current_grab.apply_unique_grab_effects(src)

	current_grab.enter_as_down(src, silent)
	adjust_position()
	update_appearance()

/// Used to prevent repeated effect application or early effect removal
/obj/item/hand_item/grab/proc/is_grab_unique(datum/grab/grab_datum)
	var/count = 0
	for(var/obj/item/hand_item/grab/other as anything in affecting.grabbed_by)
		if(other.current_grab == grab_datum)
			count++

	if(count >= 2)
		return FALSE
	return TRUE

/obj/item/hand_item/grab/proc/draw_affecting_over()
	affecting.plane = assailant.plane
	affecting.layer = assailant.layer + 0.01

/obj/item/hand_item/grab/proc/draw_affecting_under()
	affecting.plane = assailant.plane
	affecting.layer = assailant.layer - 0.01

/obj/item/hand_item/grab/proc/handle_resist()
	current_grab.handle_resist(src)

/obj/item/hand_item/grab/proc/has_hold_on_bodypart(obj/item/bodypart/BP)
	if (!BP)
		return FALSE

	if (get_targeted_bodypart() == BP)
		return TRUE

	return FALSE

/obj/item/hand_item/grab/proc/get_affecting_mob()
	RETURN_TYPE(/mob/living)
	if(isobj(affecting))
		if(length(affecting.buckled_mobs))
			return affecting.buckled_mobs?[1]
		return

	if(isliving(affecting))
		return affecting

/// Primarily used for do_after() callbacks, checks if the grab item is still holding onto something
/obj/item/hand_item/grab/proc/is_grabbing(atom/movable/AM)
	return affecting == AM
/*
 * This section is for component signal relays/hooks
*/

/// Target deleted, ABORT
/obj/item/hand_item/grab/proc/target_or_owner_del(datum/source)
	SIGNAL_HANDLER
	qdel(src)

/// If something tries to throw the target.
/obj/item/hand_item/grab/proc/target_thrown(atom/movable/source, list/arguments)
	SIGNAL_HANDLER

	if(!current_grab.stop_move)
		return
	if(arguments[4] == assailant && current_grab.can_throw)
		return

	return COMPONENT_CANCEL_THROW

/obj/item/hand_item/grab/attackby(obj/W, mob/user)
	if(user == assailant)
		current_grab.item_attack(src, W)

/obj/item/hand_item/grab/proc/resolve_openhand_attack()
	return current_grab.resolve_openhand_attack(src)

/obj/item/hand_item/grab/proc/adjust_position()
	if(QDELETED(assailant) || QDELETED(affecting) || !assailant.Adjacent(affecting))
		qdel(src)
		return FALSE

	if(assailant)
		assailant.setDir(get_dir(assailant, affecting))

	if(current_grab.same_tile)
		affecting.move_from_pull(assailant, get_turf(assailant))
		affecting.setDir(assailant.dir)

	affecting.update_offsets()
	affecting.reset_plane_and_layer()

/obj/item/hand_item/grab/proc/move_victim_towards(atom/destination)
	if(current_grab.same_tile)
		return

	if(affecting.anchored || affecting.move_resist > assailant.move_force || !affecting.Adjacent(assailant, assailant, affecting))
		qdel(src)
		return

	if(isliving(assailant))
		var/mob/living/pulling_mob = assailant
		if(pulling_mob.buckled && pulling_mob.buckled.buckle_prevents_pull) //if they're buckled to something that disallows pulling, prevent it
			qdel(src)
			return

	var/move_dir = get_dir(affecting.loc, destination)

	// Don't move people in space, that's fucking cheating
	if(!Process_Spacemove(move_dir))
		return

	// Okay, now actually try to move
	. = affecting.Move(get_step(affecting.loc, move_dir), move_dir, glide_size)
	if(.)
		affecting.update_offsets()

/// Removes any grabs applied to the affected movable that aren't src
/obj/item/hand_item/grab/proc/remove_competing_grabs()
	for(var/obj/item/hand_item/grab/other_grab in affecting.grabbed_by - src)
		to_chat(other_grab.assailant, span_alert("[affecting] is ripped from your grip by [assailant]."))
		qdel(other_grab)
