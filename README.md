# Sato's Corpse Loot Fix

A mod for the game Battle Brothers ([Steam](https://store.steampowered.com/app/365360/Battle_Brothers/), [GOG](https://www.gog.com/game/battle_brothers), [Developer Site](http://battlebrothersgame.com/buy-battle-brothers/)).

## Table of contents

-   [Features](#features)
-   [Requirements](#requirements)
-   [Installation](#installation)
-   [Uninstallation](#uninstallation)
-   [Details](#details)
-   [Compatibility](#compatibility)
-   [Credits](#credits)

## Features

Battlefield loot drops in bbros are largely tied to the existence of a particular unit's corpse: when the battle is over, corpses are scanned for lootable items and those show up in the post-battle screen. To spawn a corpse, the game will first look at the slain unit's tile, then adjacent unoccupied tiles, then lastly the killer's tile (if the killer was adjacent). If all of these tiles already have corpses, then **a new corpse will not spawn** and non-droppable items (e.g. armor) on it will be lost. Additional loot, such as crafting components from beasts, will also not drop.

This is arguably not a "bug", but it's my belief that it is unintended (especially when considering famed items and interactions with the Blacksmith retinue) and promotes tedious metagaming counter to the spirit of the game's other mechanics.

This mod "fixes" this problem by keeping track of unspawned corpses and adding their loot to the post-battle screen.

## Requirements

1) [Modding Script Hooks](https://www.nexusmods.com/battlebrothers/mods/42) (v20 or later)

## Installation

1) Download the mod from the [releases page](https://github.com/jcsato/sato_corpse_loot_fix/releases/latest)
2) Without extracting, put the `sato_corpse_loot_fix_*.zip` file in your game's data directory
    1) For Steam installations, this is typically: `C:\Program Files (x86)\Steam\steamapps\common\Battle Brothers\data`
    2) For GOG installations, this is typically: `C:\Program Files (x86)\GOG Galaxy\Games\Battle Brothers\data`

## Uninstallation

1) Remove the relevant `sato_corpse_loot_fix_*.zip` file from your game's data directory

## Details

The mod works in the following way:
1) On actor death, check to see if there are any valid tiles for spawning the actor's corpse
2) If there aren't, find an unoccupied tile starting from the bottom right corner of the map
3) Spawn the corpse on that tile, allowing all normal logic to execute (e.g. drop beast components if applicable)
4) Move all droppable items (e.g. weapons) from the corner tile to the tile the actor was killed on
5) Add the corpse to an in-memory list and remove it from the corner tile (no surprise corner zombie resurrections)
6) After the battle, take all the corpses from the above list and add their items to the post-battle loot

## Compatibility

This mod should be compatible with any other mods and be safe to add or remove mid-campaign.

## Credits

Special thanks to Calandro for the initial discovery of this bug/mechanic and for input on how to best fix it.
