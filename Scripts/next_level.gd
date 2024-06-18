extends Area2D

@onready var encryption_lock = $EncryptionLock

@onready var fade_timer = $FadeTimer
@onready var sfx = $SFX
@onready var unlocked_sfx = $UnlockedSFX

var has_enemies_node = true
var enabled = false

signal fade_out
signal completed

func _process(delta):
	encryption_lock.visible = not enabled
	var num_enemies_left = 0
	if get_parent().has_node("Enemies"): num_enemies_left = get_parent().get_node("Enemies").get_child_count()
	else: has_enemies_node = false
	if num_enemies_left <= 0:
		if not enabled and has_enemies_node:
			unlocked_sfx.play()
		enabled = true

func _on_body_entered(body):
	if not enabled: return
	emit_signal("fade_out")
	sfx.play()
	Global.player_node.fade_to_black()
	fade_timer.start()

func _on_fade_timer_timeout():
	emit_signal("completed")
