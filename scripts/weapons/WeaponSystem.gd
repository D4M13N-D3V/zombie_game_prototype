extends Node2D

@export var IsPlayer = true
@export var current_weapon = 0
@export var current_weapon_configuration:Resource
@export var weapons = ["knife"]
@export var ammo = {}
@export var loadedAmmo = {}

#var weapons = ["flashlight","knife","handgun","shotgun","rifle"]

var current_weapon_animator = null

const BLOOD_IMPACT = preload("res://scenes/BloodImpact.tscn")
const WALL_IMPACT = preload("res://scenes/WallImpact.tscn")

signal weapon_changed(weapon_id)
signal ammo_changed(amount, maximum)
signal magazine_changed(amount,maximum)

func _ready():
	current_weapon = 0
	initialize_weapon(weapons[current_weapon])
	%RangedTimer.connect("timeout",Callable(self,"_reset_ranged_cooldown"))
	%MeleeTimer.connect("timeout", Callable(self,"_reset_melee_cooldown"))
	%RangedTimer.stop()
	%MeleeTimer.stop()

func _reset_ranged_cooldown():
	%RangedTimer.stop()

func _reset_melee_cooldown():
	%MeleeTimer.stop()

func _process(_delta):
	if(IsPlayer==true and GameManager.ui_open==false):
		melee_logic()
		shoot_logic()
		reload_logic()
		weapon_switch_logic()
	
func weapon_switch_logic():
	if(Input.is_action_just_pressed("next_weapon")):
		next_weapon()
	if(Input.is_action_just_pressed("previous_weapon")):
		previous_weapon()

func melee_logic():
	if(Input.is_action_just_pressed("melee")):
		melee()

func shoot_logic():
	if(Input.is_action_just_pressed("shoot") and current_weapon_configuration.weapon_ranged_automatic==false):
		shoot()
	elif(Input.is_action_pressed("shoot") and current_weapon_configuration.weapon_ranged_automatic==true):
		shoot()
		
func reload_logic():
	if(Input.is_action_just_pressed("reload")):
		reload()

func add_weapon(weapon_id):
	weapons.append(weapon_id)
	
func remove_weapon(weapon_id):
	weapons.erase(weapon_id)

func initialize_weapon(weapon_id):
	current_weapon_configuration = load("res://resources/weapons/"+weapon_id+"/"+weapon_id+".tres")
	if current_weapon_animator != null:
		current_weapon_animator.get_parent().queue_free()
	# Load and instantiate weapon animator scene
	var weapon_animator_scene = load("res://resources/weapons/"+weapon_id+"/"+weapon_id+"Animations.tscn")
	
	# Check if the scene is successfully loaded
	if weapon_animator_scene != null:
		current_weapon_animator = weapon_animator_scene.instantiate()
		add_child(current_weapon_animator)
		current_weapon_animator = current_weapon_animator.get_child(0)
		current_weapon_animator.play("idle")
	else:
		print("Failed to load weapon animator scene for weapon ID: ", weapon_id)
	
	if(ammo.has(weapon_id)==false):
		ammo[weapon_id] = 0
		loadedAmmo[weapon_id] = 0
		ammo_changed.emit(0, current_weapon_configuration.weapon_ranged_maximum)
		magazine_changed.emit(0, current_weapon_configuration.weapon_ranged_capacity)
	weapon_changed.emit(weapon_id)

func next_weapon():
	if current_weapon == weapons.size() - 1:
		current_weapon = 0
	else:
		current_weapon += 1
	initialize_weapon(weapons[current_weapon])
	ammo_changed.emit(ammo[weapons[current_weapon]], current_weapon_configuration.weapon_ranged_maximum)
	magazine_changed.emit(loadedAmmo[weapons[current_weapon]], current_weapon_configuration.weapon_ranged_capacity)

func previous_weapon():
	current_weapon -= 1
	if current_weapon < 0:
		current_weapon = weapons.size() - 1
	initialize_weapon(weapons[current_weapon])
	ammo_changed.emit(ammo[weapons[current_weapon]], current_weapon_configuration.weapon_ranged_maximum)
	magazine_changed.emit(loadedAmmo[weapons[current_weapon]], current_weapon_configuration.weapon_ranged_capacity)

func reload():
	if(current_weapon_configuration.weapon_ranged_enabled==true and ammo[weapons[current_weapon]]>0 ):
		current_weapon_animator.play("reload")
		var capacity = current_weapon_configuration.weapon_ranged_capacity
		var current = ammo[weapons[current_weapon]]
		if(capacity>current):
			ammo[weapons[current_weapon]] = 0
			loadedAmmo[weapons[current_weapon]] = current
		elif(loadedAmmo[weapons[current_weapon]]<capacity):
			var difference = capacity-loadedAmmo[weapons[current_weapon]]
			ammo[weapons[current_weapon]] = current-difference
			loadedAmmo[weapons[current_weapon]] = capacity
		else:
			ammo[weapons[current_weapon]] = ammo[weapons[current_weapon]] - capacity
			loadedAmmo[weapons[current_weapon]] = capacity
		ammo_changed.emit(ammo[weapons[current_weapon]], current_weapon_configuration.weapon_ranged_maximum)
		magazine_changed.emit(loadedAmmo[weapons[current_weapon]], current_weapon_configuration.weapon_ranged_capacity)

func shoot():
	if(current_weapon_configuration.weapon_ranged_enabled==true and loadedAmmo[weapons[current_weapon]]>0 and %RangedTimer.is_stopped()==true and current_weapon_animator.current_animation!="reload"):
		loadedAmmo[weapons[current_weapon]] = loadedAmmo[weapons[current_weapon]]-1
		current_weapon_animator.play("shoot")
		%RangedTimer.start(current_weapon_configuration.weapon_ranged_cooldown)
		get_parent().get_node("ZoomCamera").apply_shake(current_weapon_configuration.weapon_ranged_shake_intensity, 2.0)
		if %Muzzle.is_colliding():
			if(%Muzzle.get_collider().has_method("damage")==true):
				%Muzzle.get_collider().damage(current_weapon_configuration.weapon_ranged_damage)
				var impact_location = %Muzzle.get_collision_point()
				var impact = BLOOD_IMPACT.instantiate()
				get_parent().get_parent().get_parent().add_child(impact)
				impact.global_position =impact_location
			else:
				var impact_location = %Muzzle.get_collision_point()
				var impact = WALL_IMPACT.instantiate()
				get_parent().get_parent().get_parent().add_child(impact)
				impact.global_position = impact_location
		magazine_changed.emit(loadedAmmo[weapons[current_weapon]], current_weapon_configuration.weapon_ranged_capacity)
		
func melee():
	if(current_weapon_configuration.weapon_melee_enabled==true and %MeleeTimer.is_stopped()==true):
		%MeleeTimer.start(current_weapon_configuration.weapon_melee_cooldown)
		current_weapon_animator.play("melee")
		get_parent().get_node("ZoomCamera").apply_shake(100.0, 4.0)
		var targets = %MeleeZone.get_overlapping_bodies()
		for target in targets:
			if(target is TileMap == false):
				target.damage(current_weapon_configuration.weapon_melee_damage)
				var impact = BLOOD_IMPACT.instantiate()
				get_parent().get_parent().get_parent().add_child(impact)
				impact.global_position = target.global_position
				impact.global_scale = Vector2(0.19,0.19)

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
	if(animation=="shoot" or animation=="reload"):
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


func _on_inventory_weapon_equipped(weapon_id, item):
	if(weapons[current_weapon]==weapon_id):
		next_weapon()
	add_weapon(weapon_id)
	
func _on_inventory_weapon_unequipped(weapon_id, item):
	if(weapons[current_weapon]==weapon_id):
		next_weapon()
	remove_weapon(weapon_id)


func _on_inventory_item_used(item_id):
	if(item_id=="handgun_ammo"):
		if(ammo.has("handgun")==false):
			ammo["handgun"] = 0
			loadedAmmo["handgun"] = 0
		ammo["handgun"] = ammo["handgun"]+7
		ammo_changed.emit(ammo[weapons[current_weapon]], current_weapon_configuration.weapon_ranged_maximum)
		magazine_changed.emit(loadedAmmo[weapons[current_weapon]], current_weapon_configuration.weapon_ranged_capacity)
	elif(item_id=="shotgun_ammo"):
		if(ammo.has("shotgun")==false):
			ammo["shotgun"] = 0
			loadedAmmo["shotgun"] = 0
		ammo["shotgun"] = ammo["shotgun"]+7
		ammo_changed.emit(ammo[weapons[current_weapon]], current_weapon_configuration.weapon_ranged_maximum)
		magazine_changed.emit(loadedAmmo[weapons[current_weapon]], current_weapon_configuration.weapon_ranged_capacity)
	elif(item_id=="rifle_ammo"):
		if(ammo.has("rifle")==false):
			ammo["rifle"] = 0
			loadedAmmo["rifle"] = 0
		ammo["rifle"] = ammo["rifle"]+7
		ammo_changed.emit(ammo[weapons[current_weapon]], current_weapon_configuration.weapon_ranged_maximum)
		magazine_changed.emit(loadedAmmo[weapons[current_weapon]], current_weapon_configuration.weapon_ranged_capacity)
