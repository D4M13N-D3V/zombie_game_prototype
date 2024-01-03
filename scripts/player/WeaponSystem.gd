extends Node2D

var current_weapon_configuration:Resource
#var weapons = ["flashlight","knife","handgun","shotgun","rifle"]
var weapons = ["flashlight","knife","handgun", "rifle", "shotgun"]
@export var current_weapon = 0
var current_weapon_animator = null

const BLOOD_IMPACT = preload("res://scenes/BloodImpact.tscn")
const WALL_IMPACT = preload("res://scenes/WallImpact.tscn")

signal weapon_changed(weapon_id)

func _ready():
	current_weapon = 0
	initialize_weapon(weapons[current_weapon])


func initialize_weapon(weapon_id):
	current_weapon_configuration = load("res://resources/player/weapons/"+weapon_id+"/"+weapon_id+".tres")
	if current_weapon_animator != null:
		current_weapon_animator.get_parent().queue_free()
	# Load and instantiate weapon animator scene
	var weapon_animator_scene = load("res://resources/player/weapons/"+weapon_id+"/"+weapon_id+"Animations.tscn")
	
	# Check if the scene is successfully loaded
	if weapon_animator_scene != null:
		current_weapon_animator = weapon_animator_scene.instantiate()
		add_child(current_weapon_animator)
		current_weapon_animator = current_weapon_animator.get_child(0)
		current_weapon_animator.play("idle")
	else:
		print("Failed to load weapon animator scene for weapon ID: ", weapon_id)
	weapon_changed.emit(weapon_id)

func next_weapon():
	if current_weapon == weapons.size() - 1:
		current_weapon = 0
	else:
		current_weapon += 1
	initialize_weapon(weapons[current_weapon])

func previous_weapon():
	current_weapon -= 1
	if current_weapon < 0:
		current_weapon = weapons.size() - 1
	initialize_weapon(weapons[current_weapon])

	

func shoot():
	if(current_weapon_configuration.weapon_ranged_enabled==true):
		current_weapon_animator.play("shoot")
		get_parent().get_node("ZoomCamera").apply_shake(current_weapon_configuration.weapon_ranged_shake_intensity, 2.0)
		if get_parent().get_node("Muzzle").is_colliding():
			if(get_parent().get_node("Muzzle").get_collider().has_method("damage")==true):
				get_parent().get_node("Muzzle").get_collider().damage(current_weapon_configuration.weapon_ranged_damage)
				var impact_location = get_parent().get_node("Muzzle").get_collision_point()
				var impact = BLOOD_IMPACT.instantiate()
				get_parent().get_node("Muzzle").get_collider().add_child(impact)
				impact.global_position = impact_location
			else:
				var impact_location = get_parent().get_node("Muzzle").get_collision_point()
				var impact = WALL_IMPACT.instantiate()
				get_parent().get_node("Muzzle").get_collider().add_child(impact)
				impact.global_position = impact_location

func melee():
	if(current_weapon_configuration.weapon_melee_enabled==true):
		current_weapon_animator.play("melee")
		get_parent().get_node("ZoomCamera").apply_shake(10.0, 4.0)
		var targets = %MeleeZone.get_overlapping_bodies()
		for target in targets:
			if(target is TileMap == false):
				target.damage(current_weapon_configuration.weapon_melee_damage)
				var impact = BLOOD_IMPACT.instantiate()
				target.add_child(impact)
				impact.global_position = target.global_position

func is_line_of_sight_clear(enemy):
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(enemy.global_position, global_position)
	query.exclude = [self]
	var result = space_state.intersect_ray(query)
	if(result.is_empty() or result.is_empty()==false and result["rid"]==enemy.get_rid()):
		return true
	return false
	
func check_magazine():
	pass
	
func reload():
	pass

func is_playing_melee_anim():
	if(current_weapon_animator==null):
		return false
	var animation = current_weapon_animator.current_animation
	if(animation=="melee"):
		return true
	return false
	
func is_playing_shoot_anim():
	if(current_weapon_animator==null):
		return false
	var animation = current_weapon_animator.current_animation
	if(animation=="shoot"):
		return true
	return false
	
func _on_player_player_started_sprinting():
	if(current_weapon_animator!=null and is_playing_melee_anim()==false and is_playing_shoot_anim()==false or current_weapon_animator!=null and current_weapon_animator.is_playing()==false):
		current_weapon_animator.play("sprint")


func _on_player_player_stopped_sprinting():
	if(current_weapon_animator!=null and is_playing_melee_anim()==false and is_playing_shoot_anim()==false or current_weapon_animator!=null and current_weapon_animator.is_playing()==false):
		current_weapon_animator.play("idle")


func _on_player_player_stopped_moving():
	if(current_weapon_animator!=null and is_playing_melee_anim()==false and is_playing_shoot_anim()==false or current_weapon_animator!=null and current_weapon_animator.is_playing()==false):
		current_weapon_animator.play("idle")


func _on_player_player_started_moving():
	if(current_weapon_animator!=null and is_playing_melee_anim()==false and is_playing_shoot_anim()==false or current_weapon_animator!=null and current_weapon_animator.is_playing()==false):
		current_weapon_animator.play("move")
