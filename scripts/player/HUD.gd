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

func _on_player_healed(_amount, current_health, maximum_health):
	%player_maximum_health_value.text = str(maximum_health)
	%player_current_health_value.text = str(current_health)


func _on_player_player_sprint_changed(maximum, current):
	%player_maximum_sprint_value.text = str(maximum)
	%player_current_sprint_value.text = str(current)
