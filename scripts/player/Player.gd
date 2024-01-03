extends Character
class_name Player

signal player_started_moving
signal player_stopped_moving
signal player_started_sprinting
signal player_stopped_sprinting
signal player_sprint_changed(maximum,current)

signal player_turned_flashlight_on
signal player_turned_flashlight_off

func _ready():
	heal(1)
	set("character_movement_speed",8000.0)
	set("character_sprint_use_modifier",false)
	set("character_sprint_modifier",2.0)
	set("character_sprint_maximum",100.0)
	set("character_sprint_drain_rate",2.0)
	set("character_sprint_regen_rate",5.0)
	set("character_sprinting",false)
	set("character_current_sprint",100.0)

func _process(delta):
	look_at_mouse()
	movement_logic(delta)
	vision_logic()
	melee_logic()
	shoot_logic()
	weapon_switch_logic()
	if(%CharacterAnimationPlayer.is_playing()==false):
		%CharacterAnimationPlayer.play("Idle")

# Weapon Switch
func weapon_switch_logic():
	if(Input.is_action_just_pressed("next_weapon")):
		%WeaponSystem.next_weapon()
	if(Input.is_action_just_pressed("previous_weapon")):
		%WeaponSystem.previous_weapon()
	
	
# Combat Logic
func melee_logic():
	if(Input.is_action_just_pressed("melee")):
		%WeaponSystem.melee()
func shoot_logic():
	if(Input.is_action_just_pressed("shoot")):
		%WeaponSystem.shoot()

# Vision Cone Logic
func vision_logic():
	var zombies = %Vision.get_overlapping_bodies()
	for zombie in zombies:
		if(zombie is TileMap == false and is_line_of_sight_clear(zombie)):
			zombie.show()

func is_line_of_sight_clear(enemy):
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(enemy.global_position, global_position)
	query.exclude = [self]
	var result = space_state.intersect_ray(query)
	if(result.is_empty() or result.is_empty()==false and result["rid"]==enemy.get_rid()):
		return true
	return false

func _on_vision_body_shape_exited(_body_rid, body, _body_shape_index, _local_shape_index):
	if(body is TileMap == false):
		if(body!=null):
			body.hide()
		

# Movement Logic
func movement_logic(delta):
	
	if(Input.is_action_just_pressed("sprint")):
		%ZoomCamera._set_zoom_level(%ZoomCamera._zoom_level*2)
		
	if(Input.is_action_just_released("sprint")):
		%ZoomCamera._set_zoom_level(%ZoomCamera._zoom_level*0.5)
	
	if(Input.is_action_pressed("sprint") and get("character_current_sprint")>0):
		set("character_sprinting",true)
	else:
		set("character_sprinting",false)
		
	var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if(get("character_sprinting")):
		velocity = direction * get("character_movement_speed") * delta *1.5
		if(velocity.length()>0.0):
			var sprint = clamp(get("character_current_sprint") -get("character_sprint_drain_rate") * delta, 0, get("character_sprint_maximum"))
			set("character_current_sprint",sprint)
			player_sprint_changed.emit(get("character_sprint_maximum"),get("character_current_sprint"))
	else:
		velocity = direction * get("character_movement_speed") * delta
		var sprint = clamp(get("character_current_sprint") + get("character_sprint_regen_rate") * delta, 0, get("character_sprint_maximum"))
		set("character_current_sprint", sprint)
		player_sprint_changed.emit(get("character_sprint_maximum"),get("character_current_sprint"))
			
	move_and_slide()

	if(get("character_sprinting")==true):
		if(velocity.length()>0):
			player_started_sprinting.emit()
			if(%CharacterAnimationPlayer.current_animation!="Run" or %CharacterAnimationPlayer.is_playing()==false):
				%CharacterAnimationPlayer.play("Run")
		else:
			player_stopped_moving.emit()
			player_stopped_sprinting.emit()
			%CharacterAnimationPlayer.play("Idle")
	else:
		if(velocity.length()>0):
			player_started_moving.emit()
			if(%CharacterAnimationPlayer.current_animation!="Walk" or %CharacterAnimationPlayer.is_playing()==false):
				%CharacterAnimationPlayer.play("Walk")
		else:
			player_stopped_moving.emit()
			player_stopped_sprinting.emit()
			%CharacterAnimationPlayer.play("Idle")
	
func look_at_mouse():
	look_at(get_global_mouse_position())

