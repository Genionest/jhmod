local tuning = TUNING
local seg_time = 30
local total_day_time = seg_time * 16
-- fix: amrorwood, spear, hambat, footballhat
tuning.SPEAR_DAMAGE = 34 * .9
tuning.HAMBAT_DAMAGE = 34 * 1.5
tuning.ARMORWOOD_ABSORPTION = .7
tuning.ARMOR_FOOTBALLHAT_ABSORPTION = .7
tuning.ARMOR_RUINSHAT_ABSORPTION = .8
tuning.ARMORRUINS_ABSORPTION = .8
-- Boss has more health
tuning.DEERCLOPS_HEALTH 		= 3000
tuning.DRAGONFLY_HEALTH 		= 3000
tuning.BEARGER_HEALTH 			= 3000
tuning.MOOSE_HEALTH 			= 3000
tuning.MINOTAUR_HEALTH 			= 3000
tuning.TWISTER_HEALTH 			= 3000
tuning.TIGERSHARK_HEALTH 		= 3000
tuning.ANTQUEEN_HEALTH 			= 3500
tuning.PUGALISK_HEALTH 			= 3000
tuning.ANCIENT_HERALD_HEALTH 	= 3000
tuning.WARG_HEALTH = 1000
-- Stronger pigman
tuning.PIG_HEALTH = 350
tuning.WEREPIG_HEALTH = 450
tuning.PIG_GUARD_HEALTH = 400
-- Beefalo easy to ride
tuning.BEEFALO_DOMESTICATION_STARVE_OBEDIENCE = -1/(total_day_time*5)
tuning.BEEFALO_DOMESTICATION_FEED_OBEDIENCE = 0.3
tuning.BEEFALO_DOMESTICATION_OVERFEED_OBEDIENCE = -0.01
tuning.BEEFALO_DOMESTICATION_ATTACKED_BY_PLAYER_OBEDIENCE = -1
tuning.BEEFALO_DOMESTICATION_BRUSHED_OBEDIENCE = 0.8
tuning.BEEFALO_DOMESTICATION_SHAVED_OBEDIENCE = -1
tuning.BEEFALO_DOMESTICATION_LOSE_DOMESTICATION = -1/(total_day_time*20)
tuning.BEEFALO_DOMESTICATION_GAIN_DOMESTICATION = 1/(total_day_time*3)
tuning.BEEFALO_DOMESTICATION_MAX_LOSS_DAYS = 20 -- day
tuning.BEEFALO_DOMESTICATION_OVERFEED_DOMESTICATION = -0.01
tuning.BEEFALO_DOMESTICATION_ATTACKED_DOMESTICATION = 0
tuning.BEEFALO_DOMESTICATION_ATTACKED_OBEDIENCE = -0.01
tuning.BEEFALO_DOMESTICATION_ATTACKED_BY_PLAYER_DOMESTICATION = -0.3
tuning.BEEFALO_DOMESTICATION_BRUSHED_DOMESTICATION = .2
-- tuning.BEEFALO_DOMESTICATION_BRUSHED_DOMESTICATION = (1-(15/20))/15
-- Teeth trap can use more
tuning.TRAP_TEETH_USES = 20