extends Node
class_name HitboxComponent

signal hurt
signal killed

@export var health: int = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func take_damage(damage):
	health -= damage
	if health <= 0:
		emit_signal("killed")
	else:
		emit_signal("hurt")
