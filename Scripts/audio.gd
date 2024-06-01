extends Control


@onready var land = $SFX/Land
@onready var jump = $SFX/Jump
@onready var dash = $SFX/Dash
@onready var wall_jump = $SFX/WallJump
@onready var wall_cling = $SFX/WallCling
@onready var double_jump = $SFX/DoubleJump
@onready var hurt = $SFX/Hurt


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


func _on_jlayer_hurt():
	hurt.play()
