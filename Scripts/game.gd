extends Node2D

@onready var player = $World/Jlayer

# The following code is heavily based off a game that my friend made lol

@export var maps : Array[PackedScene]

@export var map_index = 0

var map_node : Node2D

func _ready():
	load_map(map_index)

func load_map(index : int):
	if map_node != null:
		map_node.queue_free()
	map_node = maps[index].instantiate()
	add_child(map_node)
	map_node.connect("completed", _on_map_completed)
	var spawn_pos = map_node.get_node("SpawnPos")
	if spawn_pos:
		player.position = spawn_pos.position
	else:
		player.position = Vector2(0.0, 0.0)
	player.fade_out_of_black()

func _on_map_completed():
	if map_index == len(maps) - 1:
		print("you win") # TODO
	else:
		map_index += 1
		load_map(map_index)
