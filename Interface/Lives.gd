extends BoxContainer
@onready var lifeFrame = preload("res://Scenes/life_frame.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	life_changed(10)

# Update life counter
func life_changed(player_health):
	var lives_displayed = get_child_count()
	while (player_health != lives_displayed):
		print(player_health)
		print(lives_displayed)
		if lives_displayed > player_health:
			get_children()[-1].queue_free()
			lives_displayed-=1
		elif lives_displayed < player_health:
			add_child(lifeFrame.instantiate()) 
			lives_displayed+=1

