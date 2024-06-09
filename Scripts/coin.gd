extends Area2D

@onready var animation_player = $AnimationPlayer

func _on_body_entered(body):
	if body.name == "Jlayer" :
		animation_player.play("pickup")
		var item = {
			"name": "cookies"
		}
		Global.add_item(item)
