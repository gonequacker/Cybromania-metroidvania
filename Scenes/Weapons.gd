extends BoxContainer
enum {HAND, STAFF, PIKE, DAGGER, LAUNCHER, ARBALEST}
var nativeCooldown = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var has_firewall = Global.inventory["spell"] > 0
	var has_pike = Global.inventory["pike"] > 0
	var has_daggers = Global.inventory["daggers"] > 0
	var has_launcher = Global.inventory["launcher"] > 0
	var has_arbalest = Global.inventory["arbalest"] > 0
	if has_firewall: $Firewall/TextureRect.visible = true
	if has_pike: $PQ/TextureRect.visible = true
	if has_daggers: $DMARC/TextureRect.visible = true
	if has_launcher: $Blackhole/TextureRect.visible = true
	if has_arbalest: $Antivirus/TextureRect.visible = true

func player_attacked(weapon):
	get_child(weapon - 2).modulate = Color.DIM_GRAY
	
	
func off_cooldown(weapon):
	for child in get_children():
		child.modulate = Color.WHITE
	'''''
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
	'''
