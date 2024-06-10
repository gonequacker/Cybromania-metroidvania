extends Node2D

@onready var dieSFX = $Die
@onready var anim = $Anim

signal killed

func _on_hitbox_component_killed():
	anim.play("killed")
	dieSFX.play()
	emit_signal("killed")

func _on_die_finished():
	queue_free()
