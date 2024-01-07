extends ColorRect

# Reference to child slots
@onready var slots = get_children()

# Dictionary to store items associated with their respective slots
var items = {}

# Signals for item-related events
signal weapon_equipped(weapon_id, item)
signal weapon_unequipped(weapon_id, item)

func _ready():
	# Initialize the items dictionary with slots
	for slot in slots:
		items[slot.name] = null

# Function to insert an item into the equipment slots
func insert_item(item):
	# Calculate the center position of the item
	var item_pos = item.global_position + item.size / 2
	# Get the slot under the item's position
	var slot = get_slot_under_pos(item_pos)
	
	# Check if the item can be inserted into the slot
	if slot == null:
		return false

	# Retrieve item slot information from the ItemDb
	var item_slot = ItemDb.get_item(item.get_meta("id")).item_slot
	# Check if the item's slot matches the target slot
	if item_slot != slot.name:
		return false
	# Check if the slot is already occupied
	if items[item_slot] != null:
		return false

	# Place the item in the slot and emit the weapon_equipped signal
	items[item_slot] = item
	item.global_position = slot.global_position + slot.size / 2 - item.size / 2
	weapon_equipped.emit(item.item_config.item_id, item.item_config)
	return true

# Function to grab an item from the equipment slots
func grab_item(pos):
	# Get the item under the specified position
	var item = get_item_under_pos(pos)
	if item == null:
		return null

	# Retrieve item slot information from the ItemDb
	var item_slot = ItemDb.get_item(item.get_meta("id")).item_slot
	# Remove the item from the slot and emit the weapon_unequipped signal
	items[item_slot] = null
	weapon_unequipped.emit(item.item_config.item_id, item.item_config)
	return item

# Function to get the slot under a specified position
func get_slot_under_pos(pos):
	return get_thing_under_pos(slots, pos)

# Function to get the item under a specified position
func get_item_under_pos(pos):
	return get_thing_under_pos(items.values(), pos)

# Generic function to get the object (slot or item) under a specified position
func get_thing_under_pos(arr, pos):
	for thing in arr:
		if thing != null and thing.get_global_rect().has_point(pos):
			return thing
	return null
