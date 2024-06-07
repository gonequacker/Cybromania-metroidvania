extends CharacterBody2D

@onready var invuln_anim = $InvulnAnim
@onready var sprite = $Sprite
@onready var collider = $Collider
@onready var crouch_collider = $CrouchCollider
@onready var head_bonker_1 = $HeadBonker
@onready var head_bonker_2 = $HeadBonker2

@onready var landSFX = $SFX/Land
@onready var jumpSFX = $SFX/Jump
@onready var dashSFX = $SFX/Dash
@onready var wall_jumpSFX = $SFX/WallJump
@onready var wall_clingSFX = $SFX/WallCling
@onready var double_jumpSFX = $SFX/DoubleJump
@onready var hurtSFX = $SFX/Hurt
@onready var healSFX = $SFX/Heal

@onready var firewallSFX = $SFX/Weapon/Firewall
@onready var daggerSFX = $SFX/Weapon/Dagger
@onready var pikeSFX = $SFX/Weapon/Pike
@onready var arbalestSFX = $SFX/Weapon/Arbalest
@onready var blackholeSFX = $SFX/Weapon/Blackhole

const PROJECTILE_S = preload("res://Scenes/Projectiles/projectile.tscn")
const FIREWALL_S = preload("res://Scenes/Projectiles/firewall.tscn")
const PIKE_S = preload("res://Scenes/Projectiles/pike.tscn")
const DAGGER_S = preload("res://Scenes/Projectiles/dagger.tscn")
const BLACKHOLE_S = preload("res://Scenes/Projectiles/blackhole.tscn")
const BOLT_S = preload("res://Scenes/Projectiles/bolt.tscn")

signal hurt(player_health)
signal healed(player_health)

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

enum {HAND, STAFF, PIKE, DAGGER, LAUNCHER, ARBALEST}
var ATTACK_MAX = {
	HAND: 25,
	STAFF: 60,
	PIKE: 30,
	DAGGER: 8,
	LAUNCHER: 75,
	ARBALEST: 15
}

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

var weapon = HAND # currently held weapon.
var weapon_cooldown = 0 # frames until player can attack again.


func _ready():
	Global.set_player_reference(self) # tbh im not sure why im doing this
	connect("hurt", get_parent().get_parent().get_node("UI/HUD/Lives").life_changed)
	connect("hurt", get_parent().get_parent().get_node("UI/GameOver").life_changed)
	connect("healed", get_parent().get_parent().get_node("UI/HUD/Lives").life_changed)
	emit_signal("healed", HEALTH_MAX)


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
		if airborne: landSFX.play()
		airborne = false
		double_jump = false
		double_jump_cooldown = 0

	# Handle jump.
	double_jump_cooldown -= 1
	jump_buffer -= 1
	if (Input.is_action_just_pressed("jump") or jump_buffer > 0) and (is_on_floor() or coyote > 0): # Regular jump.
		velocity.y = JUMP_VELOCITY
		jump = true
		jumpSFX.play()
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
		double_jumpSFX.play()
	
	# Handle early release jump cancel.
	if jump and velocity.y < 0 and Input.is_action_just_released("jump"):
		velocity.y /= 3.0
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
		dashSFX.play()
	
	# Wall jumping.
	wall_cooldown -= 1
	if is_on_wall_only() and velocity.y > 0 and has_wall_jump():
		if not wall_slide and dash <= 0: # Can grab wall if not dashing
			wall_slide = true
			wall_clingSFX.play()
			double_jump = false
		if velocity.y > WALL_SLIDE_SPEED: # Slow descent when grabbing wall
			velocity.y = WALL_SLIDE_SPEED
		if Input.is_action_just_pressed("jump"): # Initiate wall jump
			wall_cooldown = WALL_COOLDOWN_MAX
			velocity.x = -facing * movespeed
			velocity.y = JUMP_VELOCITY
			jump = true
			wall_jumpSFX.play()
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
	
	# Handle hotbar inputs. (yikes)
	if Input.is_action_just_pressed("1"):
		weapon = HAND
	if Input.is_action_just_pressed("2") and has_staff():
		weapon = STAFF
	if Input.is_action_just_pressed("3") and has_pike():
		weapon = PIKE
	if Input.is_action_just_pressed("4") and has_dagger():
		weapon = DAGGER
	if Input.is_action_just_pressed("5") and has_launcher():
		weapon = LAUNCHER
	if Input.is_action_just_pressed("6") and has_arbalest():
		weapon = ARBALEST
	
	# Handle item inputs.
	if Input.is_action_just_pressed("heal"):
		heal()
	
	# Handle attack input(s).
	weapon_cooldown -= 1
	if Input.is_action_pressed("attack") and weapon_cooldown <= 0 and dash <= 0 and wall_cooldown <= 0 and double_jump_cooldown <= 0:
		attack()


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
# Check inventory for weapons
func has_staff():
	return Global.inventory["spell"] > 0
func has_pike():
	return Global.inventory["pike"] > 0
func has_dagger():
	return Global.inventory["daggers"] > 0
func has_launcher():
	return Global.inventory["launcher"] > 0
func has_arbalest():
	return Global.inventory["arbalest"] > 0


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
	hurtSFX.play()
	# Update UI
	emit_signal("hurt", health)
# Heal player by some amount.
func heal():
	# Exit early if player is already at max health
	if health >= HEALTH_MAX: return
	# Use a health item
	var amount = Global.heal(HEALTH_MAX - health)
	# Exit early if player is out of health items
	if amount <= 0: return
	# Heal player
	health += amount
	# Cap health to the max health amount
	if health > HEALTH_MAX: health = HEALTH_MAX
	# Play heal sound
	healSFX.play()
	# Update UI
	emit_signal("healed", health)


func attack():
	# Calculate direction that attack should face (based on how Hollow Knight does it)
	var direction
	if (facing_vertical != 0.0):
		direction = Vector2(0.0, facing_vertical)
	else:
		direction = Vector2(facing_horizontal(), 0.0)
	# Take into account current weapon.
	match weapon:
		HAND:
			pass#spawn_proj(direction, PROJECTILE_S)
		STAFF:
			spawn_proj(direction, FIREWALL_S)
			firewallSFX.play()
		PIKE:
			spawn_melee(direction, PIKE_S)
			pikeSFX.play()
		DAGGER:
			spawn_proj(direction, DAGGER_S)
			daggerSFX.play()
		LAUNCHER:
			spawn_proj(direction, BLACKHOLE_S)
			blackholeSFX.play()
		ARBALEST:
			spawn_proj(direction, BOLT_S)
			arbalestSFX.play()
	# Attack cooldown
	weapon_cooldown = ATTACK_MAX[weapon]
# Attacking functions
func spawn_proj(direction, projectile):
	var proj = projectile.instantiate()
	proj.position = position + Vector2(0.0, 5.0 if crouched else 1.0)
	proj.direction = direction
	get_parent().add_child(proj)
func spawn_melee(direction, melee):
	var proj = melee.instantiate()
	proj.position = Vector2(0.0, 5.0 if crouched else 1.0)
	proj.direction = direction
	add_child(proj)
