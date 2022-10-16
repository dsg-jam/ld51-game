extends Control

const MapsDb := preload("res://scripts/db/maps.gd")

# you just gotta love how PackedStringArray isn't const
var MSG_FILTER := PackedStringArray([
	DSGMessageType.PLAYER_JOINED,
	DSGMessageType.SERVER_HELLO,
	DSGMessageType.SERVER_START_GAME,
])

var _amount_of_players: int = 1
var _selected_map_idx: int = -1

@export var _start_button: Button
@export var _label_id_value: Label
@export var _label_amount_of_players: Label
@export var _label_players: Label
@export var _map_list: ItemList
@export var _pop_up: Panel

@onready var _board_scene = preload("res://scenes/board_game.tscn")

func _ready():
	self._display_maps()
	self._update_labels()
	self._start_button.set_visible(false)
	DSGNetwork.message_received.connect(_on_ws_received_message)
	DSGNetwork.connected_to_server.connect(_on_ws_connected)
	DSGNetwork.connect_to_lobby(GlobalVariables.id)

func _on_start_game_button_pressed():
	if self._selected_map_idx < 0:
		return
	var start_message = {
		"type": DSGMessageType.HOST_START_GAME,
		"payload": {
			"platform": Utils.parse_map_to_dict(
				MapsDb.MAPS[self._selected_map_idx]["map_string"]
				)
		}
	}
	DSGNetwork.send(start_message)

func _on_ws_connected():
	self._pop_up.set_visible(false)

func _on_ws_received_message(_msg_type: String) -> void:
	while true:
		var msg: Variant = DSGNetwork.pop_pending_message(MSG_FILTER)
		if msg == null:
			break
		match msg["type"]:
			DSGMessageType.SERVER_HELLO:
				self._server_hello(msg["payload"])
			DSGMessageType.PLAYER_JOINED:
				self._player_joined(msg["payload"])
			DSGMessageType.SERVER_START_GAME:
				self._server_start_game(msg["payload"])

func _server_hello(payload: Variant):
	if not payload["is_host"]:
		self._setup_non_host()
	var player = payload["player"]
	GlobalVariables.player_id = player["id"]
	GlobalVariables.player_number = player["number"]
	GlobalVariables.session_id = payload["session_id"]

func _player_joined(_payload: Variant):
	self._amount_of_players += 1
	self._update_labels()

func _server_start_game(payload: Dictionary):
	GlobalVariables.map = Utils.parse_dict_to_map(payload)
	var players = payload["players"]
	for player in players:
		GlobalVariables.players[player["id"]] = player["number"]
	GlobalVariables.pieces = payload["pieces"]
	get_tree().change_scene_to_packed(self._board_scene)

func _setup_non_host():
	self._start_button.queue_free()
	self._label_amount_of_players.visible = false
	self._label_players.visible = false
	self._map_list.visible = false
	GlobalVariables.is_host = false

func _update_labels():
	self._label_id_value.text = GlobalVariables.id
	self._label_amount_of_players.text = str(self._amount_of_players)
	self._start_button.set_visible(self._amount_of_players > 1)

func _display_maps():
	for map in MapsDb.MAPS:
		self._map_list.add_item(map["name"])

func _on_maps_list_item_clicked(index, _at_position, _mouse_button_index):
	self._selected_map_idx = index

func _on_copy_button_pressed():
	DisplayServer.clipboard_set(GlobalVariables.id)
