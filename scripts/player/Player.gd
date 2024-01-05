extends Character
class_name Player

signal player_started_moving
signal player_stopped_moving
signal player_started_sprinting
signal player_stopped_sprinting
signal player_sprint_changed(maximum,current)

signal player_turned_flashlight_on
signal player_turned_flashlight_off

func _process(delta):
	look_at_mouse()
	movement_logic(delta)
	vision_logic()
	if(%CharacterAnimationPlayer.is_playing()==false):
		%CharacterAnimationPlayer.play("Idle")

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
		set("character_sprinting",true)
		
	if(Input.is_action_just_released("sprint")):
		%ZoomCamera._set_zoom_level(%ZoomCamera._zoom_level*0.5)
		set("character_sprinting",false)
		
	var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	move_character(direction, delta)
	move_and_slide()
	sprint_animation_logic()

func sprint_animation_logic():
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

