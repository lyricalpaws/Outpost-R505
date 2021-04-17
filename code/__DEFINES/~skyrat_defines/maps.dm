//GLOBAL FILE FOR DECLARING CUSTOM ZLEVEL TRAITS

#define ZTRAITS_ROCKPLANET list(\
	ZTRAIT_MINING = TRUE, \
	ZTRAIT_ACIDRAIN = TRUE, \
	ZTRAIT_LAVA_RUINS = TRUE, \
	ZTRAIT_BOMBCAP_MULTIPLIER = 2, \
	ZTRAIT_BASETURF = /turf/open/floor/plating/asteroid)

#define ZTRAITS_ICEMOONSKYRAT list(\
	ZTRAIT_MINING = TRUE, \
	ZTRAIT_SNOWSTORM = TRUE, \
	ZTRAIT_ICE_RUINS = TRUE, \
	ZTRAIT_ICE_RUINS_UNDERGROUND = TRUE, \
	ZTRAIT_BOMBCAP_MULTIPLIER = 2, \
	ZTRAIT_BASETURF = /turf/open/lava/plasma/ice_moon) //Remove ZTRAIT_ICE_RUINS if anyone makes multi-z icemoon ruins, as it'll cause problems here.
