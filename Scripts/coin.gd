extends Area2D

@onready var animation_player = $AnimationPlayer
@onready var collect_coin = $CollectCoin

var scene_path: String = "res://Scenes/coin.tscn"

func _on_body_entered(body):
	if body.name == "Jlayer" :
		animation_player.play("pickup")
		collect_coin.play()
		var item = {
			"name": "bytes",
			"texture": Texture,
			"scene_path": scene_path
		}
		Global.add_item(item)
