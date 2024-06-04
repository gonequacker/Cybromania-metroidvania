extends CharacterBody2D

@onready var pickup_rect = $ColorRect
@onready var invuln_anim = $InvulnAnim
@onready var sprite = $Sprite
@onready var collider = $Collider
@onready var crouch_collider = $CrouchCollider
@onready var head_bonker_1 = $HeadBonker
@onready var head_bonker_2 = $HeadBonker2

const ICON = preload("res://icon.svg")
const PROJECTILE = preload("res://Scenes/projectile.tscn")

signal landed
signal jumped
signal double_jumped
signal dashed
signal wall_clinged
signal wall_jumped
signal hurt
signal healed

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@export var SPEED = 110.0 # force of walking/moving left and right.
@export var CROUCH_SPEED = 60.0 # force of walking while crouched.
@export var DASH_SPEED = 200.0 # force of dash.
@export var DASH_MAX = 20 # number of frames that the dash lasts for.
@export var DASH_COOLDOWN_MAX = 8 # number of frames after dash wherein player cannot dash.
@export var JUMP_HEIGHT = 3 # jump height, in tiles.
var JUMP_VELOCITY = -sqrt(2.0*gravity*JUMP_HEIGHT*16.0) - 0.1 # force of a regular jump.
@export var DOUBLE_JUMP_VELOCITY = -420.0 # force of a double jump.
@export var COYOTE_MAX = 9 # number of frames given for coyote time.
@export var WALL_SLIDE_SPEED = 100.0 # wall cling fall speed cap.
@export var WALL_COOLDOWN_MAX = 7 # number of frames during which the player moves away from a wall after a wall jump.
@export var FALL_SPEED_MAX = 350 # fall speed cap.
@export var DOUBLE_JUMP_MAX = 10 # number of frames to fall before actually double jumping.
@export var HEALTH_MAX = 10 # max health, to be given at the start of the game.
@export var INVULN_MAX = 60 * 3 # number of invulnerability frames to be given after damage.
@export var JUMP_BUFFER_MAX = 15 # number of frames to buffer a jump input right before landing.

var jump = false # true if player is currently jumping.
var double_jump = false # true if player has used their double jump. set to false to give it back.
var facing = 1.0 # 1.0 is right, -1.0 is left.
var facing_vertical = 0.0 # 1.0 is up, -1.0 is down
var coyote = 0 # number of frames of coyote time left.
var dash = 0 # number of frames left in the current dash.
var dash_cooldown = 0 # number of frames left before player can dash again.
var wall_cooldown = 0 # number of frames left to jump away from wall immediately after wall jump.
var double_jump_cooldown = 0 # number of frames left to fall before actually double jumping.
var health = HEALTH_MAX # player's current health.
var invuln = 0 # number of frames of invulnerability left.
var jump_buffer = 0 # number of frames of jump buffer left.

var airborne = false # true if airborne.
var wall_slide = false # true if sliding along a wall.
var crouched = false # true if crouched, making hitbox shorter. also true if dashing.

var weapon = 0 # currently held weapon.

func _ready():
	Global.set_player_reference(self) # tbh im not sure why im doing this
	print(JUMP_VELOCITY)

func _physics_process(delta):
	handle_inputs(delta)
	move_and_slide()
	handle_animations()
	handle_invulnerability()


func handle_inputs(delta):
	# Handle crouch.
	if Input.is_action_pressed("crouch") and is_on_floor() and has_crouch(): # Player explicitly tries to crouch.
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
		double_jump_cooldown = 0

	# Handle jump.
	double_jump_cooldown -= 1
	jump_buffer -= 1
	if (Input.is_action_just_pressed("jump") or jump_buffer > 0) and (is_on_floor() or coyote > 0): # Regular jump.
		velocity.y = JUMP_VELOCITY
		jump = true
		emit_signal("jumped")
		jump_buffer = 0
	elif Input.is_action_just_pressed("jump") and not double_jump and not wall_slide and dash < 0 and has_double_jump(): # Double jump.
		double_jump_cooldown = DOUBLE_JUMP_MAX
		double_jump = true
		jump = true
	if Input.is_action_just_pressed("jump") and not is_on_floor(): # Jump buffer.
		jump_buffer = JUMP_BUFFER_MAX
	
	# Handle double jump.
	if double_jump_cooldown == 0 and has_double_jump():
		velocity.y = DOUBLE_JUMP_VELOCITY
		emit_signal("double_jumped")
	
	# Handle early release jump cancel.
	if jump and velocity.y < 0 and Input.is_action_just_released("jump"):
		velocity.y = 0
		jump = false

	# Get the input direction.
	var direction = Input.get_axis("left", "right")
	# Dash.
	dash -= 1
	dash_cooldown -= 1
	if Input.is_action_just_pressed("dash") and dash <= 0 and dash_cooldown <= 0 and has_dash():
		velocity.x = facing * DASH_SPEED
		dash = DASH_MAX
		dash_cooldown = DASH_MAX + DASH_COOLDOWN_MAX
		emit_signal("dashed")
	
	# Wall jumping.
	wall_cooldown -= 1
	if is_on_wall_only() and velocity.y > 0 and has_wall_jump():
		if not wall_slide and dash <= 0: # Can grab wall if not dashing
			wall_slide = true
			emit_signal("wall_clinged")
			double_jump = false
		if velocity.y > WALL_SLIDE_SPEED: # Slow descent when grabbing wall
			velocity.y = WALL_SLIDE_SPEED
		if Input.is_action_just_pressed("jump"): # Initiate wall jump
			wall_cooldown = WALL_COOLDOWN_MAX
			velocity.x = -facing * movespeed
			velocity.y = JUMP_VELOCITY
			jump = true
			emit_signal("wall_jumped")
	else:
		wall_slide = false
	
	# Handle the movement/deceleration.
	if dash > 0: # Dashing
		velocity.y = 0 # Halt vertical movement
		crouch() # Activate smaller hitbox
	elif wall_cooldown > 0: # Currently jumping off of wall
		velocity.x = -facing * movespeed # Moving away from wall
	elif direction: # Just plain moving left/right
		velocity.x = direction * movespeed
		facing = sign(direction)
		sprite.scale.x = facing
		crouch_collider.scale.x = facing
	else: # Not moving at all
		velocity.x = move_toward(velocity.x, 0, movespeed) #instant stop
	
	# Handle up/down look
	if airborne:
		facing_vertical = Input.get_axis("up", "crouch")
		if facing_vertical != 0.0:
			facing_vertical /= abs(facing_vertical)
	elif Input.is_action_pressed("up"):
		facing_vertical = -1.0
	else:
		facing_vertical = 0.0
	
	# Handle attack input(s).
	if Input.is_action_just_pressed("attack") and dash <= 0 and wall_cooldown <= 0 and double_jump_cooldown <= 0:
		attack()
	
	# Handle hotbar inputs.
	if Input.is_action_just_pressed("heal"):
		heal()


func handle_animations():
	if crouched: # All animations to play while crouched.
		if dash > 0: # Dashing
			sprite.play("Dash")
		else: # Crouching
			sprite.play("Crouch")
	elif wall_slide: # Wall sliding
		sprite.play("Wall")
	elif double_jump_cooldown > 0: # Double jumping
		sprite.play("Doublejump")
	elif not is_on_floor(): # Airborne
		sprite.play("Airborne")
		if (velocity.y < 0): # Rising
			sprite.set_frame(0)
		else: # Falling
			sprite.set_frame(1)
	elif abs(velocity.x) > 0.1: # Running
		sprite.play("Run")
	else: # Idling
		sprite.play("Idle")


# Helper functions.
# Horizontal facing (taking into account wall riding)
func facing_horizontal():
	return -facing if wall_slide else facing
# Try to crouch the player.
func crouch():
	collider.disabled = true
	crouch_collider.disabled = false
	crouched = true
# Try to uncrouch the player (fails if low ceiling)
func uncrouch():
	if not is_bonking():
		collider.disabled = false
		crouch_collider.disabled = true
		crouched = false
# Check if head will bonk when uncrouching
func is_bonking():
	return head_bonker_1.is_colliding() or head_bonker_2.is_colliding()
# Check inventory for key items
func has_crouch():
	return Global.inventory["crouch"] > 0
func has_dash():
	return Global.inventory["dash"] > 0
func has_wall_jump():
	return Global.inventory["wall_jump"] > 0
func has_double_jump():
	return Global.inventory["double_jump"] > 0


func handle_invulnerability():
	# Handle invulnerability.
	invuln -= 1
	# Disable invuln anim if not invulnerable.
	if invuln <= 0:
		invuln_anim.play("RESET")
# Called by killzone when player takes damage
func take_damage(amount):
	# Check that the player is vulnerable
	if invuln > 0: return
	# Take damage
	health -= amount
	# Give player invulnerability
	invuln = INVULN_MAX
	invuln_anim.play("invuln")
	# Play hurt sound
	emit_signal("hurt")
	# Update UI
	# TODO: Link to some UI elements
	print(str(health) + "/" + str(HEALTH_MAX))
# Heal player by some amount.
func heal():
	# Exit early if player is already at max health
	if health >= HEALTH_MAX: return
	# Use a health item
	var amount = Global.heal(HEALTH_MAX - health)
	# Heal player
	health += amount
	# Cap health to the max health amount
	if health > HEALTH_MAX: health = HEALTH_MAX
	# Play heal sound
	emit_signal("healed")
	# Update UI
	# TODO: Link to some UI elements
	print(str(health) + "/" + str(HEALTH_MAX))


func attack():
	var direction
	if (facing_vertical != 0.0):
		direction = Vector2(0.0, facing_vertical)
	else:
		direction = Vector2(facing_horizontal(), 0.0)
	var bullet = PROJECTILE.instantiate()
	bullet.position = position
	bullet.direction = direction
	get_parent().add_child(bullet)
