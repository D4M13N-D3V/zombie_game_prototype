extends CharacterBody2D
class_name Character

@export var character_movement_walk_speed:float = 0.0
@export var character_movement_sprint_speed:float = 0.0
@export var character_stamina_maximum:float= 0.0
@export var character_stamina_regen_rate:float = 0.0
@export var character_stamina_drain_rate:float = 0.0
@export var character_health_maximum:float = 0.0
@export var character_health_regen_rate:float = 0.0
@export var character_armor_maximum:float = 0.0
@export var character_armor_regen_rate:float = 0.0

var character_moving = false
var character_sprinting = false
var character_dead = false
var character_stamina_current = 0.0
var character_health_current = 0.0
var character_armor_current = 0.0
var character_damage_history = []

signal character_death
signal character_revived
signal character_stamina_increase(amount)
signal character_stamina_decrease(amount)
signal character_stamina_set(amount)
signal character_health_increase(amount)
signal character_health_decrease(amount)
signal character_health_set(amount)
signal character_armor_increase(amount)
signal character_armor_decrease(amount)
signal character_armor_set(amount)

func _ready():
	character_health_current = character_health_maximum
	character_stamina_current = character_stamina_maximum

func move_character(direction, delta):
	if(character_dead==false):
		if(character_sprinting==true):
			velocity = direction * character_movement_sprint_speed * delta 
		else:
			velocity = direction * character_movement_walk_speed * delta 
	move_and_slide()
		
func kill():
	if(character_dead==false):
		character_death.emit()
		death_callback()
	
func death_callback():
	queue_free()
	
func revive():
	if(character_dead==true):
		character_revived.emit()

func damage(amount):
	if(character_armor_current>=amount):
		remove_armor(amount)
	elif(character_armor_current<amount):
		var leftOver = amount - character_armor_current
		remove_armor(amount)
		character_armor_current = 0
		remove_health(leftOver)

func give_health(amount):
	if(amount<0):
		print("Attempted to add health to a character for a negative amount.")
	elif(character_dead==true):
		print("Attempted to add health to a dead character.")
	else:
		var futureHealth = character_health_current + amount
		if(futureHealth>character_health_maximum):
			character_health_current = character_health_maximum
		else:
			character_health_current = futureHealth

func remove_health(amount):
	if(amount<0):
		print("Attempted to remove health from a character for a negative amount.")
	elif(character_dead==true):
		print("Attempted to remove health from a dead character.")
	else:
		var futureHealth = character_health_current - amount
		if(futureHealth <= 0):
			character_health_current = 0
			kill()
		else:
			character_health_current = futureHealth

func set_health(amount):
	if(character_dead==false):
		character_health_current = amount
	
func give_armor(amount):
	if(amount<0):
		print("Attempted to add armor to a character for a negative amount.")
	elif(character_dead==true):
		print("Attempted to add armor to a dead character.")
	else:
		var futureArmor = character_armor_current + amount
		if(futureArmor>character_armor_maximum):
			character_armor_current = character_armor_maximum
		else:
			character_armor_current = futureArmor

func remove_armor(amount):
	if(amount<0):
		print("Attempted to remove armor to a character for a negative amount.")
	elif(character_dead==true):
		print("Attempted to remove armor to a dead character.")
	else:
		var futureArmor = character_armor_current - amount
		if(futureArmor<0):
			character_armor_current = 0
		else:
			character_armor_current = futureArmor

func set_armor(amount):
	if(character_dead==false):
		character_armor_current = amount
	
func give_stamina(amount):
	if(amount<0):
		print("Attempted to add stamina to a character for a negative amount.")
	elif(character_dead==true):
		print("Attempted to add stamina to a dead character.")
	else:
		var futureArmor = character_stamina_current + amount
		if(futureArmor>character_stamina_maximum):
			character_stamina_current = character_stamina_maximum
		else:
			character_armor_current = futureArmor

func remove_stamina(amount):
	if(amount<0):
		print("Attempted to remove stamina to a character for a negative amount.")
	elif(character_dead==true):
		print("Attempted to remove stamina to a dead character.")
	else:
		var futureStamina = character_stamina_current - amount
		if(futureStamina<0):
			character_stamina_current = 0
		else:
			character_stamina_current = futureStamina

func set_stamina(amount):
	if(character_dead==false):
		character_stamina_current = amount
