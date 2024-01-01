extends PointLight2D

var original_position
@export var shake_amplitude = 2.0
@export var shake_frequency = 10.0
@export var shake_timer = 0.0

func _ready():
	original_position = position

func _process(delta):
	# Assuming your character's animation has a property called "animation_movement"
	var pos = get_parent().global_position
	
	# Calculate shake offset based on character movement
	var shake_offset = Vector2(
		sin(shake_timer) * shake_amplitude * pos.x,
		cos(shake_timer) * shake_amplitude * pos.y
	)
	
	# Apply shake offset to the light position
	position = original_position + shake_offset
	
	# Update the shake timer based on frequency
	shake_timer += delta * shake_frequency
