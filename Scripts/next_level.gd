extends Area2D

@onready var fade_timer = $FadeTimer
@onready var sfx = $SFX

signal completed

func _on_body_entered(body):
	sfx.play()
	Global.player_node.fade_to_black()
	fade_timer.start()

func _on_fade_timer_timeout():
	emit_signal("completed")
