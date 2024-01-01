extends CanvasLayer

func _process(delta):
	%HealthBar.value = get_node("../../Player").player_current_health
	%HealthBar.max_value = get_node("../../Player").player_maximum_health
	%StaminaBar.value = get_node("../../Player").player_current_stamina
	%StaminaBar.max_value = get_node("../../Player").player_maximum_stamina
