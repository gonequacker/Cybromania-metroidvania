extends Area2D

var direction = Vector2(1.0,0.0)
var speed = 300.0

func _process(delta):
	position = position + speed * direction * delta

func _on_body_entered(body):
	queue_free()
