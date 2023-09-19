/datum/preference/toggle/monochrome_ghost
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	savefile_key = "monochrome_ghost"
	savefile_identifier = PREFERENCE_PLAYER

	default_value = TRUE

/datum/preference/toggle/monochrome_ghost/apply_to_client(client/client, value)
	var/mob/dead/observer/M = client.mob
	if(value && istype(M) && !M.started_as_observer)
		M.add_client_colour(/datum/client_colour/ghostmono)
	else
		M.remove_client_colour(/datum/client_colour/ghostmono)
