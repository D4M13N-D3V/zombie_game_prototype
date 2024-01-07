extends Control
class_name InventoryGridManager

const item_base = preload("res://scenes/inventory_old/ItemBase.tscn")

@export_group("Inventory Grid Settings")
@export var inventory_main_grid_control:Control
@export var inventory_main_grid_cell_height:int = 32
@export var inventory_main_grid_cell_width:int = 32
@export var inventory_main_grid_auto_size = false
@export var inventory_main_grid_height:int = 15
@export var inventory_main_grid_width:int = 15
@export var inventory_main_grid_cell_color_available:Color = Color.WHITE
@export var inventory_main_grid_cell_color_used:Color = Color.GREEN
@export var inventory_main_grid_cell_color_hightlighted:Color = Color.ORANGE
var _inventory_main_grid = {}
var _inventory_main_grid_items = []

enum inventory_state { INVENTORY, LOOT, STATS }
enum inventory_grid_state { AVAILABLE, USED, HIGHLIGHTED }

func _ready():
	if(inventory_main_grid_control==null):
		printerr("Inventory does not have a parent assigned for the main grid!")
	main_grid_intialize()
	pickup_item("handgun_ammo")
	
func _process(delta):
	if(Input.is_action_just_pressed("melee")):
		if(_is_mouse_ontop_of_control(inventory_main_grid_control)==true):
			print("IN GRID")
		else:
			print("OUT GRID")

# Item Logic
func pickup_item(item_id):
	var item = item_base.instantiate()
	item.set_meta("id", item_id)
	var dbItem = ItemDb.get_item(item_id)
	item.item_config = dbItem
	item.set_size(Vector2(dbItem.item_width, dbItem.item_height))
	item.texture = dbItem.item_icon
	if not main_grid_insert_first_available(item):
		item.queue_free()
		return false
	return true


# Main Grid Logic
func get_main_grid_size(item):
	var results = {}
	var s = item.size
	results.x = int(clamp(s.x / inventory_main_grid_cell_height, 1.0, 500.0)) + 1
	results.y = int(clamp(s.y / inventory_main_grid_cell_width, 1.0, 500.0)) + 1
	return results

func main_grid_to_global_coords(coords):
	return inventory_main_grid_control.global_position + Vector2(coords.x*inventory_main_grid_cell_width, coords.y*inventory_main_grid_cell_height)
	
	
func global_to_main_grid_coords(pos):
	var results = {}
	var coords = inventory_main_grid_control.position-pos
	results.x = int(coords.x / inventory_main_grid_cell_width)
	results.y = int(coords.y / inventory_main_grid_cell_height)
	return results
	
func main_grid_set_state(x,y, state):
	if(state==inventory_grid_state.AVAILABLE):
		_inventory_main_grid[x][y]["state"] = inventory_grid_state.AVAILABLE
		_inventory_main_grid[x][y]["rect"].color = inventory_main_grid_cell_color_available
	elif(state==inventory_grid_state.USED):
		_inventory_main_grid[x][y]["state"] = inventory_grid_state.USED
		_inventory_main_grid[x][y]["rect"].color = inventory_main_grid_cell_color_used
	elif(state==inventory_grid_state.HIGHLIGHTED):
		_inventory_main_grid[x][y]["state"] = inventory_grid_state.HIGHLIGHTED
		_inventory_main_grid[x][y]["rect"].color = inventory_main_grid_cell_color_hightlighted

func main_grid_set_space_state(x, y, w, h, state):
	for i in range(x, x + w):
		for j in range(y, y + h):
			main_grid_set_state(i,j,state)

func main_grid_intialize():
	if(inventory_main_grid_auto_size==true):
		var result = get_main_grid_size(inventory_main_grid_control)
		inventory_main_grid_width = result.x
		inventory_main_grid_height = result.y
		
	for x in range(inventory_main_grid_width):
		_inventory_main_grid[x] = {}
		for y in range(inventory_main_grid_height):
			_inventory_main_grid[x][y] = {}
			_inventory_main_grid[x][y]["state"] = inventory_grid_state.AVAILABLE

	# Create ColorRect nodes for each grid cell and set their default colors
	for y in range(inventory_main_grid_height):
		for x in range(inventory_main_grid_width):
			var color_rect = ColorRect.new()
			color_rect.global_position = main_grid_to_global_coords(Vector2(x,y))
			color_rect.size = Vector2(inventory_main_grid_cell_width - 2, inventory_main_grid_cell_height - 2)
			add_child(color_rect)
			color_rect.color = inventory_main_grid_cell_color_available
			_inventory_main_grid[x][y]["rect"] = color_rect
			
func main_grid_insert_first_available(item):
	for y in range(inventory_main_grid_height):
		for x in range(inventory_main_grid_width):
			if not _inventory_main_grid[x][y]["state"]==inventory_grid_state.USED:
				item.global_position = main_grid_to_global_coords(Vector2(x,y))
				if main_grid_insert_item(item):
					return true
	return false
	
func is_grid_space_available(x, y, w, h):
	if x < 0 or y < 0:
		return false
	if x + w > inventory_main_grid_width or y + h > inventory_main_grid_height:
		return false
	for i in range(x, x + w):
		for j in range(y, y + h):
			if _inventory_main_grid[i][j]["state"] == inventory_grid_state.USED:
				return false
	return true
func main_grid_insert_item(item):
	var item_pos = item.position-position
	var g_pos = global_to_main_grid_coords(item_pos)
	var item_size = get_main_grid_size(item)
	
	# Check if there is enough space to insert the item
	if is_grid_space_available(g_pos.x, g_pos.y, item_size.x, item_size.y):
		main_grid_set_space_state(g_pos.x, g_pos.y, item_size.x, item_size.y, inventory_grid_state.USED)
		item.position = Vector2(g_pos.x * inventory_main_grid_width, g_pos.y * inventory_main_grid_height)
		add_child(item)
		_inventory_main_grid_items.append(item)
		return true
	else:
		return false
# Misc Methods
		
func _is_mouse_ontop_of_control(c):
	var cursor_pos = get_global_mouse_position()
	return c.get_global_rect().has_point(cursor_pos)
