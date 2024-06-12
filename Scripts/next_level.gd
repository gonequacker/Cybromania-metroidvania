extends Area2D

@onready var fade_timer = $FadeTimer

signal completed

func _on_body_entered(body):
	body.fade_to_black()
	fade_timer.start()

func _on_fade_timer_timeout():
	emit_signal("completed")
