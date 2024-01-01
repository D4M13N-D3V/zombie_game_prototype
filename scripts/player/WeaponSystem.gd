extends Node2D

var current_weapon_configuration:Resource
var weapons = ["flashlight","knife","handgun","shotgun","rifle"]
var current_weapon = 0
var current_weapon_animator = null

signal weapon_changed(weapon_id)

func _ready():
	current_weapon = 0
	initialize_weapon(weapons[current_weapon])


func initialize_weapon(weapon_id):
	current_weapon_configuration = load("res://resources/player/weapons/"+weapon_id+"/"+weapon_id+".tres")
	if current_weapon_animator != null:
		current_weapon_animator.queue_free()
	# Load and instantiate weapon animator scene
	var weapon_animator_scene = load("res://resources/player/weapons/"+weapon_id+"/"+weapon_id+"Animations.tscn")
	
	# Check if the scene is successfully loaded
	if weapon_animator_scene != null:
		current_weapon_animator = weapon_animator_scene.instantiate()
		current_weapon_animator.play(weapon_id+"_idle")
		add_child(current_weapon_animator)
	else:
		print("Failed to load weapon animator scene for weapon ID: ", weapon_id)
	weapon_changed.emit(weapon_id)


func next_weapon():
	if(current_weapon+1==weapons.size()):
		current_weapon=0
	else:
		current_weapon = current_weapon+1
	initialize_weapon(weapons[current_weapon])

func previous_weapon():
	current_weapon = current_weapon-1
	if(current_weapon-1<0):
		current_weapon=weapons.size()-1
	else:
		current_weapon = current_weapon-1
	initialize_weapon(weapons[current_weapon])
	

func shoot():
	if(current_weapon_configuration.weapon_ranged_enabled==true):
		current_weapon_animator.play(weapons[current_weapon]+"_shoot")
		%ZoomCamera.apply_shake(50.0, 2.0)
		if %Muzzle.is_colliding() and %Muzzle.get_collider().has_method("damage"):
			%Muzzle.get_collider().damage(current_weapon_configuration.weapon_ranged_damage)

func melee():
	if(current_weapon_configuration.weapon_melee_enabled==true):
		current_weapon_animator.play(weapons[current_weapon]+"_melee")
		%ZoomCamera.apply_shake(10.0, 4.0)
		#MELEE DAMAGE LOGIC

func check_magazine():
	pass
	
func reload():
	pass

func is_playing_melee_anim():
	var animation = current_weapon_animator.get_animation()
	if(animation==weapons[current_weapon]+"_melee"):
		return true
	return false
	
func is_playing_shoot_anim():
	var animation = current_weapon_animator.get_animation()
	if(animation==weapons[current_weapon]+"_shoot"):
		return true
	return false
	
func _on_player_player_started_sprinting():
	if(is_playing_melee_anim()==false and is_playing_shoot_anim()==false or current_weapon_animator.is_playing()==false):
		current_weapon_animator.play(weapons[current_weapon]+"_sprint")


func _on_player_player_stopped_sprinting():
	if(is_playing_melee_anim()==false and is_playing_shoot_anim()==false or current_weapon_animator.is_playing()==false):
		current_weapon_animator.play(weapons[current_weapon]+"_idle")


func _on_player_player_stopped_moving():
	if(is_playing_melee_anim()==false and is_playing_shoot_anim()==false or current_weapon_animator.is_playing()==false):
		current_weapon_animator.play(weapons[current_weapon]+"_idle")


func _on_player_player_started_moving():
	if(is_playing_melee_anim()==false and is_playing_shoot_anim()==false or current_weapon_animator.is_playing()==false):
		current_weapon_animator.play(weapons[current_weapon]+"_move")
