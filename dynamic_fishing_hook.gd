extends Node2D

# Fishing hook that moves up and down. 
# Currently, fishing hook will not move at all by itself. 
# If player enters the detection zone, the hook will move up or down trying to 
# match the player's y coordinate. 

@onready var anim = $Anim
@onready var hurtSFX = $Hurt
@onready var dieSFX = $Die

signal killed

var player = null
var target_y = null
@export var speed = 50

func _physics_process(delta):
	# If there is a target set, move to target.
	# This is used for moving in to position.
	if target_y != null:
		position.y += (target_y - position.y)/ speed
		if abs(position.y - target_y) < 5:
			# Release target once reached. 
			target_y = null
	
	# Regular behavior, chase the player when player eneters detection area. 
	if player:
		position.y += (player.position.y - position.y)/ speed


func _on_player_detection_body_entered(body):
	player = body

func _on_player_detection_body_exited(body):
	player = null


# Handle hitbox signals
func _on_hitbox_component_hurt():
	anim.play("hurt")
	hurtSFX.play()

func _on_hitbox_component_killed():
	anim.play("killed")
	dieSFX.play()
	emit_signal("killed")

func _on_die_finished():
	queue_free()
