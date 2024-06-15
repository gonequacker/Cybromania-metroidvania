extends BoxContainer
var stylebox
var newStyle

# Called when the node enters the scene tree for the first time.
func _ready():
	stylebox = $FirewallOutline.get_theme_stylebox('panel')
	stylebox.border_color = Color("FFFF0000")
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func weapon_changed(weapon):
	# Remove previous outline
	$FirewallOutline.add_theme_stylebox_override("panel", stylebox)
	$BlackoleOutline.add_theme_stylebox_override("panel", stylebox)
	$DMARCOutline.add_theme_stylebox_override("panel", stylebox)
	$PQOutline.add_theme_stylebox_override("panel", stylebox)
	$AntivirusOutline.add_theme_stylebox_override("panel", stylebox)
	# Outline chosen weapon
	match weapon:
		1:
			pass
		2:
			var newStyle = stylebox.duplicate()
			newStyle.border_color = Color("FFFF00")
			$FirewallOutline.add_theme_stylebox_override("panel", newStyle)
		3:
			var newStyle = stylebox.duplicate()
			newStyle.border_color = Color("FFFF00")
			$BlackoleOutline.add_theme_stylebox_override("panel", newStyle)
		4:
			var newStyle = stylebox.duplicate()
			newStyle.border_color = Color("FFFF00")
			$DMARCOutline.add_theme_stylebox_override("panel", newStyle)
		5:
			var newStyle = stylebox.duplicate()
			newStyle.border_color = Color("FFFF00")
			$PQOutline.add_theme_stylebox_override("panel", newStyle)
		6:
			var newStyle = stylebox.duplicate()
			newStyle.border_color = Color("FFFF00")
			$AntivirusOutline.add_theme_stylebox_override("panel", newStyle)
