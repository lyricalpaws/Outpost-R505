/*
This is the decay subsystem that is run once at startup.
These procs are incredibly expensive and should only really be run once. That's why the only run once.

FAIR WARNING: This subsystem is subject to a bunch of R505 tweaks and changes - labeled individually below.
*/


#define WALL_RUST_PERCENT_CHANCE 15

#define FLOOR_DIRT_PERCENT_CHANCE 15
#define FLOOR_BLOOD_PERCENT_CHANCE 1
#define FLOOR_VOMIT_PERCENT_CHANCE 1
#define FLOOR_OIL_PERCENT_CHANCE 5
#define FLOOR_TILE_MISSING_PERCENT_CHANCE 1
#define FLOOR_COBWEB_PERCENT_CHANCE 1

#define NEST_PERCENT_CHANCE 1

#define LIGHT_FLICKER_PERCENT_CHANCE 5

SUBSYSTEM_DEF(decay)
	name = "Decay System"
	flags = SS_NO_FIRE
	init_order = INIT_ORDER_DECAY

	var/list/possible_turfs = list()
	var/list/possible_areas = list()
	var/severity_modifier = 2

	var/list/possible_nests = list(
		/obj/structure/mob_spawner/spiders,
		/obj/structure/mob_spawner/snake,
		// /obj/structure/mob_spawner/bush,
		//I never liked the beehives much
		// /obj/structure/mob_spawner/beehive, 
		/obj/structure/mob_spawner/rats
		)
	
	var/list/area_whitelist = list(
		/area/maintenance,
		/area/hallway,
		/area/commons/dorms/barracks,
		/area/commons/locker,
		/area/commons/vacant_room,
		/area/commons/storage,
		/area/service/electronic_marketing_den,
		/area/service/abandoned_gambling_den,
		/area/service/theater/abandoned,
		/area/service/library/abandoned,
		/area/service/hydroponics,
		/area/engineering,
		/area/construction,
		/area/medical/abandoned,
		/area/security,
		/area/cargo,
		/area/science/storage,
		/area/science/test_area,
		/area/science/robotics,
		/area/science/research/abandoned
		)

/datum/controller/subsystem/decay/Initialize()
	for(var/turf/iterating_turf in world)
		if(!is_station_level(iterating_turf.z))
			continue
		if(istype(iterating_turf, /turf/open/floor/plating/asteroid/snow))
			continue
		possible_turfs += iterating_turf

	for(var/area/iterating_area in world)
		if(!is_station_level(iterating_area.z))
			continue
		possible_areas += iterating_area

	if(!possible_turfs)
		CRASH("SSDecay had no possible turfs to use!")

	//Not sure why it totally disables itself on a coinflip.
	//Note to self - maybe make it proc differently on different maps, or even based on prior rounds?
	/*
	if(prob(50))
		message_admins("SSDecay will not interact with this round.")
		return ..()
	*/

	//Redoing how it interacts with different depts a bit.

	//severity_modifier = rand(1, 4)

	//message_admins("SSDecay severity modifier set to [severity_modifier]")

	
	message_admins("Executing Decay system at [severity_modifier]")
	grungeify()
	
	return ..()

//R505 decay iterators
//This is just a temporary measure, I'll make a better, more organized decay setup later.
/datum/controller/subsystem/decay/proc/grungeify()
	for(var/area/iterating_area in possible_areas)
		if(is_type_in_list(iterating_area, area_whitelist))
			for(var/turf/open/floor/iterating_floor in iterating_area)
				if(!istype(iterating_floor, /turf/open/floor/plating))
					if(prob(FLOOR_TILE_MISSING_PERCENT_CHANCE * severity_modifier) && prob(60))
						iterating_floor.break_tile_to_plating()

				if(prob(FLOOR_DIRT_PERCENT_CHANCE * severity_modifier))
					new /obj/effect/decal/cleanable/dirt(iterating_floor)

				if(prob(FLOOR_DIRT_PERCENT_CHANCE * severity_modifier))
					new /obj/effect/decal/cleanable/dirt(iterating_floor)

				if(!istype(iterating_area, /area/hallway))
					if(prob(FLOOR_BLOOD_PERCENT_CHANCE * severity_modifier / 4))
						var/obj/effect/decal/cleanable/blood/spawned_blood = new (iterating_floor)
						spawned_blood.dry()
						if(!iterating_floor.Enter(spawned_blood))
							qdel(spawned_blood)

					if(prob(FLOOR_OIL_PERCENT_CHANCE * severity_modifier / 2))
						var/obj/effect/decal/cleanable/oil/spawned_oil = new (iterating_floor)
						if(!iterating_floor.Enter(spawned_oil))
							qdel(spawned_oil)

			for(var/turf/closed/iterating_wall in possible_turfs)
				if(prob(WALL_RUST_PERCENT_CHANCE * severity_modifier))
					iterating_wall.AddElement(/datum/element/rust)

		for(var/obj/machinery/light/iterating_light in iterating_area)
			if(prob(LIGHT_FLICKER_PERCENT_CHANCE))
				iterating_light.start_flickering()

	





//Skyrat decay iterators unused for now
/datum/controller/subsystem/decay/proc/do_common()
	for(var/turf/open/floor/iterating_floor in possible_turfs)
		if(!istype(iterating_floor, /turf/open/floor/plating))
			if(prob(FLOOR_TILE_MISSING_PERCENT_CHANCE * severity_modifier) && prob(60))
				iterating_floor.break_tile_to_plating()

		if(prob(FLOOR_DIRT_PERCENT_CHANCE * severity_modifier))
			new /obj/effect/decal/cleanable/dirt(iterating_floor)

		if(prob(FLOOR_DIRT_PERCENT_CHANCE * severity_modifier))
			new /obj/effect/decal/cleanable/dirt(iterating_floor)

	for(var/turf/closed/iterating_wall in possible_turfs)
		if(prob(WALL_RUST_PERCENT_CHANCE * severity_modifier))
			iterating_wall.AddElement(/datum/element/rust)

/datum/controller/subsystem/decay/proc/do_maintenance()
	for(var/area/maintenance/iterating_maintenance in possible_areas)
		for(var/turf/open/iterating_floor in iterating_maintenance)
			if(prob(FLOOR_BLOOD_PERCENT_CHANCE * severity_modifier))
				var/obj/effect/decal/cleanable/blood/spawned_blood = new (iterating_floor)
				spawned_blood.dry()
				if(!iterating_floor.Enter(spawned_blood))
					qdel(spawned_blood) //No blood under windows.

			if(prob(FLOOR_COBWEB_PERCENT_CHANCE * severity_modifier))
				var/obj/structure/spider/stickyweb/spawned_web = new (iterating_floor)
				if(!iterating_floor.Enter(spawned_web))
					qdel(spawned_web)

			if(prob(NEST_PERCENT_CHANCE * severity_modifier) && prob(50))
				var/spawner_to_spawn = pick(possible_nests)
				var/obj/structure/mob_spawner/spawned_spawner = new spawner_to_spawn (iterating_floor)
				if(!iterating_floor.Enter(spawned_spawner))
					qdel(spawned_spawner)

		for(var/obj/machinery/light/iterating_light in iterating_maintenance)
			if(prob(LIGHT_FLICKER_PERCENT_CHANCE))
				iterating_light.start_flickering()

/datum/controller/subsystem/decay/proc/do_engineering()
	for(var/area/engineering/iterating_engineering in possible_areas)
		for(var/turf/open/iterating_floor in iterating_engineering)
			if(prob(FLOOR_BLOOD_PERCENT_CHANCE * severity_modifier))
				var/obj/effect/decal/cleanable/blood/spawned_blood = new (iterating_floor)
				spawned_blood.dry()
				if(!iterating_floor.Enter(spawned_blood))
					qdel(spawned_blood)

			if(prob(FLOOR_OIL_PERCENT_CHANCE * severity_modifier))
				var/obj/effect/decal/cleanable/oil/spawned_oil = new (iterating_floor)
				if(!iterating_floor.Enter(spawned_oil))
					qdel(spawned_oil)

/datum/controller/subsystem/decay/proc/do_medical()
	for(var/area/medical/iterating_medical in possible_areas)
		for(var/turf/open/iterating_floor in iterating_medical)
			if(prob(FLOOR_BLOOD_PERCENT_CHANCE * severity_modifier))
				var/obj/effect/decal/cleanable/blood/spawned_blood = new (iterating_floor)
				spawned_blood.dry()
				if(!iterating_floor.Enter(spawned_blood))
					qdel(spawned_blood)

			if(prob(FLOOR_VOMIT_PERCENT_CHANCE * severity_modifier))
				var/obj/effect/decal/cleanable/vomit/spawned_vomit = new (iterating_floor)
				if(!iterating_floor.Enter(spawned_vomit))
					qdel(spawned_vomit)

		if(is_type_in_list(iterating_medical, list(/area/medical/coldroom, /area/medical/morgue, /area/medical/psychology)))
			for(var/obj/machinery/light/iterating_light in iterating_medical)
				if(prob(LIGHT_FLICKER_PERCENT_CHANCE))
					iterating_light.start_flickering()
