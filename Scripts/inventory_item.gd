@tool
extends Node2D


@export var item_name = ""
@export var item_texture: Texture
var scene_path: String = "res://Scenes/inventory_item.tscn"

@onready var icon_sprite = $Sprite2D

var player_in_range = false

# Called when the node enters the scene tree for the first time.
func _ready():
	if not Engine.is_editor_hint():
		icon_sprite.texture = item_texture


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Engine.is_editor_hint():
		icon_sprite.texture = item_texture
	
	if player_in_range:
		pickup_item()


# Add item to inventory
func pickup_item():
	var item = {
		"name": item_name,
		"texture": item_texture,
		"scene_path": scene_path
	}
	if Global.player_node:
		Global.add_item(item)
		self.queue_free()


func _on_area_2d_body_entered(body):
	player_in_range = true
	body.pickup_rect.visible = true


func _on_area_2d_body_exited(body):
	player_in_range = false
	body.pickup_rect.visible = false
