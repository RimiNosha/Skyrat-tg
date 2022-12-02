// All of these are cosmetic, aside from paid_by_hand.

/datum/background_feature/good
	name = "Good Wages"
	description = "You start with more money, and have better paychecks."
	icon_state = "spacecash10000"
	icon_path = 'icons/obj/economy.dmi'

/datum/background_feature/poor
	name = "Poor Wages"
	description = "You start with less money, and have worse paychecks."
	icon_state = "spacecash10"
	icon_path = 'icons/obj/economy.dmi'

/datum/background_feature/average
	name = "Average Wages"
	description = "You start with a normal amount of money, and have normal paychecks."
	icon_state = "spacecash100"
	icon_path = 'icons/obj/economy.dmi'

/datum/background_feature/penniless
	name = "Penniless"
	description = "You start with no money, and have no paychecks. Better get inventive."
	icon_state = "coin_tails"
	icon_path = 'icons/obj/economy.dmi'

/datum/background_feature/lavaland
	name = "Lavaland \"Native\""
	description = "You do not need money, and you instead have the blessing of the necropolis."
	icon_state = "talisman"
	icon_path = 'icons/obj/lavaland/artefacts.dmi'

/// If a background has this, then payment is not given automatically, and flies in along with mail on the shuttle, which the HoP has to divvy out.
/datum/background_feature/paid_by_hand
	name = "Paid by Hand"
	description = "Unfortunately, the HoP has to bring your money in due to your circumstances."
	icon_state = "coin_salad"
	icon_path = 'icons/obj/economy.dmi'
