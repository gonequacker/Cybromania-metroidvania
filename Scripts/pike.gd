extends Node2D

@onready var animation_player = $AnimationPlayer

var direction = Vector2(1.0,0.0)

# Called when the node enters the scene tree for the first time.
func _ready():
	if direction.x > 0.1:
		scale.x *= -1.0
	if direction.y != 0.0:
		rotation = -PI/2.0 if direction.y > 0.0 else PI/2.0
	animation_player.play("attack")

func _on_area_entered(area):
	if area.is_in_group("porcupine"):
		area.get_parent().get_node("HitboxComponent").take_damage(2)
