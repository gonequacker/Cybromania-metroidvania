extends Area2D

const MAX_HITS = 3

var direction = Vector2(1.0,0.0)
var speed = 400.0

var hits = 0

func _ready():
	if direction.x > 0.1:
		scale.x *= -1.0
	if direction.y != 0.0:
		rotation = -PI/2.0 if direction.y > 0.0 else PI/2.0

func _process(delta):
	position = position + speed * direction * delta

func _on_body_entered(body):
	hits += 1
	if hits >= MAX_HITS:
		queue_free()

func _on_timer_timeout():
	queue_free()
