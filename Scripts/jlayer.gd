extends CharacterBody2D


const SPEED = 120.0
const JUMP_VELOCITY = -350.0
const COYOTE_MAX = 9

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var jump = false
var coyote = 0

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
		if coyote > 0: coyote -= 1
	else:
		coyote = COYOTE_MAX

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and (is_on_floor() or coyote > 0):
		velocity.y = JUMP_VELOCITY
		jump = true
	
	# Handle early release jump cancel.
	if jump and velocity.y < 0 and Input.is_action_just_released("ui_accept") and not is_on_floor():
		velocity.y = 0
		jump = false

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
		if velocity.x < 0:
			$Sprite.scale.x = -1
		else:
			$Sprite.scale.x = 1
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
