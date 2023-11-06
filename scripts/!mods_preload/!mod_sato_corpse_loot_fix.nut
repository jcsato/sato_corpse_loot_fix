::mods_registerMod("sato_corpse_loot_fix", 1.0, "Sato's Corpse Loot Fix");

::mods_queue("sato_corpse_loot_fix", null, function() {
	::include("script_hooks/sato_corpse_loot_fix");
});
