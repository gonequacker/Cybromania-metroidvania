extends Button


# Called when the node enters the scene tree for the first time.
func _ready():
	self.pressed.connect(self._button_pressed)
	
func _button_pressed():
	get_tree().paused = false
	get_tree().reload_current_scene()
	get_parent().get_parent().get_parent().visible = false
	
	Global.inventory = {
	"crouch": 0,
	"dash": 0,
	"wall_jump": 0,
	"double_jump": 0,
	"spell": 0,
	"launcher": 0,
	"daggers": 0,
	"pike": 0,
	"arbalest": 0,
	"bytes": 0,
	"cookies": 0
}
	
