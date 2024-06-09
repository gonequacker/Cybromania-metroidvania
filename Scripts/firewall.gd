extends Area2D

@onready var ray_cast = $RayCast2D
@onready var timer = $Timer

var direction = Vector2(1.0,0.0)
var speed = 120.0

func _ready():
	if direction.x > 0.1:
		scale.x *= -1.0
	if direction.y != 0.0:
		rotation = -PI/2.0 if direction.y > 0.0 else PI/2.0

func _process(delta):
	position = position + speed * direction * delta
	if ray_cast.is_colliding():
		queue_free()

func _on_timer_timeout():
	queue_free()

func _on_area_entered(area):
	if area.is_in_group("worm"):
		area.get_parent().get_node("HitboxComponent").take_damage(1)
