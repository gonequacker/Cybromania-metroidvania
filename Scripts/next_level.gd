extends Area2D

@onready var encryption_lock = $EncryptionLock

@onready var fade_timer = $FadeTimer
@onready var sfx = $SFX

var enabled = false

signal fade_out
signal completed

func _process(delta):
	encryption_lock.visible = not enabled
	var num_enemies_left = 0
	var enemies_node = get_parent().get_node("Enemies")
	if enemies_node: num_enemies_left = enemies_node.get_child_count()
	if num_enemies_left <= 0:
		enabled = true

func _on_body_entered(body):
	if not enabled: return
	emit_signal("fade_out")
	sfx.play()
	Global.player_node.fade_to_black()
	fade_timer.start()

func _on_fade_timer_timeout():
	emit_signal("completed")
