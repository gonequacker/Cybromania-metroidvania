extends Button


# Called when the node enters the scene tree for the first time.
func _ready():
	self.pressed.connect(self._button_pressed)



func _button_pressed():
	self.get_parent().get_parent().hide()