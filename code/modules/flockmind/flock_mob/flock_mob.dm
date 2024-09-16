/mob/living/simple_animal/flock
	name = "flockdrone"
	icon = 'goon/icons/mob/featherzone.dmi'
	icon_state = "drone"
	icon_living = "drone"
	icon_dead = "drone-dead"

	light_system = OVERLAY_LIGHT
	light_color = "#26ffe6"
	light_power = 0.2
	light_outer_range = 2

	ai_controller = /datum/ai_controller/flock

	minbodytemp = 0
	maxbodytemp = 1000
	atmos_requirements = list(
		"min_oxy" = 0,
		"max_oxy" = 0,
		"min_plas" = 0,
		"max_plas" = 0,
		"min_co2" = 0,
		"max_co2" = 0,
		"min_n2" = 0,
		"max_n2" = 0
	)


	stop_automated_movement = TRUE
	movement_type = FLOATING

	/// Flock datum. Can be null.
	var/datum/flock/flock
	/// A mob possessing this mob.
	var/mob/camera/flock/controlled_by

/mob/living/simple_animal/flock/Initialize(mapload)
	. = ..()
	update_light_state()
	RegisterSignal(ai_controller, COMSIG_AI_STATUS_CHANGE, PROC_REF(on_ai_status_change))

	var/datum/action/cooldown/flock/convert/convert_action = new
	convert_action.Grant(src)
	set_combat_mode(TRUE)
	ADD_TRAIT(src, TRAIT_FREE_FLOAT_MOVEMENT, INNATE_TRAIT)
	flock = GLOB.debug_flock

/mob/living/simple_animal/flock/set_stat(new_stat)
	. = ..()
	switch(stat)
		if(CONSCIOUS)
			ADD_TRAIT(src, TRAIT_MOVE_FLOATING, INNATE_TRAIT)
		else
			REMOVE_TRAIT(src, TRAIT_MOVE_FLOATING, INNATE_TRAIT)


/// Turn the light on or off, based on if the mob is doing shit or not.
/mob/living/simple_animal/flock/proc/update_light_state()
	if(stat == DEAD)
		set_light_on(FALSE)
		return

	if(ai_controller.ai_status == AI_ON || ckey)
		set_light_on(TRUE)
		return

	set_light_on(FALSE)

/mob/living/simple_animal/flock/proc/on_ai_status_change(datum/ai_controller/source, ai_status)
	SIGNAL_HANDLER
	update_light_state()
