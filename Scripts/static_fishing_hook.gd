extends Node2D

@onready var dieSFX = $Die
@onready var anim = $Anim


func _on_hitbox_component_killed():
	dieSFX.play()
	anim.play("killed")

func _on_die_finished():
	queue_free()
