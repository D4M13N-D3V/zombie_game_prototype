extends Character
class_name Zombie
func _ready():
	%ZombieSprite.play("idle")
	character_health_current = character_health_maximum
	character_stamina_current = character_stamina_maximum

func death_callback():
	queue_free()
