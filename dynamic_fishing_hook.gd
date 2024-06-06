extends Node2D

# Fishing hook that moves up and down. 
# Currently, fishing hook will not move at all by itself. 
# If player enters the detection zone, the hook will move up or down trying to 
# match the player's y coordinate. 

var player = null
@export var speed = 50

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if player:
		print("there is a player detected! Moving y coor")
		print("player y: ", player.position.y)
		print("this position y: ", position.y)
		position.y += (player.position.y - position.y)/ speed
		print("new position y: ", position.y)


func _on_player_detection_body_entered(body):
	player = body
	print("body entered: ", body)

func _on_player_detection_body_exited(body):
	print("player exited: ", player == body)
	player = null
