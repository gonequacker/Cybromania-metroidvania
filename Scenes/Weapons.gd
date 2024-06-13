extends BoxContainer
enum {HAND, STAFF, PIKE, DAGGER, LAUNCHER, ARBALEST}

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func player_attacked(weapon):
	get_child(weapon - 2).modulate = Color.DIM_GRAY
	
func off_cooldown(weapon):
	match weapon:
		STAFF:
			get_child(0).modulate = Color.WHITE
		PIKE:
			get_child(1).modulate = Color.WHITE
		DAGGER:
			get_child(2).modulate = Color.WHITE
		LAUNCHER:
			get_child(3).modulate = Color.WHITE
		ARBALEST:
			get_child(4).modulate = Color.WHITE
