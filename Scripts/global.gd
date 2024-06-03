# The following code is based heavily on https://github.com/christinec-dev/GodotInventorySystem

extends Node

# Inventory items
var inventory = {
	"crouch": 0,
	"dash": 0,
	"wall_jump": 0,
	"double_jump": 0,
	"spell": 0,
	"launcher": 0,
	"daggers": 0,
	"pike": 0,
	"arbalest": 0,
	"bytes": 0,
	"cookies": 0
}

signal inventory_updated

var player_node: Node = null

func _ready():
	pass

func add_item(item):
	for i in inventory:
		# Check if the item exists in the inventory
		if item.name.to_lower() == i.to_lower():
			inventory[i] += 1
			inventory_updated.emit()
			print("Item added ", inventory)
			return true
	# Picked up item is not in our list of valid items. Maybe it was named wrong?
	print("Invalid item name! ", inventory)
	return false

func remove_item():
	inventory_updated.emit()

func set_player_reference(player):
	player_node = player
