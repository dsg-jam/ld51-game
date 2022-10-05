extends Node2D
var board_scene = preload("res://scenes/board_game.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	$ColorRect/VBoxContainer/HBoxContainer/IDValue.text = GlobalVariables.id
	DSGNetwork.set_url(GlobalVariables.id)
	assert(DSGNetwork.connect_websocket())


func _on_start_game_button_pressed():
	get_tree().change_scene_to_packed(board_scene)
