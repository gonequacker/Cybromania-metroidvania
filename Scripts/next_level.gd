extends Area2D

signal completed

func _on_body_entered(body):
	emit_signal("completed")
