extends CharacterBody2D

signal landed
signal jumped

const SPEED = 120.0
const DASH_SPEED = 200.0
const DASH_MAX = 20
const DASH_COOLDOWN_MAX = 5
const JUMP_VELOCITY = -350.0
const COYOTE_MAX = 9

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var jump = false
var facing = 1.0
var coyote = 0
var dash = 0
var dash_cooldown = 0

var airborne = false

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
		# Handle coyote time.
		if coyote > 0: coyote -= 1
		airborne = true
	else:
		coyote = COYOTE_MAX
		if airborne: emit_signal("landed")
		airborne = false

	# Handle jump.
	if Input.is_action_just_pressed("jump") and (is_on_floor() or coyote > 0):
		velocity.y = JUMP_VELOCITY
		jump = true
		emit_signal("jumped")
	
	# Handle early release jump cancel.
	if jump and velocity.y < 0 and Input.is_action_just_released("jump") and not is_on_floor():
		velocity.y = 0
		jump = false

	# Get the input direction.
	var direction = Input.get_axis("left", "right")
	# Dash.
	dash -= 1
	dash_cooldown -= 1
	if Input.is_action_just_pressed("dash") and dash <= 0 and dash_cooldown <= 0:
		velocity.x = facing * DASH_SPEED
		dash = DASH_MAX
		dash_cooldown = DASH_MAX + DASH_COOLDOWN_MAX
	
	# Handle the movement/deceleration.
	if dash > 0:
		velocity.y = 0
		$Sprite.set_animation("Dash")
	elif direction:
		velocity.x = direction * SPEED
		facing = sign(direction)
		$Sprite.set_animation("Run")
		$Sprite.scale.x = facing
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED) #instant stop
		$Sprite.set_animation("Idle")
	
	# Handle airborne sprite animation.
	if not is_on_floor() and dash <= 0:
		$Sprite.set_animation("Airborne")
		if (velocity.y < 0):
			$Sprite.set_frame(0)
		else:
			$Sprite.set_frame(1)
		$Sprite.set_speed_scale(0)
	else:
		$Sprite.set_speed_scale(1)

	move_and_slide()
