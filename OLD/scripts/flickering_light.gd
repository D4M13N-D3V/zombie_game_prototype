extends PointLight2D

var original_energy : float
@export var flicker_range : float = 0.2  # Adjust this value to control the flicker intensity
@export var min_flicker_timer : float = 0.1  # Adjust this value to set the minimum flicker speed
@export var max_flicker_timer : float = 0.5  # Adjust this value to set the maximum flicker speed
@export var flicker_timer : float

func _ready():
	original_energy = energy
	randomize()
	reset_flicker_timer()

func reset_flicker_timer():
	flicker_timer = randf_range(min_flicker_timer, max_flicker_timer)

func _process(delta):
	flicker_timer -= delta

	if flicker_timer <= 0:
		reset_flicker_timer()

		var flicker_amount = randf_range(-flicker_range, flicker_range)
		energy = original_energy + flicker_amount
