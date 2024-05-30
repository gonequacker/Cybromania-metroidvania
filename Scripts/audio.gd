extends Control



# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_jlayer_landed():
	$Land.play()


func _on_jlayer_jumped():
	$Jump.play()


func _on_jlayer_dashed():
	$Dash.play()


func _on_jlayer_wall_clinged():
	$WallCling.play()


func _on_jlayer_wall_jumped():
	$WallJump.play()


func _on_jlayer_double_jumped():
	$DoubleJump.play()


func collect_coin():
	$CollectCoin.play()
