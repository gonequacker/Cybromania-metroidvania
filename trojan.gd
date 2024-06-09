extends Node2D

# Spews enemies after timer is up
# Will spew enemies up to min(max_enemies, health)
# Hurt the boss by destroying minions

@onready var sprite = $AnimatedSprite2D
@onready var timer_between_spews = $between_spews
@onready var timer_between_enemies = $between_enemies
@onready var hurtSFX = $Hurt
@onready var dieSFX = $Die

# load the enemy scenes and store in an array
@onready var dos_scene = load("res://Scenes/enemies/dos.tscn")
@onready var hook_scene = load("res://Scenes/enemies/hook.tscn")
@onready var porcupine_scene = load("res://Scenes/enemies/porcupine.tscn")
@onready var worm_scene = load("res://Scenes/enemies/worm.tscn")
@onready var enemy_arr = [dos_scene, hook_scene, porcupine_scene, worm_scene]

# boss stats
@export var MAX_HEALTH = 20
@onready var health = MAX_HEALTH
@export var MAX_ENEMY_COUNT = 7  # enemies will spawn until at most this number is reached
@export var MIN_ENEMY_COUNT = 2  # if there are more than this number of live enemies, no more will be spawned
@onready var live_enemy_count = 0
var animation = "Idle"

func _ready():
	# connect and start the timer to release enemies
	timer_between_spews.timeout.connect(_on_timer_between_spews_timeout)
	timer_between_spews.start()

func _on_timer_between_spews_timeout():
	# only spew if there are few enemies left
	if live_enemy_count > MIN_ENEMY_COUNT:
		return
	# open hatch, play spew animation, instantiate many enemies,
	# close hatch, and continue. 
	sprite.play("OpenHatch")
	await sprite.animation_finished
	sprite.play("Spewing")
	
	# spawn enemies loop, go until MAX or boss' current health is reached. 
	while(live_enemy_count < min(MAX_ENEMY_COUNT, health)):
		# spawn random enemy type
		var spawn_index = int(randi() % enemy_arr.size())
		if spawn_index != 1: # ignore hooks for now
			spawn_enemy(spawn_index)
			live_enemy_count += 1
			
			# start the timer and wait for it to finish
			timer_between_enemies.start()
			await timer_between_enemies.timeout
	
	# close hatch, connect the animations when going back to idle
	await sprite.animation_looped
	sprite.play("CloseHatch")
	await sprite.animation_finished
	sprite.play("idle")
	
	timer_between_spews.start()

func spawn_enemy(enemy_index):
	# add the enemy from enemies_arr to the scene
	# use the boss' position as the spawn position, may need logic for 
	# enemy types (hooks from ceiling, worms on ground). 
	var enemy_instance = enemy_arr[enemy_index].instantiate()
	enemy_instance.position = position
	get_tree().current_scene.add_child(enemy_instance)

func _on_hitbox_component_killed():
	# enemy health is below zero
	sprite.play("killed")
	dieSFX.play()

func _on_die_finished():
	queue_free()

