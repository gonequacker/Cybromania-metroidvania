extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func life_changed(player_health):
	if player_health <= 0:
		get_tree().paused = true
		visible = true
