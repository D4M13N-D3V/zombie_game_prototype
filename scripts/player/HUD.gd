extends CanvasLayer


func _on_player_player_started_sprinting():
	%player_sprinting_value.text="true"
	
func _on_player_player_stopped_sprinting():
	%player_sprinting_value.text="false"

func _on_player_player_started_moving():
	%player_moving_value.text="true"

func _on_player_player_stopped_moving():
	%player_moving_value.text="false"

func _on_player_damaged(_amount, current_health, maximum_health):
	%player_maximum_health_value.text = str(maximum_health)
	%player_current_health_value.text = str(current_health)
	%HealthBar.max_value = maximum_health
	%HealthBar.value = current_health

func _on_player_healed(_amount, current_health, maximum_health):
	%player_maximum_health_value.text = str(maximum_health)
	%player_current_health_value.text = str(current_health)
	%HealthBar.max_value = maximum_health
	%HealthBar.value = current_health


func _on_player_player_sprint_changed(maximum, current):
	%player_maximum_sprint_value.text = str(maximum)
	%player_current_sprint_value.text = str(current)
	%SprintBar.max_value = maximum
	%SprintBar.value = current


func _on_weapon_system_weapon_changed(weapon_id):
	%player_current_weapon_value.text = weapon_id


func _on_weapon_system_ammo_changed(amount, _maximum):
	%player_current_weapon_ammo_value.text = str(amount)


func _on_weapon_system_magazine_changed(amount, _maximum):
	%player_current_weapon_magazine_value.text = str(amount)
