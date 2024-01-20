/mob/living
	COOLDOWN_DECLARE(pain_cd)
	COOLDOWN_DECLARE(pain_emote_cd)

/mob/living/carbon/var/shock_stage

/mob/living/carbon/getPain()
	. = 0
	for(var/obj/item/bodypart/BP as anything in bodyparts)
		. += BP.getPain()

	. -= CHEM_EFFECT_MAGNITUDE(src, CE_PAINKILLER)

	if(stat == UNCONSCIOUS)
		. *= 0.6

	return max(0, .)

/mob/living/carbon/adjustPain(amount, updating_health = TRUE)
	if(((status_flags & GODMODE)))
		return FALSE
	return apply_pain(amount, updating_health = updating_health)

/mob/living/proc/flash_pain(severity = PAIN_SMALL)
	return

/mob/living/carbon/flash_pain(severity = PAIN_SMALL)
	flick(severity, hud_used?.pain)

/mob/living/carbon/apply_pain(amount, def_zone, message, ignore_cd, updating_health = TRUE)
	if((status_flags & GODMODE) || HAS_TRAIT(src, TRAIT_NO_PAINSHOCK))
		return FALSE

	amount -= CHEM_EFFECT_MAGNITUDE(src, CE_PAINKILLER)/3
	if(amount <= 0)
		return

	var/obj/item/bodypart/BP
	if(!def_zone) // Distribute to all bodyparts evenly if no bodypart
		var/list/not_full = bodyparts.Copy()
		var/list/parts = not_full.Copy()
		var/amount_remaining = amount
		while(amount_remaining > 0 && length(not_full))
			if(!length(parts))
				parts += not_full

			var/pain_per_part = round(amount_remaining/length(parts), DAMAGE_PRECISION)
			BP = pick(parts)
			parts -= BP

			var/used = BP.adjustPain(pain_per_part)
			if(!used)
				not_full -= BP
				continue

			amount_remaining -= abs(used)
		. = amount - amount_remaining
	else
		BP = get_bodypart(def_zone, TRUE)
		if(!BP)
			return
		. = BP.adjustPain(amount)


	if(.)
		switch(.)
			if(1 to PAIN_AMT_MEDIUM)
				flash_pain(PAIN_SMALL)
			if(20 to PAIN_AMT_MEDIUM)
				flash_pain(PAIN_MEDIUM)
				shake_camera(src, 1, 2)
			if(PAIN_AMT_MEDIUM to INFINITY)
				flash_pain(PAIN_LARGE)
				shake_camera(src, 3, 4)

		pain_message(message, ., ignore_cd)

	if(updating_health && .)
		updatehealth()

/mob/living/carbon/proc/pain_message(message, amount, ignore_cd)
	set waitfor = FALSE
	if(!amount)
		return FALSE

	. = COOLDOWN_FINISHED(src, pain_cd)
	if(!ignore_cd && !.)
		return FALSE

	if(message)
		switch(round(amount))
			if(PAIN_AMT_AGONIZING to INFINITY)
				to_chat(src, span_danger(span_big(message)))
			if(PAIN_AMT_MEDIUM to PAIN_AMT_AGONIZING - 1)
				to_chat(src, span_danger(message))
			if(PAIN_AMT_LOW to PAIN_AMT_MEDIUM - 1)
				to_chat(src, span_danger(message))
			else
				to_chat(src, span_warning(message))

	if(.)
		COOLDOWN_START(src, pain_cd, rand(12 SECONDS, 20 SECONDS))

	return TRUE

/mob/living/carbon/human/pain_message(message, amount, ignore_cd)
	. = ..()
	if(!.)
		return

	var/emote = dna.species.get_pain_emote(amount)
	var/probability = 0

	switch(round(amount))
		if(PAIN_AMT_AGONIZING to INFINITY)
			probability = 100
		if(PAIN_AMT_MEDIUM to PAIN_AMT_AGONIZING - 1)
			probability = 70
		if(1 to PAIN_AMT_MEDIUM - 1)
			probability = 20

	if(emote && prob(probability))
		pain_emote(amount)

/// Perform a pain response emote, amount is the amount of pain they are in. See pain defines for easy numbers.
/mob/living/carbon/proc/pain_emote(amount = PAIN_AMT_LOW, bypass_cd)
	if(!COOLDOWN_FINISHED(src, pain_emote_cd) && !bypass_cd)
		return

	COOLDOWN_START(src, pain_emote_cd, 5 SECONDS)
	emote(dna.species.get_pain_emote(amount))

#define PAIN_STRING \
	pick("The pain is excruciating!",\
		"Please, just end the pain!",\
		"Your whole body is going numb!"\
	)

/mob/living/carbon/proc/handle_shock()
	if(status_flags & GODMODE)
		return

	if(HAS_TRAIT(src, TRAIT_FAKEDEATH))
		return

	if(HAS_TRAIT(src, TRAIT_NO_PAINSHOCK))
		shock_stage = 0
		return

	var/heart_attack_gaming = undergoing_cardiac_arrest()
	if(heart_attack_gaming)
		shock_stage = max(shock_stage + 1, SHOCK_TIER_4 + 1)

	var/pain = getPain()
	if(pain >= max(SHOCK_MIN_PAIN_TO_BEGIN, shock_stage * 0.8))
		shock_stage = min(shock_stage + 1, SHOCK_MAXIMUM)

	else if(!heart_attack_gaming)
		shock_stage = min(shock_stage, SHOCK_MAXIMUM)
		var/recovery = 1
		if(pain < 0.5 * shock_stage)
			recovery = 3
		else if(pain < 0.25 * shock_stage)
			recovery = 2

		shock_stage = max(shock_stage - recovery, 0)
		return

	if(stat)
		return

	if(shock_stage == SHOCK_TIER_1)
		pain_message(PAIN_STRING, 10 - CHEM_EFFECT_MAGNITUDE(src, CE_PAINKILLER)/3)

	if(shock_stage >= SHOCK_TIER_2)
		if(shock_stage == SHOCK_TIER_2 && organs_by_slot[ORGAN_SLOT_EYES])
			visible_message("<b>[src]</b> is having trouble keeping [p_their()] eyes open.")
		if(prob(30))
			blur_eyes(3)
			set_timed_status_effect(10 SECONDS, /datum/status_effect/speech/stutter, only_if_higher = TRUE)

	if(shock_stage == SHOCK_TIER_3)
		pain_message(PAIN_STRING, shock_stage - CHEM_EFFECT_MAGNITUDE(src, CE_PAINKILLER)/3)

	if(shock_stage >= SHOCK_TIER_4 && prob(2))
		pain_message(PAIN_STRING, shock_stage - CHEM_EFFECT_MAGNITUDE(src, CE_PAINKILLER)/3)
		Knockdown(2 SECONDS)

	if(shock_stage >= SHOCK_TIER_5 && prob(5))
		pain_message(PAIN_STRING, shock_stage - CHEM_EFFECT_MAGNITUDE(src, CE_PAINKILLER)/3)
		Knockdown(2 SECONDS)

	if(shock_stage >= SHOCK_TIER_6)
		if (prob(2))
			pain_message(pick("You black out!", "You feel like you could die any moment now!", "You're about to lose consciousness!"), shock_stage - CHEM_EFFECT_MAGNITUDE(src, CE_PAINKILLER)/3)
			Unconscious(10 SECONDS)

	if(shock_stage >= SHOCK_TIER_7)
		if(shock_stage == SHOCK_TIER_7)
			visible_message("<b>[src]</b> falls limp!")
		Knockdown(40 SECONDS)

#undef PAIN_STRING

/mob/living/carbon/proc/handle_pain()
	if(stat)
		return

	var/pain = getPain()

	if(pain >= 15)
		add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/pain, TRUE, min((pain / 15), 15))
	else
		remove_movespeed_modifier(/datum/movespeed_modifier/pain)

	if(pain >= maxHealth)
		if(stat == CONSCIOUS && !HAS_TRAIT(src, TRAIT_FAKEDEATH))
			visible_message(
				"<b>[src]</b> slumps over, too weak to continue fighting...",
				span_danger("You give into the pain.")
			)
		Sleeping(10 SECONDS)
		return

	if(!COOLDOWN_FINISHED(src, pain_cd) && !prob(5))
		return

	var/highest_damage
	var/obj/item/bodypart/damaged_part
	for(var/obj/item/bodypart/loop as anything in bodyparts)
		if(loop.bodypart_flags & BP_NO_PAIN)
			continue

		var/dam = loop.getPain()
		if(dam && dam > highest_damage && (highest_damage == 0 || prob(70)))
			damaged_part = loop
			highest_damage = dam

	if(damaged_part && CHEM_EFFECT_MAGNITUDE(src, CE_PAINKILLER) < highest_damage)
		if(highest_damage > PAIN_THRESHOLD_REDUCE_PARALYSIS)
			AdjustSleeping(-(highest_damage / 5) SECONDS)
		if(highest_damage > PAIN_THRESHOLD_DROP_ITEM && prob(highest_damage / 5))
			dropItemToGround(get_active_held_item())

		var/burning = damaged_part.burn_dam > damaged_part.brute_dam
		var/msg
		switch(highest_damage)
			if(1 to PAIN_AMT_MEDIUM)
				msg = "Your [damaged_part.plaintext_zone] [burning ? "burns" : "hurts"]."
			if(PAIN_AMT_MEDIUM to PAIN_AMT_AGONIZING)
				msg = "Your [damaged_part.plaintext_zone] [burning ? "burns" : "hurts"] badly!"
			if(PAIN_AMT_AGONIZING to INFINITY)
				msg = "OH GOD! Your [damaged_part.plaintext_zone] is [burning ? "on fire" : "hurting terribly"]!"

		pain_message(msg, highest_damage)


	// Damage to internal organs hurts a lot.
	for(var/obj/item/organ/I as anything in organs)
		if(prob(1) && (!(I.organ_flags & (ORGAN_SYNTHETIC|ORGAN_DEAD)) && I.damage > 5))
			var/obj/item/bodypart/parent = I.ownerlimb
			if(parent.bodypart_flags & BP_NO_PAIN)
				continue

			var/pain_given = 10
			var/message = "You feel a dull pain in your [parent.plaintext_zone]"
			if(I.damage > I.low_threshold)
				pain_given = 25
				message = "You feel a pain in your [parent.plaintext_zone]"
			if(I.damage > (I.high_threshold * I.maxHealth))
				pain_given = 40
				message = "You feel a sharp pain in your [parent.plaintext_zone]"
			apply_pain(pain_given, parent.body_zone, message)

	if(prob(1))
		var/systemic_organ_failure = getToxLoss()
		switch(systemic_organ_failure)
			if(5 to 17)
				pain_message("Your body stings slightly.", 10)
			if(17 to 35)
				pain_message("Your body stings.", 20)
			if(35 to 60)
				pain_message("Your body stings strongly.", 40)
			if(60 to 100)
				pain_message("Your whole body hurts badly.", 40)
			if(100 to INFINITY)
				pain_message("Your body aches all over, it's driving you mad.", 70)
