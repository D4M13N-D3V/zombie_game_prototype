extends CharacterBody2D
class_name Character

@export var character_movement_speed:float = 8000.0

@export var character_sprint_modifier:float = 2.0
@export var character_sprint_maximum:float = 100.0
@export var character_sprint_drain_rate:float = 2.0
@export var character_sprint_regen_rate:float = 0.0

var character_sprinting:bool = false
var character_current_sprint = 0.0

@export var character_health_maximum:float = 3.0
@export var character_health_regen_rate:float = 1.0
@export var character_armor_maximum:float = 10.0
@export var character_armor_regen_rate:float = 0.0

var character_current_health:float = 3.0
var character_current_armor:float = 0.0

signal died
signal damaged(amount,current_health,maximum_health)
signal healed(amount,current_health,maximum_health)

func _ready():
	heal(1)

func damage(amount):
	if(amount>=character_current_health):
		character_current_health=0
		die()
	else:
		character_current_health -= amount
	damaged.emit(amount,character_current_health,character_health_maximum)
	
func heal(amount):
	if(character_current_health+amount>character_health_maximum):
		character_current_health=character_health_maximum
	else:
		character_current_health += amount
	damaged.emit(amount,character_current_health,character_health_maximum)
		
func die():
	queue_free()
