/mob/camera/flock/say(message, bubble_type, list/spans, sanitize, datum/language/language, ignore_spam, forced, filterproof, range)
	if (!message)
		return

	if (src.client)
		if(client.prefs.muted & MUTE_IC)
			to_chat(src, span_boldwarning("You cannot send IC messages (muted)."))
			return
		if (!(ignore_spam || forced) && src.client.handle_spam_prevention(message,MUTE_IC))
			return

	flock_talk(src, message, flock)

/proc/flock_talk(mob/speaker, message, datum/flock/flock, involuntary)

	message = trim(copytext_char(sanitize(message), 1, MAX_MESSAGE_LEN))
	if (!message)
		return

	var/used_name = ""
	var/list/spans = list("flocksay")

	// Get spans
	if(istype(speaker, /mob/camera/flock))
		spans += "sentient"
		if(istype(speaker, /mob/camera/flock/overmind))
			spans += "flockmind"

	else if(istype(speaker, /mob/living/simple_animal/flock/drone))
		var/mob/living/simple_animal/flock/drone/bird_drone = speaker
		if(!bird_drone.controlled_by)
			spans += "flocknpc"

	else
		spans += "bold"
		spans += "italics"

	// Get name
	if(isnull(speaker))
		used_name = "\[SYSTEM\]"

	else if(istype(speaker, /mob/living/simple_animal/flock/drone))
		var/mob/living/simple_animal/flock/drone/bird_drone = speaker
		if(!bird_drone.controlled_by)
			used_name = "Drone [bird_drone.real_name]"
		else
			used_name = "[bird_drone.controlled_by.real_name] as [bird_drone]"

	else if(istype(speaker, /mob/camera/flock))
		var/mob/camera/flock/overmind/ghost_bird = speaker
		used_name = ghost_bird.real_name

	if(speaker)
		var/say_verb = pick("sings", "clicks", "whistles", "intones", "transmits", "submits", "uploads")
		message = "[say_verb], \"[message]\""

	var/flock_message = "<span class='game say [jointext(spans, " ")]'><span class='bold'>\[[flock ? flock.name : "--.--"]\]</span> [span_name("[used_name]")] <span class='message'>[message]</span></span>"
	var/silicon_message = "<span class='game say [jointext(spans, " ")]'><span class='bold'>\[?????\]</span> [span_name("[used_name]")] <span class='message'>[stars(message, 50)]</span></span>"

	for(var/mob/player as anything in GLOB.player_list)
		if(isflockmob(player))
			to_chat(player, flock_message)
			continue

		if(isobserver(player) && !involuntary)
			to_chat(player, flock_message)
			continue

		if(player.can_hear() && player.binarycheck() && (!involuntary && speaker || prob(30)))
			to_chat(player, silicon_message)
			continue
