extends ColorRect
class_name InventoryItemGrid

# Arrays to store inventory items and the grid representation
var inventory_item_grid_items = []

# 2D dictionary to represent the inventory grid, where each cell has information about usage and a corresponding ColorRect node
var inventory_item_grid = {}
var inventory_item_grid_cell_size = 32
@export var inventory_item_grid_width = 0
@export var inventory_item_grid_height = 0
@export var inventory_grid_default_color: Color
@export var inventory_grid_used_color: Color

# Signals for item-related events
signal weapon_equipped(weapon_id, item)
signal weapon_unequipped(weapon_id, item)
signal item_used(item_id)

func _ready():
	# Initialize the inventory grid
	for x in range(inventory_item_grid_width):
		inventory_item_grid[x] = {}
		for y in range(inventory_item_grid_height):
			inventory_item_grid[x][y] = {}
			inventory_item_grid[x][y]["used"] = false

	# Create ColorRect nodes for each grid cell and set their default colors
	for y in range(inventory_item_grid_height):
		for x in range(inventory_item_grid_width):
			var color_rect = ColorRect.new()
			color_rect.global_position = Vector2(x * inventory_item_grid_cell_size, y * inventory_item_grid_cell_size)
			color_rect.size = Vector2(inventory_item_grid_cell_size - 2, inventory_item_grid_cell_size - 2)
			add_child(color_rect)
			color_rect.color = inventory_grid_default_color
			inventory_item_grid[x][y]["rect"] = color_rect

# Function to insert an item into the inventory grid
func insert_item(item):
	var item_pos = item.position-position
	var g_pos = pos_to_grid_coord(item_pos)
	var item_size = get_grid_size(item)
	
	# Check if there is enough space to insert the item
	if is_grid_space_available(g_pos.x, g_pos.y, item_size.x, item_size.y):
		set_grid_space(g_pos.x, g_pos.y, item_size.x, item_size.y, true)
		item.position = Vector2(g_pos.x, g_pos.y) * inventory_item_grid_cell_size
		add_child(item)
		inventory_item_grid_items.append(item)
		return true
	else:
		return false

# Function to grab an item from the inventory grid based on a position
func grab_item(pos):
	var item = get_item_under_pos(pos)
	if item == null:
		return null
	
	var item_pos = item.position
	var g_pos = pos_to_grid_coord(item_pos)
	var item_size = get_grid_size(item)
	set_grid_space(g_pos.x, g_pos.y, item_size.x, item_size.y, false)
	
	inventory_item_grid_items.remove_at(inventory_item_grid_items.find(item))
	return item

# Function to use an item from the inventory grid based on a position
func use_item(pos):
	var item = get_item_under_pos(pos)
	if item == null:
		return null
	
	# Emit signal if the item is usable
	if item.item_config.item_usable == true:
		item_used.emit(item.item_config.item_id)
		item.queue_free()
	
	var item_size = get_grid_size(item)
	var item_pos = item.position
	var g_pos = pos_to_grid_coord(item_pos)
	inventory_item_grid_items.remove_at(inventory_item_grid_items.find(item))
	set_grid_space(g_pos.x, g_pos.y, item_size.x, item_size.y, false)

# Function to convert global position to grid coordinates
func pos_to_grid_coord(pos):
	var results = {}
	results.x = int(pos.x / inventory_item_grid_cell_size)
	results.y = int(pos.y / inventory_item_grid_cell_size)
	return results

# Function to get the grid size of an item in terms of grid cells
func get_grid_size(item):
	var results = {}
	var s = item.size
	results.x = int(clamp(s.x / inventory_item_grid_cell_size, 1.0, 500.0)) + 1
	results.y = int(clamp(s.y / inventory_item_grid_cell_size, 1.0, 500.0)) + 1
	return results

# Function to check if there is enough space in the grid to place an item
func is_grid_space_available(x, y, w, h):
	if x < 0 or y < 0:
		return false
	if x + w > inventory_item_grid_width or y + h > inventory_item_grid_height:
		return false
	for i in range(x, x + w):
		for j in range(y, y + h):
			if inventory_item_grid[i][j]["used"] == true:
				return false
	return true

# Function to set the usage state of grid cells and update ColorRect colors accordingly
func set_grid_space(x, y, w, h, state):
	for i in range(x, x + w):
		for j in range(y, y + h):
			if state == true:
				inventory_item_grid[i][j]["used"] = true
				inventory_item_grid[i][j]["rect"].color = inventory_grid_used_color
			else:
				inventory_item_grid[i][j]["used"] = false
				inventory_item_grid[i][j]["rect"].color = inventory_grid_default_color

# Function to get the item under a given position
func get_item_under_pos(pos):
	for item in inventory_item_grid_items:
		if item.get_global_rect().has_point(pos):
			return item
	return null

# Function to insert an item at the first available spot in the grid
func insert_item_at_first_available_spot(item):
	for y in range(inventory_item_grid_height):
		for x in range(inventory_item_grid_width):
			if not inventory_item_grid[x][y]["used"]:
				item.global_position = global_position + Vector2(x, y) * inventory_item_grid_cell_size
				if insert_item(item):
					return true
	return false
