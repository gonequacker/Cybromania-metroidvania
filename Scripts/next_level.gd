extends Area2D

@onready var fade_timer = $FadeTimer
@onready var sfx = $SFX

signal fade_out
signal completed

func _on_body_entered(body):
	emit_signal("fade_out")
	sfx.play()
	Global.player_node.fade_to_black()
	fade_timer.start()

func _on_fade_timer_timeout():
	emit_signal("completed")
