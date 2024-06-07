extends Area2D

const MAX_HITS = 3

var direction = Vector2(1.0,0.0)
var speed = 400.0

var hits = 0

func _ready():
	if direction.x > 0.1:
		scale.x *= -1.0
	if direction.y != 0.0:
		rotation = -PI/2.0 * direction.y

func _process(delta):
	position = position + speed * direction * delta

func _on_body_entered(body):
	# Do nothing, as I don't want the bolt to crash into walls
	pass


func _on_timer_timeout():
	queue_free()

func _on_area_entered(area):
	if area.is_in_group("enemy"):
		area.get_parent().get_node("HitboxComponent").take_damage(2)
