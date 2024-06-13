extends Node2D

@export var music : AudioStream

signal completed

func _on_next_level_completed():
	print("completed level!")
	emit_signal("completed")
