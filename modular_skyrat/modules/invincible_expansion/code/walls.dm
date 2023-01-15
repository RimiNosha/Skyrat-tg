#define INVINCIBLE_WALL(pth) \
 \
##pth/invincible/dismantle_wall(devastated, explode) { return } \
 \
##pth/invincible/break_wall() { return } \
 \
##pth/invincible/devastate_wall() { return } \
 \
##pth/invincible/ex_act(severity, target) { return } \
 \
##pth/invincible/blob_act(obj/structure/blob/attacking_blob) { return } \
 \
##pth/invincible/attack_hulk(mob/living/carbon/user) { return } \
 \
##pth/invincible/attackby(obj/item/C, mob/user, params) { return } \
 \
##pth/invincible/narsie_act(force, ignore_mobs, probability) { return } \
 \
##pth/invincible/rust_heretic_act() { return } \
 \
##pth/invincible/rcd_act(mob/user, obj/item/construction/rcd/the_rcd, passed_mode) { return FALSE } \
 \
##pth/invincible/TerraformTurf(path, new_baseturf, flags, defer_change = FALSE, ignore_air = FALSE) { return } \
 \
##pth/invincible/acid_act(acidpwr, acid_volume, acid_id) { return FALSE } \
 \
##pth/invincible/Melt() { to_be_destroyed = FALSE; return src } \
 \
##pth/invincible/singularity_act() { return } \
 \
##pth/invincible {\
	desc = "Effectively impervious to conventional methods of destruction."; \
	explosive_resistance = 100; \
	rcd_memory = null; \
	can_engrave = FALSE; }\
##pth/invincible

INVINCIBLE_WALL(/turf/closed/wall/r_wall)
