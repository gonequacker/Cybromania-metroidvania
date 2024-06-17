extends Area2D

@onready var timer = $Timer

const START_SPEED = 50.0

var direction = Vector2(1.0,0.0)
var speed = START_SPEED

func _process(delta):
	position = position + speed * direction * delta
	if speed > 0.0: speed -= delta * START_SPEED / 3.0

func _on_timer_timeout():
	queue_free()

func _on_area_entered(area):
	if area.is_in_group("dos"):
		area.get_parent().get_node("HitboxComponent").take_damage(5)
