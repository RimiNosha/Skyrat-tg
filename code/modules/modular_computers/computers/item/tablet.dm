/obj/item/modular_computer/tablet  //Its called tablet for theme of 90ies but actually its a "big smartphone" sized
	name = "tablet computer"
	icon = 'icons/obj/modular_tablet.dmi'
	icon_state = "tablet-red"
	icon_state_unpowered = "tablet-red"
	icon_state_powered = "tablet-red"
	icon_state_menu = "menu"
	inhand_icon_state = "electronic"
	lefthand_file = 'icons/mob/inhands/items/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items/devices_righthand.dmi'
	base_icon_state = "tablet"
	worn_icon_state = "tablet"
	hardware_flag = PROGRAM_TABLET
	max_hardware_size = 1
	max_idle_programs = 2
	w_class = WEIGHT_CLASS_SMALL
	max_bays = 3
	steel_sheet_cost = 2
	slot_flags = ITEM_SLOT_ID | ITEM_SLOT_BELT
	has_light = TRUE //LED flashlight!
	comp_light_luminosity = 2.3 //Same as the PDA
	looping_sound = FALSE
	custom_materials = list(/datum/material/iron=300, /datum/material/glass=100, /datum/material/plastic=100)
	interaction_flags_atom = INTERACT_ATOM_ALLOW_USER_LOCATION

	var/has_variants = TRUE
	var/finish_color = null

	///The item currently inserted into the PDA, starts with a pen.
	var/obj/item/inserted_item = /obj/item/pen
	///List of items that can be stored in a PDA
	var/static/list/contained_item = list(
		/obj/item/pen,
		/obj/item/toy/crayon,
		/obj/item/lipstick,
		/obj/item/flashlight/pen,
		/obj/item/clothing/mask/cigarette,
	)

/obj/item/modular_computer/tablet/update_icon_state()
	if(has_variants && !bypass_state)
		if(!finish_color)
			finish_color = pick("red", "blue", "brown", "green", "black")
		icon_state = icon_state_powered = icon_state_unpowered = "[base_icon_state]-[finish_color]"
	return ..()

/obj/item/modular_computer/tablet/attack_self(mob/user)
	// bypass literacy checks to access syndicate uplink
	var/datum/component/uplink/hidden_uplink = GetComponent(/datum/component/uplink)
	if(hidden_uplink?.owner && HAS_TRAIT(user, TRAIT_ILLITERATE))
		if(hidden_uplink.owner != user.key)
			return ..()

		hidden_uplink.locked = FALSE
		hidden_uplink.interact(null, user)
		return COMPONENT_CANCEL_ATTACK_CHAIN

	return ..()

/obj/item/modular_computer/tablet/interact(mob/user)
	. = ..()
	if(HAS_TRAIT(src, TRAIT_PDA_MESSAGE_MENU_RIGGED))
		explode(usr, from_message_menu = TRUE)

/obj/item/modular_computer/tablet/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = ..()

	context[SCREENTIP_CONTEXT_CTRL_LMB] = "Remove pen"

	return CONTEXTUAL_SCREENTIP_SET

/obj/item/modular_computer/tablet/attackby(obj/item/W, mob/user)
	. = ..()

	if(is_type_in_list(W, contained_item))
		if(W.w_class >= WEIGHT_CLASS_SMALL) // Anything equal to or larger than small won't work
			return
		if(inserted_item)
			to_chat(user, span_warning("There is already \a [inserted_item] in \the [src]!"))
		else
			if(!user.transferItemToLoc(W, src))
				return
			to_chat(user, span_notice("You insert \the [W] into \the [src]."))
			inserted_item = W
			playsound(src, 'sound/machines/pda_button1.ogg', 50, TRUE)

/obj/item/modular_computer/tablet/AltClick(mob/user)
	. = ..()
	if(.)
		return

	remove_pen(user)

/obj/item/modular_computer/tablet/CtrlClick(mob/user)
	. = ..()
	if(.)
		return

	remove_pen(user)

///Finds how hard it is to send a virus to this tablet, checking all programs downloaded.
/obj/item/modular_computer/tablet/proc/get_detomatix_difficulty()
	var/detomatix_difficulty

	var/obj/item/computer_hardware/hard_drive/hdd = all_components[MC_HDD]
	if(hdd)
		for(var/datum/computer_file/program/downloaded_apps as anything in hdd.stored_files)
			detomatix_difficulty += downloaded_apps.detomatix_resistance

	return detomatix_difficulty

/obj/item/modular_computer/tablet/proc/tab_no_detonate()
	SIGNAL_HANDLER
	return COMPONENT_TABLET_NO_DETONATE

/obj/item/modular_computer/tablet/proc/remove_pen(mob/user)

	if(issilicon(user) || !user.canUseTopic(src, be_close = TRUE, no_dexterity = FALSE, no_tk = TRUE)) //TK doesn't work even with this removed but here for readability
		return

	if(inserted_item)
		to_chat(user, span_notice("You remove [inserted_item] from [src]."))
		user.put_in_hands(inserted_item)
		inserted_item = null
		update_appearance()
		playsound(src, 'sound/machines/pda_button2.ogg', 50, TRUE)
	else
		to_chat(user, span_warning("This tablet does not have a pen in it!"))

// Tablet 'splosion..

/obj/item/modular_computer/tablet/proc/explode(mob/target, mob/bomber, from_message_menu = FALSE)
	var/turf/T = get_turf(src)

	if(from_message_menu)
		log_bomber(null, null, target, "'s tablet exploded as [target.p_they()] tried to open their tablet message menu because of a recent tablet bomb.")
	else
		log_bomber(bomber, "successfully tablet-bombed", target, "as [target.p_they()] tried to reply to a rigged tablet message [bomber && !is_special_character(bomber) ? "(SENT BY NON-ANTAG)" : ""]")

	if (ismob(loc))
		var/mob/M = loc
		M.show_message(span_userdanger("Your [src] explodes!"), MSG_VISUAL, span_warning("You hear a loud *pop*!"), MSG_AUDIBLE)
	else
		visible_message(span_danger("[src] explodes!"), span_warning("You hear a loud *pop*!"))

	target.client?.give_award(/datum/award/achievement/misc/clickbait, target)

	if(T)
		T.hotspot_expose(700,125)
		if(istype(all_components[MC_SDD], /obj/item/computer_hardware/hard_drive/portable/virus/deto))
			explosion(src, devastation_range = -1, heavy_impact_range = 1, light_impact_range = 3, flash_range = 4)
		else
			explosion(src, devastation_range = -1, heavy_impact_range = -1, light_impact_range = 2, flash_range = 3)
	qdel(src)


/**
 * A simple helper proc that applies the client's ringtone prefs to the tablet's messenger app,
 * if it has one.
 *
 * Arguments:
 * * ringtone_client - The client whose prefs we'll use to set the ringtone of this PDA.
 */
/obj/item/modular_computer/tablet/proc/update_ringtone(client/ringtone_client)
	if(!ringtone_client)
		return

	var/new_ringtone = ringtone_client?.prefs?.read_preference(/datum/preference/text/pda_ringtone)

	if(!new_ringtone || new_ringtone == MESSENGER_RINGTONE_DEFAULT)
		return

	var/obj/item/computer_hardware/hard_drive/drive = all_components[MC_HDD]

	if(!drive)
		return

	for(var/datum/computer_file/program/messenger/messenger_app in drive.stored_files)
		messenger_app.ringtone = new_ringtone


// SUBTYPES

/obj/item/modular_computer/tablet/syndicate_contract_uplink
	name = "contractor tablet"
	icon = 'icons/obj/contractor_tablet.dmi'
	icon_state = "tablet"
	icon_state_unpowered = "tablet"
	icon_state_powered = "tablet"
	icon_state_menu = "assign"
	w_class = WEIGHT_CLASS_SMALL
	slot_flags = ITEM_SLOT_ID | ITEM_SLOT_BELT
	comp_light_luminosity = 6.3
	has_variants = FALSE

/// Given to Nuke Ops members.
/obj/item/modular_computer/tablet/nukeops
	icon_state = "tablet-syndicate"
	icon_state_powered = "tablet-syndicate"
	icon_state_unpowered = "tablet-syndicate"
	comp_light_luminosity = 6.3
	has_variants = FALSE
	device_theme = "syndicate"
	light_color = COLOR_RED

/obj/item/modular_computer/tablet/nukeops/emag_act(mob/user)
	if(!enabled)
		to_chat(user, span_warning("You'd need to turn the [src] on first."))
		return FALSE
	to_chat(user, span_notice("You swipe \the [src]. It's screen briefly shows a message reading \"MEMORY CODE INJECTION DETECTED AND SUCCESSFULLY QUARANTINED\"."))
	return FALSE

/// Borg Built-in tablet interface
/obj/item/modular_computer/tablet/integrated
	name = "modular interface"
	icon_state = "tablet-silicon"
	icon_state_powered = "tablet-silicon"
	icon_state_unpowered = "tablet-silicon"
	base_icon_state = "tablet-silicon"
	has_light = FALSE //tablet light button actually enables/disables the borg lamp
	comp_light_luminosity = 0
	has_variants = FALSE
	///Ref to the silicon we're installed in. Set by the silicon itself during its creation.
	var/mob/living/silicon/silicon_owner
	///Ref to the RoboTact app. Important enough to borgs to deserve a ref.
	var/datum/computer_file/program/robotact/robotact
	///IC log that borgs can view in their personal management app
	var/list/borglog = list()

/obj/item/modular_computer/tablet/integrated/Initialize(mapload)
	. = ..()
	vis_flags |= VIS_INHERIT_ID
	silicon_owner = loc
	if(!istype(silicon_owner))
		silicon_owner = null
		stack_trace("[type] initialized outside of a borg, deleting.")
		return INITIALIZE_HINT_QDEL

/obj/item/modular_computer/tablet/integrated/Destroy()
	silicon_owner = null
	return ..()

/obj/item/modular_computer/tablet/integrated/turn_on(mob/user, open_ui = FALSE)
	if(silicon_owner?.stat != DEAD)
		return ..()
	return FALSE

/obj/item/modular_computer/tablet/integrated/get_ntnet_status(specific_action = 0)
	//No borg found
	if(!silicon_owner)
		return FALSE
	// no AIs/pAIs
	var/mob/living/silicon/robot/cyborg_check = silicon_owner
	if(!istype(cyborg_check))
		return ..()
	//lockdown restricts borg networking
	if(cyborg_check.lockcharge)
		return FALSE
	//borg cell dying restricts borg networking
	if(!cyborg_check.cell || cyborg_check.cell.charge == 0)
		return FALSE

	return ..()

/**
 * Returns a ref to the RoboTact app, creating the app if need be.
 *
 * The RoboTact app is important for borgs, and so should always be available.
 * This proc will look for it in the tablet's robotact var, then check the
 * hard drive if the robotact var is unset, and finally attempt to create a new
 * copy if the hard drive does not contain the app. If the hard drive rejects
 * the new copy (such as due to lack of space), the proc will crash with an error.
 * RoboTact is supposed to be undeletable, so these will create runtime messages.
 */
/obj/item/modular_computer/tablet/integrated/proc/get_robotact()
	if(!silicon_owner)
		return null
	if(!robotact)
		var/obj/item/computer_hardware/hard_drive/hard_drive = all_components[MC_HDD]
		robotact = hard_drive.find_file_by_name("robotact")
		if(!robotact)
			stack_trace("Cyborg [silicon_owner] ( [silicon_owner.type] ) was somehow missing their self-manage app in their tablet. A new copy has been created.")
			robotact = new(hard_drive)
			if(!hard_drive.store_file(robotact))
				qdel(robotact)
				robotact = null
				CRASH("Cyborg [silicon_owner]'s tablet hard drive rejected recieving a new copy of the self-manage app. To fix, check the hard drive's space remaining. Please make a bug report about this.")
	return robotact

//Makes the light settings reflect the borg's headlamp settings
/obj/item/modular_computer/tablet/integrated/ui_data(mob/user)
	. = ..()
	.["has_light"] = TRUE
	if(iscyborg(silicon_owner))
		var/mob/living/silicon/robot/robo = silicon_owner
		.["light_on"] = robo.lamp_enabled
		.["comp_light_color"] = robo.lamp_color

//Makes the flashlight button affect the borg rather than the tablet
/obj/item/modular_computer/tablet/integrated/toggle_flashlight()
	if(!silicon_owner || QDELETED(silicon_owner))
		return FALSE
	if(iscyborg(silicon_owner))
		var/mob/living/silicon/robot/robo = silicon_owner
		robo.toggle_headlamp()
	return TRUE

//Makes the flashlight color setting affect the borg rather than the tablet
/obj/item/modular_computer/tablet/integrated/set_flashlight_color(color)
	if(!silicon_owner || QDELETED(silicon_owner) || !color)
		return FALSE
	if(iscyborg(silicon_owner))
		var/mob/living/silicon/robot/robo = silicon_owner
		robo.lamp_color = color
		robo.toggle_headlamp(FALSE, TRUE)
	return TRUE

/obj/item/modular_computer/tablet/integrated/ui_state(mob/user)
	return GLOB.reverse_contained_state

/obj/item/modular_computer/tablet/integrated/syndicate
	icon_state = "tablet-silicon-syndicate"
	icon_state_powered = "tablet-silicon-syndicate"
	icon_state_unpowered = "tablet-silicon-syndicate"
	device_theme = "syndicate"


/obj/item/modular_computer/tablet/integrated/syndicate/Initialize(mapload)
	. = ..()
	if(iscyborg(silicon_owner))
		var/mob/living/silicon/robot/robo = silicon_owner
		robo.lamp_color = COLOR_RED //Syndicate likes it red

// Round start tablets

/obj/item/modular_computer/tablet/pda
	icon = 'icons/obj/modular_pda.dmi'
	icon_state = "pda"

	greyscale_config = /datum/greyscale_config/tablet
	greyscale_colors = "#999875#a92323"

	bypass_state = TRUE
	allow_chunky = TRUE

	///All applications this tablet has pre-installed
	var/list/default_applications = list()
	///The pre-installed cartridge that comes with the tablet
	var/loaded_cartridge

/obj/item/modular_computer/tablet/pda/update_overlays()
	. = ..()
	var/init_icon = initial(icon)
	var/obj/item/computer_hardware/card_slot/card = all_components[MC_CARD]
	if(!init_icon)
		return
	if(card)
		if(card.stored_card)
			. += mutable_appearance(init_icon, "id_overlay")
	if(light_on)
		. += mutable_appearance(init_icon, "light_overlay")

/obj/item/modular_computer/tablet/pda/attack_ai(mob/user)
	to_chat(user, span_notice("It doesn't feel right to snoop around like that..."))
	return // we don't want ais or cyborgs using a private role tablet

/obj/item/modular_computer/tablet/pda/Initialize(mapload)
	. = ..()
	install_component(new /obj/item/computer_hardware/hard_drive/small)
	install_component(new /obj/item/computer_hardware/battery(src, /obj/item/stock_parts/cell/computer))
	install_component(new /obj/item/computer_hardware/card_slot)

	if(!isnull(default_applications))
		var/obj/item/computer_hardware/hard_drive/small/hard_drive = find_hardware_by_name("solid state drive")
		for(var/datum/computer_file/program/default_programs as anything in default_applications)
			hard_drive.store_file(new default_programs)

	if(loaded_cartridge)
		var/obj/item/computer_hardware/hard_drive/portable/disk = new loaded_cartridge(src)
		install_component(disk)

	if(inserted_item)
		inserted_item = new inserted_item(src)
