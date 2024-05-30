extends Node2D

@onready var animated_sprite = $AnimatedSprite2D

@onready var ray_cast_right = $RayCastRight
@onready var ray_cast_left = $RayCastLeft

const SPEED = 50

var facing = 1

func _process(delta):
	position.x += facing * SPEED * delta
	if ray_cast_right.is_colliding():
		facing = -1
		animated_sprite.scale.x = -1
	elif ray_cast_left.is_colliding():
		facing = 1
		animated_sprite.scale.x = 1
