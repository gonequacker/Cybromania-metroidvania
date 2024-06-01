extends Area2D

# Run when player collides with the killzone.
func _on_body_entered(body):
	body.take_damage()
