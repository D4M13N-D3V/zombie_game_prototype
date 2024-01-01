extends Node2D

@export var weapons = ["Flashlight","Knife","Handgun","Rifle","Shotgun"]
@export var guns = ["Handgun","Rifle","Shotgun"]

@export var current_weapon = 0

@export var pistol_ammo = 7
@export var pistol_capacity = 7
@export var pistol_current = 7

@export var shotgun_ammo = 5
@export var shotgun_capacity = 5
@export var shotgun_current = 5

@export var rifle_ammo = 30
@export var rifle_capacity = 30
@export var rifle_current = 30

func _physics_process(_delta):
	gun_switch_logic()
	melee_combat_logic()
	gun_combat_logic()
	#gun_reload_logic()
	gun_switch_logic()
	
func melee_combat_logic():
	if(Input.is_action_just_pressed("melee")):
		%PlayerSprite.play(%WeaponSystem.weapons[%WeaponSystem.current_weapon]+"_melee_attack")

# func gun_reload_login():
#	if(guns.has(weapon) and Input.is_action_just_pressed("reload") and %PlayerSprite.get_animation()!=weapon+"_melee_attack" and %PlayerSprite.get_animation()!=weapon+"_shoot"):
		

func gun_combat_logic():
	var weapon = weapons[current_weapon]
	if(guns.has(weapon) and Input.is_action_just_pressed("shoot") and %PlayerSprite.get_animation()!=weapon+"_melee_attack" and %PlayerSprite.get_animation()!=weapon+"_shoot"):
		%PlayerSprite.play(weapon+"_shoot")
		%PlayerCamera.apply_shake(120.0, 2.0)
		get_node("../Muzzle/"+weapon+"_muzzle_sprite").visible=true;
		get_node("../Muzzle/"+weapon+"_muzzle_sprite").play();
		if(%MuzzleCast.is_colliding()==true):
			if(%MuzzleCast.get_collider() is TileMap):
				print("TILE MAP!")
			else:
				print(%MuzzleCast.get_collider().get_name())
		
func _on_player_sprite_animation_finished():
	var animation = %PlayerSprite.get_animation()
	if(animation==weapons[current_weapon]+"_melee_attack" or animation==weapons[current_weapon]+"_shoot"):
		%PlayerSprite.play(weapons[current_weapon]+"_idle")

func _on_player_sprite_animation_looped():
	var animation = %PlayerSprite.get_animation()
	if(animation==weapons[current_weapon]+"_melee_attack" or animation==weapons[current_weapon]+"_shoot"):
		%PlayerSprite.play(weapons[current_weapon]+"_idle")
		
func gun_switch_logic():
	if(Input.is_action_just_pressed("next_weapon")):
		if(current_weapon+1==weapons.size()):
			current_weapon=0
		else:
			current_weapon = current_weapon+1
		%PlayerSprite.play(weapons[current_weapon]+"_idle")
	if(Input.is_action_just_pressed("previous_weapon")):
		current_weapon = current_weapon-1
		if(current_weapon-1<0):
			current_weapon=weapons.size()-1
		else:
			current_weapon = current_weapon-1
		%PlayerSprite.play(weapons[current_weapon]+"_idle")
