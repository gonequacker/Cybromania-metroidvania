class_name TitleScreen
extends Control

@onready var start_button  = $MarginContainer/HBoxContainer/VBoxContainer/Start as Button
@onready var info_button = $MarginContainer/HBoxContainer/VBoxContainer/Info as Button
@onready var quit_button = $MarginContainer/HBoxContainer/VBoxContainer/Quit as Button

@onready var level_load = preload("res://Scenes/game.tscn")
func _ready():
	start_button.button_down.connect(on_start_pressed)
	quit_button.button_down.connect(on_quit_pressed)
	$AnimationPlayer.play('new_animation')
	
func on_start_pressed() -> void:
	get_tree().change_scene_to_packed(level_load)
	
func on_quit_pressed() -> void:
	get_tree().quit()	
	
		


