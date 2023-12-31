extends AnimatedSprite2D

func _process(_delta):
	if(is_playing()==false):
		visible=false
