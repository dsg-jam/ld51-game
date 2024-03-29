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
@export var _map_list: ItemList
@export var _pop_up: Panel
@export var _info: Label

@onready var _board_scene = preload("res://scenes/board_game.tscn")

func _ready():
	DSGNetwork.message_received.connect(_on_ws_received_message)
	DSGNetwork.connected_to_server.connect(_on_ws_connected)
	DSGNetwork.connection_closed.connect(_on_ws_closed)
	self._setup_lobby()

func _setup_lobby():
	self._display_maps()
	self._update_labels()
	self._start_button.set_visible(false)
	if not DSGNetwork.is_online():
		DSGLogger.lobby_log("trying to connect to lobby with join-code: %s" % GlobalVariables.join_code)
		DSGNetwork.connect_to_lobby()
		return
	self._amount_of_players = len(GlobalVariables.players)
	self._info.text = _get_game_result()
	self._setup_after_connection()

func _setup_after_connection():
	self._pop_up.set_visible(false)
	if not GlobalVariables.is_host:
		self._start_button.queue_free()
		self._map_list.visible = false
	self._update_labels()

func _get_game_result():
	if GlobalVariables.winner_id == "":
		return "It's a draw!"
	if GlobalVariables.winner_id == GlobalVariables.player_id:
		return "You have won!"
	return "Player %s has won!" % GlobalVariables.get_player_color(GlobalVariables.winner_id)


func _on_start_game_button_pressed():
	if self._selected_map_idx < 0:
		return
	var start_message = DSGMessage.HostStartGameMessage.new(
		Utils.parse_map_to_dict(
			MapsDb.MAPS[self._selected_map_idx]["map_string"]
		)
	)
	DSGNetwork.send(start_message.to_dict())

func _on_ws_connected():
	DSGLogger.lobby_log("lobby entered successfully")
	self._pop_up.set_visible(false)

func _on_ws_received_message() -> void:
	while true:
		var msg: DSGMessage = DSGNetwork.pop_pending_message(MSG_FILTER)
		if msg == null:
			break
		if msg is DSGMessage.ServerStartGameMessage:
			self._server_start_game(msg)
		if msg is DSGMessage.ServerHelloMessage:
			self._server_hello(msg)
		if msg is DSGMessage.PlayerJoinedMessage:
			self._player_joined(msg)

func _on_ws_closed():
	DSGLogger.lobby_log("exiting lobby due to closed connection")
	get_tree().change_scene_to_file("res://scenes/start.tscn")

func _server_hello(hello_message: DSGMessage.ServerHelloMessage):
	hello_message.write_global_variables()
	self._amount_of_players = hello_message.get_amount_of_players()
	self._info.text = "Welcome! You play %s." % GlobalVariables.COLOR_MAPPING[GlobalVariables.player_number]
	self._setup_after_connection()

func _player_joined(_msg: DSGMessage.PlayerJoinedMessage):
	self._amount_of_players += 1
	self._update_labels()

func _server_start_game(msg: DSGMessage.ServerStartGameMessage):
	GlobalVariables.map = msg.get_map()
	for player in msg.get_players():
		GlobalVariables.players[player.get_id()] = player.get_number()
	GlobalVariables.pieces = msg.get_pieces()
	get_tree().change_scene_to_packed(self._board_scene)

func _update_labels():
	self._label_id_value.text = GlobalVariables.get_lobby_id_or_code()
	self._label_amount_of_players.text = str(self._amount_of_players)
	if GlobalVariables.is_host:
		self._start_button.set_visible(self._amount_of_players > 1)

func _display_maps():
	for map in MapsDb.MAPS:
		self._map_list.add_item(map["name"])

func _on_maps_list_item_clicked(index, _at_position, _mouse_button_index):
	self._selected_map_idx = index
