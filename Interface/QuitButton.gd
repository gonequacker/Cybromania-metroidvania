extends Button


# Called when the node enters the scene tree for the first time.
func _ready():
	self.pressed.connect(_button_pressed)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func _button_pressed():
	get_tree().quit()
