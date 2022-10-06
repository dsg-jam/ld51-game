extends Node2D

@onready var board_scene = preload("res://scenes/board_game.tscn")
@onready var network = get_node("/root/DSGNetwork")

func _ready():
	$ColorRect/VBoxContainer/HBoxContainer/IDValue.text = GlobalVariables.id
	DSGNetwork.set_url(GlobalVariables.id)
	assert(DSGNetwork.connect_websocket())
	network.ws_received_message.connect(_on_ws_received_message)


func _on_start_game_button_pressed():
	get_tree().change_scene_to_packed(board_scene)


func _on_ws_received_message(message: String):
	# TODO: Receive server's hello message
	print(message)
