extends CanvasLayer

@export var health_bar:ProgressBar
@export var armor_bar:ProgressBar
@export var stamina_bar:ProgressBar
@export var current_weapon:Label
@export var total_ammo:Label
@export var current_magazine:Label
@export var magazine_total:Label

func UpdateHealth(value,maximum):
	health_bar.max_value = maximum
	health_bar.value = value

func UpdateArmor(value,maximum):
	armor_bar.max_value = maximum
	armor_bar.value = value

func UpdateStamina(value,maximum):
	stamina_bar.max_value = maximum
	stamina_bar.value = value
		
func UpdateMagazine(amount,maximum):
	current_magazine.text = str(amount)
	magazine_total.text = str(maximum)

func UpdateAmmo(amount,_maximum):
	total_ammo.text = str(amount)

func UpdateWeapon(weapon):
	current_weapon.text = weapon

func _on_player_character_health_decrease(amount, maximum):
	UpdateHealth(amount,maximum)


func _on_player_character_health_increase(amount, maximum):
	UpdateHealth(amount,maximum)


func _on_player_character_health_set(amount, maximum):
	UpdateHealth(amount,maximum)



func _on_player_character_armor_decrease(amount, maximum):
	UpdateArmor(amount,maximum)


func _on_player_character_armor_increase(amount, maximum):
	UpdateArmor(amount,maximum)


func _on_player_character_armor_set(amount, maximum):
	UpdateArmor(amount,maximum)


func _on_player_character_stamina_decrease(amount, maximum):
	UpdateStamina(amount,maximum)


func _on_player_character_stamina_increase(amount, maximum):
	UpdateStamina(amount,maximum)


func _on_player_character_stamina_set(amount, maximum):
	UpdateStamina(amount,maximum)


func _on_weapon_system_ammo_changed(amount, maximum):
	UpdateAmmo(amount, maximum)


func _on_weapon_system_magazine_changed(amount, maximum):
	UpdateMagazine(amount,maximum)


func _on_weapon_system_weapon_changed(weapon_id):
	UpdateWeapon(weapon_id)
