extends Button

##func _toggled():
# Called when the node enters the scene tree for the first time.
func _ready():
	self.button_down.connect(self._button_pressed)
	
	
func _button_pressed():
	get_tree().paused = false
	self.get_parent().get_parent().hide()
