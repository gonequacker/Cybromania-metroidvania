class_name TitleScreen
extends Control

@onready var start_button  = $MarginContainer/HBoxContainer/VBoxContainer/Start as Button
@onready var info_button = $MarginContainer/HBoxContainer/VBoxContainer/Info as Button
@onready var quit_button = $MarginContainer/HBoxContainer/VBoxContainer/Quit as Button

@onready var title_music = $AudioStreamPlayer2D2
@onready var title_animation = $AnimationPlayer
@onready var player_sprite = $Walk_1/AnimatedSprite2D

@onready var level_load = preload("res://Scenes/game.tscn")

func _ready():
	title_music.play()
	start_button.button_down.connect(on_start_pressed)
	quit_button.button_down.connect(on_quit_pressed)
	title_animation.play("new_animation")
	player_sprite.play('title_sprite_animation')
	$fall_1/AnimatedSprite2D.play("fall_1")
	$fall_2/AnimatedSprite2D.play("fall_2")
	$fall_3/AnimatedSprite2D.play("fall_3")
	$fall_4/AnimatedSprite2D.play("fall_4")
	


func on_start_pressed() -> void:
	get_tree().change_scene_to_packed(level_load)
	
func on_quit_pressed() -> void:
	get_tree().quit()	
	
		
func _on_animation_player_2_animation_changed(old_name, new_name):
	$Sprite2D.hide()
