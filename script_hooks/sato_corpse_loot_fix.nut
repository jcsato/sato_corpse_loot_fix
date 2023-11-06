::Const.SCLF <- {
	UnspawnedCorpses = []
};

::mods_hookExactClass("states/tactical_state", function(ts) {
	local gatherLoot = ::mods_getMember(ts, "gatherLoot");

	::mods_override(ts, "gatherLoot", function() {
		gatherLoot();

		local additionalLoot = [];
		foreach (corpse in ::Const.SCLF.UnspawnedCorpses) {
			if (corpse.Items != null) {
				local items = corpse.Items.getAllItems();

				foreach (item in items) {
					if (!isScenarioMode() && m.StrategicProperties != null && m.StrategicProperties.IsArenaMode && item.getLastEquippedByFaction() != 1)
						continue;

					item.onCombatFinished();
					if (!item.isChangeableInBattle() && item.isDroppedAsLoot())
						{
							if (item.getCondition() > 1 && item.getConditionMax() > 1 && item.getCondition() > item.getConditionMax() * 0.66 && Math.rand(1, 100) <= 50) {
								local c = Math.minf(item.getCondition(), Math.rand(Math.maxf(10, item.getConditionMax() * 0.35), item.getConditionMax()));
								item.setCondition(c);
							}

							item.removeFromContainer();
							additionalLoot.push(item);
						}
				}
			}
		}

		::Const.SCLF.UnspawnedCorpses = [];
		additionalLoot.extend(m.CombatResultLoot.getItems());
		m.CombatResultLoot.assign(additionalLoot);
		m.CombatResultLoot.sort();
	});
});

/**
	Some things worth noting here:
	- This hook will run multiple times, because hookDescendants hooks *all* descendants. i.e. not just wardog.nut, but
		human.nut AND bandit_raider.nut AND bandit_raider_low.nut. The reason that doesn't cause issues is because of
		the `if (_tile == null)` check in the hook. Swordmasters define their own onDeath for achievement purposes.
		When you kill a Swordmaster, it runs the onDeath function below, and passes in `_tile` as some new unoccupied
		tile. Then it calls human's onDeath, which *also* runs the onDeath function below, but because `_tile` no
		longer equals `null`, it just skips the extra logic and call onDeath as normal (which, for humans, spawns the
		corpse and then calls actor's onDeath).
	- Not all INDIRECT descendants of actor define onDeath. That's why the `if ("onDeath" in a)` check is necessary.
		Without it, trying to reference/overwrite a.onDeath will error when evaluating e.g. councilman.nut.
	- All DIRECT descendants of actor define onDeath. actor.onDeath doesn't actually do anything, which means that if
		a corpse is supposed to be spawned (and you'd only ever spawn a corpse on death. . .right?) actor descendants
		need to define their own, at which point hookDescendants below will catch it. This is important because
		actor.onDeath IS NOT HOOKED by the below - *only* actor descendants are. If I needed to run this function on
		actor descendants that did not define their own onDeath, I'd need to additionally `hookExactClass` actor.nut to
		run the same code as below.
 */
::mods_hookDescendants("entity/tactical/actor", function(a) {
	if ("onDeath" in a) {
		local onDeath = a.onDeath;

		a.onDeath = function(_killer, _skill, _tile, _fatalityType) {
			if (_tile == null) {
				local unoccupiedTile = getUnoccupiedTile(this);
				if (unoccupiedTile != null) {
					onDeath(_killer, _skill, unoccupiedTile, _fatalityType);

					if (unoccupiedTile.Properties.has("Corpse")) {
						local myTile = getTile();
						if (myTile != null) {
							local itemsToMove = unoccupiedTile.Items;
							foreach (index, item in itemsToMove) {
								myTile.Items.push(item);
								myTile.IsContainingItems = true;
								item.m.Tile = myTile;
								unoccupiedTile.Items.remove(index);
							}
						}
						::Const.SCLF.UnspawnedCorpses.push(unoccupiedTile.Properties.get("Corpse"));
						Tactical.Entities.removeCorpse(unoccupiedTile);
						unoccupiedTile.Properties.remove("Corpse");
					}
					unoccupiedTile.clear();

					return;
				}
			}

			onDeath(_killer, _skill, _tile, _fatalityType);
		}
	}

	function getUnoccupiedTile(_actor) {
		if (!actor.isPlacedOnMap())
			return null;

		local size = Tactical.getMapSize();
		for (local y = size.Y - 1; y >= 0; --y) {
			for (local x = size.X - 1; x >= 0; --x) {
				local tile = Tactical.getTileSquare(x, y);
				if (!tile.Properties.has("Corpse")) {
					return tile;
				}
			}
		}

		return null;
	}
});
