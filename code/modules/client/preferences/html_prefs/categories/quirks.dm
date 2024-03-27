/datum/preference_group/category/quirks
	name = "Traits"
	priority = 1

/datum/preference_group/category/quirks/get_content(datum/preferences/prefs)
	. = ..()
	var/datum/preference/P = GLOB.preference_entries[/datum/preference/blob/quirks]
	var/list/all_quirks = SSquirks.get_quirks()
	var/list/quirk_info = list()
	var/list/user_quirks = prefs.read_preference(P.type)

	for (var/quirk_name in all_quirks)
		var/datum/quirk/quirk = all_quirks[quirk_name]
		quirk_info[quirk_name] = list(
			"description" = initial(quirk.desc),
			"icon" = initial(quirk.icon),
			"name" = quirk_name,
			"genre" = initial(quirk.quirk_genre),
		)

	. += {"
	<fieldset class='computerPaneNested' style='display: inline-block;min-width:40%;max-width:40%;margin-left: auto;margin-right: auto'>
		<legend class='computerLegend tooltip'>
			<b>All Traits</b>
			<span class='tooltiptext'>I'm gettin' quirked up tonight.</span>
		</legend>
	<table class='zebraTable' style='min-width:100%;height: 560px;display: block;overflow-y: scroll'>
	"}

	for(var/quirk in all_quirks)
		if(quirk in user_quirks)
			continue

		var/quirk_type
		switch(quirk_info[quirk]["genre"])
			if(QUIRK_GENRE_BOON)
				quirk_type = "<span style='color: #AAFFAA'>Boon</span>"
			if(QUIRK_GENRE_BANE)
				quirk_type = "<span style='color: #FFAAAA'>Bane</span>"
			else
				quirk_type = "<span style='color: #AAAAFF'>Neutral</span>"

		. += {"
		<tr style='min-width=100%'>
			<td>
				[button_element(prefs, "[quirk]", "pref_act=[P.type];toggle_quirk=[quirk]")] - [button_element(prefs, "?", "pref_act=[P.type];info=[quirk]")] - [quirk_type]
			</td>
		</tr>
		"}


	. += "</table></fieldset>"

	. += {"
	<fieldset class='computerPaneNested' style='display: inline-block;min-width:40%;max-width:40%;margin-left: auto;margin-right: auto'>
		<legend class='computerLegend tooltip'>
			<b>My Traits</b>
			<span class='tooltiptext'>I'm gettin' quirked up tonight.</span>
		</legend>
	<table class='zebraTable' style='min-width:100%;height: 560px;display: block;overflow-y: scroll'>
	"}

	for(var/quirk in user_quirks)
		. += {"
		<tr>
			<td>
				<b>[quirk]</b> -
				[button_element(prefs, "REMOVE", "pref_act=[P.type];toggle_quirk=[quirk]")]
				<br>
				[quirk_info[quirk]["description"]]
			</td>
		</tr>
		"}

	. += "</table></fieldset>"
