extends AnimatedSprite2D

func _ready():
	play("default")
	
func _process(_delta):
	if(is_playing()==false):
		queue_free()
