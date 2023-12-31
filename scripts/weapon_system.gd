extends Node2D

var weapons = ["flashlight","knife","handgun","rifle","shotgun"]
var guns = ["handgun","rifle","shotgun"]
var current_weapon = 0

func _physics_process(_delta):
	gun_switch_logic()
	melee_combat_logic()
	gun_combat_logic()
	gun_switch_logic()
	
func melee_combat_logic():
	if(Input.is_action_just_pressed("melee")):
		%PlayerSprite.play(%WeaponSystem.weapons[%WeaponSystem.current_weapon]+"_melee_attack")

func gun_combat_logic():
	var weapon = weapons[current_weapon]
	if(guns.has(weapon) and Input.is_action_pressed("shoot") and %PlayerSprite.get_animation()!=weapon+"_melee_attack" and %PlayerSprite.get_animation()!=weapon+"_shoot"):
		%PlayerSprite.play(weapon+"_shoot")
		%PlayerCamera.apply_shake(120.0, 2.0)
		get_node("../Muzzle/"+weapon+"_muzzle_sprite").visible=true;
		get_node("../Muzzle/"+weapon+"_muzzle_sprite").play();
		
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
