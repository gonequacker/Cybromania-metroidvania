extends Button


# Called when the node enters the scene tree for the first time.
func _ready():
	self.pressed.connect(self._button_pressed);


func _button_pressed():
	get_parent().get_parent().get_child(4).show()
