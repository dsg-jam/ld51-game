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
@export var _ws_address = "127.0.0.1:8000"

@onready var _board_scene = preload("res://scenes/board_game.tscn")

func _ready():
	self._display_maps()
	self._update_labels()
	DSGNetwork.message_received.connect(_on_ws_received_message)
	var ok := DSGNetwork.connect_websocket("ws://%s/lobby/%s/join" % [self._ws_address, GlobalVariables.id])
	assert(ok)

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
				GlobalVariables.map = Utils.parse_dict_to_map(msg["payload"])
				get_tree().change_scene_to_packed(self._board_scene)

func _server_hello(payload: Variant):
	if not payload["is_host"]:
		self._setup_non_host()
	GlobalVariables.player_id = payload["player_id"]

func _player_joined(_payload: Variant):
	self._amount_of_players += 1
	self._update_labels()

func _setup_non_host():
	self._start_button.queue_free()
	self._label_amount_of_players.visible = false
	self._label_players.visible = false
	self._map_list.visible = false
	GlobalVariables.is_host = false

func _update_labels():
	self._label_id_value.text = GlobalVariables.id
	self._label_amount_of_players.text = str(self._amount_of_players)

func _display_maps():
	for map in MapsDb.MAPS:
		self._map_list.add_item(map["name"])

func _on_maps_list_item_clicked(index, _at_position, _mouse_button_index):
	self._selected_map_idx = index

func _on_copy_button_pressed():
	DisplayServer.clipboard_set(GlobalVariables.id)
