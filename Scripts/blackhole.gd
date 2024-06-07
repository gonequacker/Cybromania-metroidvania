extends Area2D

@onready var timer = $Timer

const START_SPEED = 50.0

var direction = Vector2(1.0,0.0)
var speed = START_SPEED

func _ready():
	if direction.x > 0.1:
		scale.x *= -1.0
	if direction.y != 0.0:
		rotation = -PI/2.0 if direction.y > 0.0 else PI/2.0

func _process(delta):
	position = position + speed * direction * delta
	if speed > 0.0: speed -= delta * START_SPEED / 3.0

func _on_timer_timeout():
	queue_free()

func _on_area_entered(area):
	print("Blackhole hit something...")
	if area.is_in_group("porcupine"):
		area.take_damage(1)
		print("Blackhole hit!")
