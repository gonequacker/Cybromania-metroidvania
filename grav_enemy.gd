extends CharacterBody2D

@onready var animated_sprite = $AnimatedSprite2D

@onready var ray_cast_right = $RayCastRight
@onready var ray_cast_left = $RayCastLeft

const SPEED = 50
var gravity_comp : GravityComponent = null # must be set up in _ready()
var facing = 1

func _ready():
	gravity_comp = get_node("GravityComponent")

func _process(delta):
	if ray_cast_right.is_colliding():
		facing = -1
		animated_sprite.scale.x = -1
	elif ray_cast_left.is_colliding():
		facing = 1
		animated_sprite.scale.x = 1
	velocity.x = facing * SPEED
	if gravity_comp:
		gravity_comp.handle_gravity(self, delta)
	move_and_slide()
