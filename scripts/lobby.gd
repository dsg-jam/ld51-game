extends Node2D

var _amount_of_players = 1

@export var start_button: Button
@export var label_id_value: Label
@export var label_amount_of_players: Label
@export var label_players: Label
@export var ws_address = "127.0.0.1:8000"

@onready var board_scene = preload("res://scenes/board_game.tscn")

func _ready():
	_update_labels()
	DSGNetwork.ws_received_message.connect(_on_ws_received_message)
	assert(DSGNetwork.connect_websocket("ws://%s/lobby/%s/join" % [ws_address, GlobalVariables.id]))

func _on_start_game_button_pressed():
	var _start_message = {
		"type": "start_game",
		"payload": {}
	}
	# TODO: type `start_game` is not implemented yet on the server side
	# DSGNetwork.send(JSON.stringify(start_message).to_utf8_buffer())
	get_tree().change_scene_to_packed(board_scene)

func _on_ws_received_message(stream: String):
	var message = JSON.parse_string(stream)
	if message["type"] == "server_hello":
		_server_hello(message["payload"])
	elif message["type"] == "player_joined":
		_player_joined(message["payload"])

func _server_hello(payload: Variant):
	if not payload["is_host"]:
		_setup_non_host()
	GlobalVariables.player_id = payload["player_id"]

func _player_joined(_payload: Variant):
	_amount_of_players += 1
	_update_labels()

func _setup_non_host():
	start_button.queue_free()
	label_amount_of_players.visible = false
	label_players.visible = false
	GlobalVariables.is_host = false

func _update_labels():
	label_id_value.text = GlobalVariables.id
	label_amount_of_players.text = str(_amount_of_players)
