extends Control


@onready var land = $SFX/Land
@onready var jump = $SFX/Jump
@onready var dash = $SFX/Dash
@onready var wall_jump = $SFX/WallJump
@onready var wall_cling = $SFX/WallCling
@onready var double_jump = $SFX/DoubleJump


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_jlayer_landed():
	land.play()


func _on_jlayer_jumped():
	jump.play()


func _on_jlayer_dashed():
	dash.play()


func _on_jlayer_wall_clinged():
	wall_cling.play()


func _on_jlayer_wall_jumped():
	wall_jump.play()


func _on_jlayer_double_jumped():
	double_jump.play()
