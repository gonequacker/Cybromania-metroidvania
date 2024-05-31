extends CharacterBody2D

signal landed
signal jumped
signal double_jumped
signal dashed
signal wall_clinged
signal wall_jumped

@export var SPEED = 120.0 # force of walking/moving left and right.
@export var CROUCH_SPEED = 60.0 # force of walking while crouched.
@export var DASH_SPEED = 200.0 # force of dash.
@export var DASH_MAX = 20 # number of frames that the dash lasts for.
@export var DASH_COOLDOWN_MAX = 8 # number of frames after dash wherein player cannot dash.
@export var JUMP_VELOCITY = -350.0 # force of a regular jump.
@export var COYOTE_MAX = 9 # number of frames given for coyote time.
@export var WALL_SLIDE_SPEED = 100 # wall cling fall speed cap.
@export var WALL_COOLDOWN_MAX = 5 # number of frames during which the player moves away from a wall after a wall jump.
@export var FALL_SPEED_MAX = 350 # fall speed cap.
@export var DOUBLE_JUMP_MAX = 10 # number of frames to fall before actually double jumping.

@export var has_crouch = false
@export var has_dash = false
@export var has_double_jump = false
@export var has_wall_jump = false

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var jump = false # true if player is currently jumping.
var double_jump = false # true if player has used their double jump. set to false to give it back.
var facing = 1.0 # 1.0 is right, -1.0 is left.
var coyote = 0 # number of frames of coyote time left.
var dash = 0 # number of frames left in the current dash.
var dash_cooldown = 0 # number of frames left before player can dash again.
var wall_cooldown = 0 # number of frames left to jump away from wall immediately after wall jump.
var double_jump_cooldown = 0 # number of frames left to fall before actually double jumping.

var airborne = false # true if airborne.
var wall_slide = false # true if sliding along a wall.
var crouched = false # true if crouched, making hitbox shorter. also true if dashing.

func _physics_process(delta):
	# Handle crouch.
	if Input.is_action_pressed("crouch") and is_on_floor() and has_crouch: # Player explicitly tries to crouch.
		crouch()
	else: # Try to uncrouch every frame. Uncrouch will automatically fail if there is a low ceiling.
		uncrouch()
	var movespeed = CROUCH_SPEED if crouched else SPEED
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
		if velocity.y > FALL_SPEED_MAX: velocity.y = FALL_SPEED_MAX
		# Handle coyote time.
		if coyote > 0: coyote -= 1
		airborne = true
	else:
		coyote = COYOTE_MAX
		if airborne: emit_signal("landed")
		airborne = false
		double_jump = false

	# Handle jump.
	double_jump_cooldown -= 1
	if Input.is_action_just_pressed("jump") and (is_on_floor() or coyote > 0):
		velocity.y = JUMP_VELOCITY
		jump = true
		emit_signal("jumped")
	elif Input.is_action_just_pressed("jump") and not double_jump and not wall_slide and dash < 0 and has_double_jump:
		double_jump_cooldown = DOUBLE_JUMP_MAX
		double_jump = true
		emit_signal("double_jumped")
	
	if double_jump_cooldown == 0 and has_double_jump:
		velocity.y = JUMP_VELOCITY
	
	# Handle early release jump cancel.
	if jump and velocity.y < 0 and Input.is_action_just_released("jump"):
		velocity.y = 0
		jump = false

	# Get the input direction.
	var direction = Input.get_axis("left", "right")
	# Dash.
	dash -= 1
	dash_cooldown -= 1
	if Input.is_action_just_pressed("dash") and dash <= 0 and dash_cooldown <= 0 and has_dash:
		velocity.x = facing * DASH_SPEED
		dash = DASH_MAX
		dash_cooldown = DASH_MAX + DASH_COOLDOWN_MAX
		emit_signal("dashed")
	
	# Wall jumping.
	wall_cooldown -= 1
	if is_on_wall_only() and velocity.y > 0 and has_wall_jump:
		if not wall_slide and dash <= 0:
			wall_slide = true
			emit_signal("wall_clinged")
			double_jump = false
		if velocity.y > WALL_SLIDE_SPEED:
			velocity.y = WALL_SLIDE_SPEED
			if Input.is_action_just_pressed("jump"):
				wall_cooldown = WALL_COOLDOWN_MAX
				velocity.x = -facing * movespeed
				velocity.y = JUMP_VELOCITY
				jump = true
				emit_signal("wall_jumped")
	else:
		wall_slide = false
	
	# Handle the movement/deceleration.
	if dash > 0:
		velocity.y = 0
		crouch()
	elif wall_cooldown > 0:
		velocity.x = -facing * movespeed
	elif direction:
		velocity.x = direction * movespeed
		facing = sign(direction)
		if not crouched: $Sprite.set_animation("Run")
		$Sprite.scale.x = facing
		$CrouchCollider.scale.x = facing
	else:
		velocity.x = move_toward(velocity.x, 0, movespeed) #instant stop
		if not crouched: $Sprite.set_animation("Idle")
	
	# Handle airborne sprite animation.
	if not is_on_floor() and not crouched and dash <= 0:
		$Sprite.set_animation("Airborne")
		if (velocity.y < 0):
			$Sprite.set_frame(0)
		else:
			$Sprite.set_frame(1)
	
	# Handle wall riding.
	if is_on_wall_only() and velocity.y > 0 and has_wall_jump:
		$Sprite.set_animation("Wall")
	
	# Handle crouch sprite animation.
	if crouched:
		if dash > 0:
			$Sprite.set_animation("Dash")
		else:
			$Sprite.set_animation("Crouch")
	
	if double_jump_cooldown > 0:
		$Sprite.set_animation("Doublejump")

	move_and_slide()


func crouch():
	$Collider.disabled = true
	$CrouchCollider.disabled = false
	crouched = true
func uncrouch():
	if not is_bonking():
		$Collider.disabled = false
		$CrouchCollider.disabled = true
		crouched = false

func is_bonking():
	return $HeadBonker.is_colliding() or $HeadBonker2.is_colliding()
