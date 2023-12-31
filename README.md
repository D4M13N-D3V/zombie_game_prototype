# Weapons
## Design
Left click is melee.
Right click is shoot.
## Creating a new weapon.
Inside of the `player.gd` script you will find an array of strings that is exported to the inspector. This array of strings correlates to the names of the weapon animation sets on the `AnimatedSprite2D` node on the `player` scene.
```
@export var player_weapons = ["flashlight","knife","handgun","rifle","shotgun"]
var player_current_weapon = 0
```
On the `PlayerSprite` node on the `player` scene you will find a animation set. The names of the animations should match, an example would be handgun_melee_attack, shotgun_melee_attack, rifle_melee_attack, flashlight_melee_attack, and knife_melee_attack.
As you can see all of them are named the same way in order to keep switching weapons easy graphically. The name of the weapon currently equipped is prefixed to the beginning of the base animation name, and then is ran.
