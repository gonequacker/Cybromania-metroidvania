extends Node2D

@onready var next_level = $NextLevel

@export var music : AudioStream

signal fade_out
signal completed

func _ready():
	next_level.connect("fade_out", _on_fade_out)

func _on_fade_out():
	emit_signal("fade_out")

func _on_next_level_completed():
	print("completed level!")
	emit_signal("completed")
