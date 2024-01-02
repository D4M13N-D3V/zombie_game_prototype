extends Node2D

@export var tilemap : TileMap # Make sure to assign your TileMap node in the Inspector

func _process(_delta: float) -> void:
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_MIDDLE):
		var mouse_position : Vector2 = get_global_mouse_position()
		var cell = tilemap.get_cell(mouse_position.x, mouse_position.y)
		print(cell.get_name())
