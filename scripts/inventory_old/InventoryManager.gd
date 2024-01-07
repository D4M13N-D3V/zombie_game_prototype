extends Control

# Reference to the ItemBase scene
const item_base = preload("res://scenes/inventory_old/ItemBase.tscn")

# Reference to UI elements in the inventory
@onready var inventory_background = %Background
@onready var inventory_items = %Items
@onready var inventory_equipment_slots = %Equipment
@onready var inventory_other_items = %OtherItems

# Variables to track the dragged item and its state
var inventory_item_dragged = null
var inventory_item_cursor_offset = Vector2()
var inventory_item_dragged_last_container = null
var inventory_item_dragged_last_pos = Vector2()

# Signals for item-related events
signal weapon_equipped(weapon_id, item)
signal weapon_unequipped(weapon_id, item)
signal item_used(item_id)

func _ready():
	pass #pickup_item("handgun_ammo")
	#pickup_item("handgun_ammo")

func _process(delta):
	var cursor_pos = get_global_mouse_position()

	# Toggle inventory visibility on "inventory" key press
	if Input.is_action_just_pressed("inventory"):
		toggle_inventory_visibility(cursor_pos)

	# Handle grabbing, using, and releasing items
	if Input.is_action_just_pressed("melee"):
		grab(cursor_pos)
	if Input.is_action_just_pressed("shoot"):
		use(cursor_pos)
	if Input.is_action_just_released("melee"):
		release(cursor_pos)

	# Update the position of the dragged item if it exists
	if inventory_item_dragged != null:
		inventory_item_dragged.global_position = cursor_pos + inventory_item_cursor_offset

# Function to toggle inventory visibility
func toggle_inventory_visibility(cursor_pos):
	if %Background.visible:
		%Background.visible = false
		GameManager.ui_open = false
	else:
		%Background.visible = true
		GameManager.ui_open = true

# Function to grab an item under the cursor
func grab(cursor_pos):
	var c = get_container_under_cursor(cursor_pos)
	if c != null and c.has_method("grab_item"):
		inventory_item_dragged = c.grab_item(cursor_pos)
		if inventory_item_dragged != null:
			inventory_item_dragged_last_container = c
			inventory_item_dragged_last_pos = inventory_item_dragged.global_position
			inventory_item_cursor_offset = inventory_item_dragged.global_position - cursor_pos

# Function to use an item under the cursor
func use(cursor_pos):
	var c = get_container_under_cursor(cursor_pos)
	if c != null and c.has_method("use_item"):
		c.use_item(cursor_pos)

# Function to release the grabbed item
func release(cursor_pos):
	if inventory_item_dragged == null:
		return
	var c = get_container_under_cursor(cursor_pos)
	if c == null:
		drop_item()
	elif c.has_method("insert_item"):
		if c.insert_item(inventory_item_dragged):
			inventory_item_dragged = null
		else:
			return_item()
	else:
		return_item()

# Function to get the container under the cursor
func get_container_under_cursor(cursor_pos):
	var containers = [inventory_items, inventory_other_items, inventory_equipment_slots, inventory_background]
	for c in containers:
		if c.get_global_rect().has_point(cursor_pos):
			return c
	return null

# Function to drop the dragged item
func drop_item():
	inventory_item_dragged.queue_free()
	inventory_item_dragged = null

# Function to return the dragged item to its original position or container
func return_item():
	inventory_item_dragged.global_position = inventory_item_dragged_last_pos
	inventory_item_dragged_last_container.insert_item(inventory_item_dragged)
	inventory_item_dragged = null

# Function to simulate picking up an item and adding it to the inventory
func pickup_item(item_id):
	var item = item_base.instantiate()
	item.set_meta("id", item_id)
	var dbItem = ItemDb.get_item(item_id)
	item.item_config = dbItem
	item.set_size(Vector2(dbItem.item_width, dbItem.item_height))
	item.texture = dbItem.item_icon
	if !inventory_items.insert_item_at_first_available_spot(item):
		item.queue_free()
		return false
	return true

# Event handlers for equipment-related signals
func _on_equipment_weapon_equipped(weapon_id, item):
	weapon_equipped.emit(weapon_id, item)

func _on_equipment_weapon_unequipped(weapon_id, item):
	weapon_unequipped.emit(weapon_id, item)

# Event handler for item_used signal
func _on_items_item_used(item_id):
	item_used.emit(item_id)
