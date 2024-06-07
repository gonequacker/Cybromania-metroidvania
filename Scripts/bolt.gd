extends Area2D

var direction = Vector2(1.0,0.0)
var velocity = Vector2(1.0,0.0)
var acceleration = Vector2(0.0, 0.0)
var speed = 250.0
var steer_force = 80.0

var target = null
const VIEW_ANGLE = PI/2.0

const MAX_HITS = 1
var hits = 0

func _ready():
	velocity = direction

func seek():
	var steer = Vector2.ZERO
	var desired = (target.global_position - position).normalized() * speed
	steer = (desired - velocity).normalized() * steer_force
	return steer

func _process(delta):
	if not target:
		calculate_new_target()
	else:
		acceleration += seek()
		velocity += acceleration * delta
	velocity = (velocity*speed).limit_length(speed)
	rotation = velocity.angle()
	position += velocity * delta

func calculate_new_target():
	var enemies = get_tree().get_nodes_in_group("enemy")
	if enemies.size() <= 0: return # no enemies :(
	# calculate closest enemy to projectile
	for enemy in enemies:
		var is_closer = target == null
		if not is_closer:
			is_closer = global_position.distance_squared_to(enemy.global_position) < global_position.distance_squared_to(target.global_position)
		var angle = (enemy.global_position-global_position).angle_to(velocity)
		print(abs(angle))
		var within_angle = abs(angle) < VIEW_ANGLE
		if is_closer and within_angle:
			target = enemy

func _on_timer_timeout():
	queue_free()

func _on_area_entered(area):
	if area.is_in_group("enemy"):
		area.get_parent().get_node("HitboxComponent").take_damage(2)
		hits += 1
		if hits >= MAX_HITS: queue_free()
