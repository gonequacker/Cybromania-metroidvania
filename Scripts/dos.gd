extends Node2D

# Fishing hook that moves up and down. 
# Currently, fishing hook will not move at all by itself. 
# If player enters the detection zone, the hook will move up or down trying to 
# match the player's y coordinate. 

@onready var anim = $Anim
@onready var dieSFX = $Die

signal killed

var player = null
@export var speed = 50

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if player:
		position.y += (player.position.y - position.y)/ speed
		position.x += (player.position.x - position.x)/ speed


func _on_player_detection_body_entered(body):
	player = body
	#print("body entered: ", body)

func _on_player_detection_body_exited(body):
	#print("player exited: ", player == body)
	player = null

func _on_hitbox_component_killed():
	anim.play("killed")
	dieSFX.play()
	emit_signal("killed")

func _on_die_finished():
	queue_free()
