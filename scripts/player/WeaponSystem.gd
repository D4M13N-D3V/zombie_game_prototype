extends Node2D

var current_weapon_configuration:Resource
var weapons = ["flashlight"]
var current_weapon = 0

var current_weapon_animator = null

func _ready():
	current_weapon = 0
	initialize_weapon(weapons[current_weapon])


func initialize_weapon(weapon_id):
	var current_weapon_configuration = load("res://resources/player/weapons/"+weapon_id+"/"+weapon_id+".tres")
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


func next_weapon():
	pass

func previous_weapon():
	pass

func shoot():
	pass

func melee():
	pass

func check_magazine():
	pass
	
func reload():
	pass


func _on_player_player_started_sprinting():
	current_weapon_animator.play(weapons[current_weapon]+"_sprint")


func _on_player_player_stopped_sprinting():
	current_weapon_animator.play(weapons[current_weapon]+"_idle")


func _on_player_player_stopped_moving():
	current_weapon_animator.play(weapons[current_weapon]+"_idle")


func _on_player_player_started_moving():
	current_weapon_animator.play(weapons[current_weapon]+"_move")
