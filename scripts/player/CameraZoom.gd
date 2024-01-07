extends Camera2D

@export var min_zoom = 2.5
@export var max_zoom = 4.0
@export var zoom_factor = 0.1
@export var zoom_speed = 3
var shake_strength = Vector2(0,0)
var shake_fade = 2.0

@onready var tween = Tween.new()
@onready var rng = RandomNumberGenerator.new()

var _zoom_level = 3.0

func _set_zoom_level(value: float) -> void:
	# We limit the value between `min_zoom` and `max_zoom`
	_zoom_level = clamp(value, min_zoom, max_zoom)
	
func _process(delta):
	zoom = lerp(zoom, Vector2(_zoom_level, _zoom_level), delta*zoom_speed)
	if(shake_strength.length()>0.0):
		offset = lerp(offset,shake_strength,shake_fade*delta)
		shake_strength = lerp(shake_strength,Vector2(0,0), shake_fade*delta*0.05)
	
func _input(event):
	if event.is_action_pressed("zoom_in"):
		_set_zoom_level(_zoom_level + zoom_factor)
	if event.is_action_pressed("zoom_out"):
		_set_zoom_level(_zoom_level - zoom_factor)

func apply_shake(strength, fade):	
	shake_fade = fade
	shake_strength = Vector2(rng.randf_range(-strength, strength),rng.randf_range(-strength, strength))
