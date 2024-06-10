extends Node2D

@onready var animated_sprite = $AnimatedSprite2D

@onready var ray_cast_right = $RayCastRight
@onready var ray_cast_left = $RayCastLeft

@onready var anim = $Anim
@onready var dieSFX = $Die

signal killed

const SPEED = 50

var facing = 1

func _physics_process(delta):
	position.x += facing * SPEED * delta
	if ray_cast_right.is_colliding():
		facing = -1
		animated_sprite.scale.x = -1
	elif ray_cast_left.is_colliding():
		facing = 1
		animated_sprite.scale.x = 1


func _on_hitbox_component_killed():
	anim.play("killed")
	dieSFX.play()
	emit_signal("killed")

func _on_die_finished():
	queue_free()
