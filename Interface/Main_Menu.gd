extends Button

@onready var back_to_title_screen = load("res://Scenes/title_screen.tscn") 

func _ready():
	self.button_down.connect(_Button_Pressed)
	
	
func _Button_Pressed():
	get_tree().change_scene_to_packed(back_to_title_screen)
	
	
	
