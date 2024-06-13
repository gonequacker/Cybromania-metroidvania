extends AudioStreamPlayer

@onready var music_bus_id = AudioServer.get_bus_index("Music")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if get_tree().paused:
		AudioServer.set_bus_bypass_effects(music_bus_id, false)
	else:
		AudioServer.set_bus_bypass_effects(music_bus_id, true)
