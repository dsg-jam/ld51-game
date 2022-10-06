extends Node2D

@export var start_button: Button

@onready var board_scene = preload("res://scenes/board_game.tscn")

func _ready():
	$ColorRect/VBoxContainer/HBoxContainer/IDValue.text = GlobalVariables.id
	assert(DSGNetwork.connect_websocket("ws://127.0.0.1:8000/lobby/%s/join" % GlobalVariables.id))
	DSGNetwork.ws_received_message.connect(_on_ws_received_message)


func _on_start_game_button_pressed():
	get_tree().change_scene_to_packed(board_scene)


func _on_ws_received_message(stream: String):
	var message = JSON.parse_string(stream)
	if message["type"] == "server_hello":
		if not message["payload"]["is_host"]:
			start_button.queue_free()
		GlobalVariables.player_id = message["payload"]["player_id"]
