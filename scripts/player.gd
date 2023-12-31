extends CharacterBody2D

@export var player_speed = 8000.0
var sprinting = false

func _ready():
	%WeaponSystem.current_weapon=0
	%PlayerSprite.play(%WeaponSystem.weapons[%WeaponSystem.current_weapon]+"_idle")

func _physics_process(delta):
	sprinting=Input.is_action_pressed("sprint")
	movement_logic(delta)
	look_at(get_global_mouse_position())
	vision_logic()

func vision_logic():
	var zombies = %Vision.get_overlapping_bodies()
	for zombie in zombies:
		if(zombie is TileMap == false and is_line_of_sight_clear(zombie)):
			zombie.show()
		

func get_movement_string():
	if(sprinting==true):
		return "sprint"
	else:
		return "move"

func movement_logic(delta):
	var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if(sprinting):
		velocity = direction * player_speed * delta *1.5
	else:
		velocity = direction * player_speed * delta 
	move_and_slide()
	var animation = %PlayerSprite.get_animation()
	if(velocity.length()>0.0 and animation!=%WeaponSystem.weapons[%WeaponSystem.current_weapon]+"_melee_attack" and animation!=%WeaponSystem.weapons[%WeaponSystem.current_weapon]+"_shoot"):
		%PlayerSprite.play(%WeaponSystem.weapons[%WeaponSystem.current_weapon]+"_"+get_movement_string())

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
		body.hide()
