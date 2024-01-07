extends Resource
class_name ItemConfiguration

# General Settings
@export var item_id = "item_name"
@export var item_name = "Item Name"
@export var item_description = "This is a description of the item."
@export var item_height = 1
@export var item_width = 1
@export var item_slot = "WEAPON"
@export var item_icon:Texture2D
@export var item_usable = false

var items = ItemDb.ITEMS
