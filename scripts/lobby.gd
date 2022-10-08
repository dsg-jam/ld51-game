extends Node2D

const MapsDb := preload("res://scripts/db/maps.gd")

var _amount_of_players = 1
var _selected_map_idx = -1

@export var start_button: Button
@export var label_id_value: Label
@export var label_amount_of_players: Label
@export var label_players: Label
@export var map_list: ItemList
@export var ws_address = "127.0.0.1:8000"

@onready var board_scene = preload("res://scenes/board_game.tscn")

func _ready():
	self._display_maps()
	self._update_labels()
	DSGNetwork.ws_received_message.connect(_on_ws_received_message)
	assert(DSGNetwork.connect_websocket("ws://%s/lobby/%s/join" % [ws_address, GlobalVariables.id]))

func _on_start_game_button_pressed():
	if self._selected_map_idx < 0:
		return
	var start_message = {
		"type": "host_start_game",
		"payload": {
			"platform": Utils.parse_map_to_dict(
				MapsDb.MAPS[self._selected_map_idx]["map_string"]
				)
		}
	}
	DSGNetwork.send(start_message)

func _on_ws_received_message(stream: String):
	var message = JSON.parse_string(stream)

	if message["type"] == "server_hello":
		self._server_hello(message["payload"])
	elif message["type"] == "player_joined":
		self._player_joined(message["payload"])
	elif message["type"] == "server_start_game":
		GlobalVariables.map = Utils.parse_dict_to_map(message["payload"])
		get_tree().change_scene_to_packed(self.board_scene)

func _server_hello(payload: Variant):
	if not payload["is_host"]:
		self._setup_non_host()
	GlobalVariables.player_id = payload["player_id"]

func _player_joined(_payload: Variant):
	self._amount_of_players += 1
	self._update_labels()

func _setup_non_host():
	self.start_button.queue_free()
	self.label_amount_of_players.visible = false
	self.label_players.visible = false
	self.map_list.visible = false
	GlobalVariables.is_host = false

func _update_labels():
	self.label_id_value.text = GlobalVariables.id
	self.label_amount_of_players.text = str(self._amount_of_players)

func _display_maps():
	for map in MapsDb.MAPS:
		map_list.add_item(map["name"])
		print(map)


func _on_maps_list_item_clicked(index, at_position, mouse_button_index):
	print(index)
	self._selected_map_idx = index
