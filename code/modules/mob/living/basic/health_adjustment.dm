/**
 * Adjusts the health of a simple mob by a set amount and wakes AI if its idle to react
 *
 * Arguments:
 * * amount The amount that will be used to adjust the mob's health
 * * updating_health If the mob's health should be immediately updated to the new value
 * * forced If we should force update the adjustment of the mob's health no matter the restrictions, like GODMODE
 */
/mob/living/basic/proc/adjust_health(amount, updating_health = TRUE, forced = FALSE)
	. = FALSE
	if(forced || !(status_flags & GODMODE))
		bruteloss = round(clamp(bruteloss + amount, 0, maxHealth), DAMAGE_PRECISION)
		if(updating_health)
			updatehealth()
		. = amount
	if(ckey || stat)
		return
	//if(AIStatus == AI_IDLE)
	//	toggle_ai(AI_ON)

/mob/living/basic/adjustBruteLoss(amount, updating_health = TRUE, forced = FALSE)
	if(forced)
		. = adjust_health(amount * CONFIG_GET(number/damage_multiplier), updating_health, forced)
	else if(damage_coeff[BRUTE])
		. = adjust_health(amount * damage_coeff[BRUTE] * CONFIG_GET(number/damage_multiplier), updating_health, forced)

/mob/living/basic/adjustFireLoss(amount, updating_health = TRUE, forced = FALSE)
	if(forced)
		. = adjust_health(amount * CONFIG_GET(number/damage_multiplier), updating_health, forced)
	else if(damage_coeff[BURN])
		. = adjust_health(amount * damage_coeff[BURN] * CONFIG_GET(number/damage_multiplier), updating_health, forced)

/mob/living/basic/adjustOxyLoss(amount, updating_health = TRUE, forced = FALSE)
	if(forced)
		. = adjust_health(amount * CONFIG_GET(number/damage_multiplier), updating_health, forced)
	else if(damage_coeff[OXY])
		. = adjust_health(amount * damage_coeff[OXY] * CONFIG_GET(number/damage_multiplier), updating_health, forced)

/mob/living/basic/adjustToxLoss(amount, updating_health = TRUE, forced = FALSE, cause_of_death = "Systemic organ failure")
	if(forced)
		. = adjust_health(amount * CONFIG_GET(number/damage_multiplier), updating_health, forced)
	else if(damage_coeff[TOX])
		. = adjust_health(amount * damage_coeff[TOX] * CONFIG_GET(number/damage_multiplier), updating_health, forced)

/mob/living/basic/adjustCloneLoss(amount, updating_health = TRUE, forced = FALSE)
	if(forced)
		. = adjust_health(amount * CONFIG_GET(number/damage_multiplier), updating_health, forced)
	else if(damage_coeff[CLONE])
		. = adjust_health(amount * damage_coeff[CLONE] * CONFIG_GET(number/damage_multiplier), updating_health, forced)

/mob/living/basic/pre_stamina_change(diff as num)
	return diff * damage_coeff[STAMINA]

