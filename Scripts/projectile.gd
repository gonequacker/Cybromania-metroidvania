extends Node2D

var direction = Vector2(1.0,0.0)
var speed = 200.0

func _process(delta):
  position = position + speed * direction * delta
