extends CharacterBody2D

signal landed
signal jumped

const SPEED = 120.0
const JUMP_VELOCITY = -350.0
const COYOTE_MAX = 9

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var jump = false
var coyote = 0

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

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * SPEED
		$Sprite.set_animation("Run")
		if velocity.x < 0:
			$Sprite.scale.x = -1
		else:
			$Sprite.scale.x = 1
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED) #instant stop
		$Sprite.set_animation("Idle")
	
	# Handle airborne sprite animation
	if not is_on_floor():
		$Sprite.set_animation("Airborne")
		if (velocity.y < 0):
			$Sprite.set_frame(0)
		else:
			$Sprite.set_frame(1)
		$Sprite.set_speed_scale(0)
	else:
		$Sprite.set_speed_scale(1)

	move_and_slide()
