/obj/item/organ/external/genital/breasts/build_from_dna(datum/dna/DNA, associated_key)
	. = ..()
	var/breasts_capacity = 0
	var/size = 0.5
	if(DNA.features["breasts_size"] > 0)
		size = DNA.features["breasts_size"]

	switch(genital_type)
		if("pair")
			breasts_capacity = 2
		if("quad")
			breasts_capacity = 2.5
		if("sextuple")
			breasts_capacity = 3
	internal_fluids = new /datum/reagents(size * breasts_capacity * 60)
