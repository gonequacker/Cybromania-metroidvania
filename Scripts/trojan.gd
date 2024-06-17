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

var MAX_ENEMY_COUNT = 10  # enemies will spawn until this number is reached
var MIN_ENEMY_COUNT = 4  # if there are more than this number of live enemies, no more will be spawned

var FISHING_HOOK_INITIAL_Y = 100 # pixels above the Trojan
var FISHING_HOOK_X_START = 50
var FISHING_HOOK_X_WINDOW = 400 # how much more than x_start it will go
var FISHING_HOOK_Y_START = -20
var FISHING_HOOK_Y_WINDOW = 100 # how much more than y_start it will go

var DOS_X_START = 100
var DOS_X_WINDOW = 50 # how much more than x_start it will go
var DOS_Y_START = -100
var DOS_Y_WINDOW = 200 # how much more than y_start it will go

# boss stats
var MAX_HEALTH = 30
@onready var health = MAX_HEALTH

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

	# DoS spawns at the opening of the Trojan
	if enemy_index == 0:
		enemy_instance.position.x = position.x - (randi() % DOS_X_WINDOW) - DOS_X_START # a bit left of Trojan
		enemy_instance.position.y = position.y - (randi() % DOS_Y_WINDOW) - DOS_Y_START # around Trojan

	# fishing hook spawns at random x and relative y (somewhere overhead), and lowers itself in
	elif enemy_index == 1:
		# random windows for x and y, set by constants
		enemy_instance.position.x = position.x - (randi() % FISHING_HOOK_X_WINDOW) - FISHING_HOOK_X_START
		enemy_instance.position.y = position.y - FISHING_HOOK_INITIAL_Y
		enemy_instance.target_y = position.y + (randi() % FISHING_HOOK_Y_WINDOW) - FISHING_HOOK_Y_START

	# porcupine and worm exit the trojan through mouth
	else:
		enemy_instance.position = position
	get_tree().current_scene.add_child(enemy_instance)
	
	# track the spawned enemy's death
	enemy_instance.connect("killed", _on_enemy_killed)

func _on_enemy_killed():
	health -= 1
	live_enemy_count -= 1
	if health <= 0:
		die()
		return
	hurtSFX.play()

func die():
	# enemy health is below zero
	sprite.play("killed")
	dieSFX.play()
	
	await sprite.animation_finished
	queue_free()

