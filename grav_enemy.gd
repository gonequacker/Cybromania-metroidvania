extends CharacterBody2D

# Porcupine feels gravity, but no emotion.
# Porcupine will turn around when it gets too close to a wall. 
# If the porcupine is not touching the floor, it does not attack.
# If the player enters the detection area, porcupine will start an attack timer. 
# Once the attack_timer becomes zero, porcupine attacks. 

signal killed

@onready var sprite = $AnimatedSprite2D
@onready var ray_cast_right = $RayCastRight
@onready var ray_cast_left = $RayCastLeft
@onready var gravity_comp = get_node("GravityComponent")

@onready var anim = $Anim
@onready var hurtSFX = $Hurt
@onready var dieSFX = $Die

var facing = -1
var attack_timer = 0 # 0 = not attacking, positive = countdown to attack
@export var speed = 30
@export var attack_time = 50

func attack():
	print("porcupine attack!")
	# emits spines that shoot in random directions close to the porcupine. 
	# only if there is time and it would add to gameplay!

func _physics_process(delta):
	# determine animation to play, and corresponding behavior. 
	if not is_on_floor():
		attack_timer = 0
		sprite.play("fall")
	elif attack_timer: # yes on floor, if attack_timer is not zero:
		sprite.play("attack")
		attack_timer -= 1
		if attack_timer == 0: # if the attack_timer is NOW zero, then attack.
			attack()
		return
	else:
		sprite.play("walk")

	# change direction if there is an obstacle.
	if ray_cast_right.is_colliding():
		facing = -1
		sprite.flip_h = true
	elif ray_cast_left.is_colliding():
		facing = 1
		sprite.flip_h = false
		
	# move x using speed, and y using gravity component.
	velocity.x = facing * speed
	if gravity_comp:
		gravity_comp.handle_gravity(self, delta)
	move_and_slide()

func _on_player_detection_body_entered(body):
	attack_timer = attack_time


# Handle hitbox signals
func _on_hitbox_component_hurt():
	anim.play("hurt")
	hurtSFX.play()

func _on_hitbox_component_killed():
	anim.play("killed")
	dieSFX.play()
	emit_signal("killed")

func _on_die_finished():
	queue_free()
