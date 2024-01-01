extends Resource
class_name WeaponConfiguration

#General Settings
@export var weapon_id = "weapon"
@export var weapon_name = "New Weapon"
@export var weapon_description = "A new weapon that is being added."

#Movement Settings
@export var weapon_sway_speed:float = 1.0

#Animation Settings
@export var weapon_melee_animation  = "_melee"
@export var weapon_shoot_animation  = "_shoot"
@export var weapon_reload_animation = "_reload"
@export var weapon_walk_animation = "_walk"
@export var weapon_sprint_animation = "_sprint"
@export var weapon_animated_sprite:Resource
@export var weapon_muzzle_flash:Resource
@export var weapon_muzzle_offset:Vector2 = Vector2(0,0)

#Melee Settings
@export var weapon_melee_enabled:bool = false
@export var weapon_melee_range:float = 0.0
@export var weapon_melee_damage:float = 0.0
@export var weapon_melee_aoe:bool = false

#Ranged Settings
@export var weapon_ranged_enabled:bool = false
@export var weapon_ranged_capacity:int = 0
@export var weapon_ranged_maximum:int = 0
@export var weapon_ranged_damage:float = 0.0
@export var weapon_ranged_accuracy:float = 0.0
@export var weapon_ranged_bullet_rate:int = 1
