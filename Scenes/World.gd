extends Node

func _ready():
	var level = "res://scenes/boss_fight_test_arena.tscn"
	var level_scene = load(level)
	
	var level_instance = level_scene.instantiate()
	
	# Add the level instance to the main scene
	add_child(level_instance)
