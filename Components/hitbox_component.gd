extends Node
class_name HitboxComponent

@export var health: int = 1

@onready var collision_shape = $CollisionShape2D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func take_damage(damage):
	health -= damage
	if health < 0:
		get_parent().queue_free()
