extends Node2D

@onready var player = $World/Jlayer
@onready var camera = $World/Jlayer/Camera2D

@onready var music = $Music

# The following code is heavily based off a game that my friend made lol

@export var maps : Array[PackedScene]
@export var debug_start_map = 0

var map_node : Node2D

func _ready():
	if debug_start_map > 0:
		Global.current_level = debug_start_map
		for item in Global.inventory:
			Global.inventory[item] = 9999
	load_map(Global.current_level)

func load_map(index : int):
	if map_node != null:
		map_node.queue_free()
	map_node = maps[index].instantiate()
	add_child(map_node)
	map_node.connect("fade_out", _on_fade_out)
	map_node.connect("completed", _on_map_completed)
	# Music
	music.stream = null
	var musicStream = map_node.music
	if musicStream: music.stream = musicStream
	music.play()
	# Camera bounds
	camera.limit_left = -10000000
	camera.limit_top = -10000000
	camera.limit_right = 10000000
	camera.limit_bottom = 10000000
	var left = map_node.get_node("LeftBorder")
	if left: camera.limit_left = left.position.x
	var top = map_node.get_node("TopBorder")
	if top: camera.limit_top = top.position.y
	var right = map_node.get_node("RightBorder")
	if right: camera.limit_right = right.position.x
	var bottom = map_node.get_node("BottomBorder")
	if bottom: camera.limit_bottom = bottom.position.y
	# Player spawn pos
	player.position = Vector2(0.0, 0.0)
	var spawn_pos = map_node.get_node("SpawnPos")
	if spawn_pos: player.position = spawn_pos.position
	# Fade out the black screen
	player.fade_out_of_black()

func _on_fade_out():
	music.fade_out()
func _on_map_completed():
	music.fade_in()
	if Global.current_level == len(maps) - 1:
		print("you win") # TODO
	else:
		Global.current_level += 1
		load_map(Global.current_level)
