extends HTTPRequest

const UUID_LEN := 36
const SERVER_PROTOCOL: String = "https" if DSGNetwork.SERVER_USE_TLS else "http"

@export var game_id_path: NodePath

@onready var lobby_scene = preload("res://scenes/lobby.tscn")
@onready var global_vars = get_node("/root/GlobalVariables")
@onready var game_id_input = get_node(game_id_path)

func _ready():
	self.request_completed.connect(self._on_request_completed)

func _build_url(path: String) -> String:
	return "%s://%s%s" % [SERVER_PROTOCOL, DSGNetwork.SERVER_HOST, path]

func _on_create_new_game_button_pressed() -> void:
	var url := self._build_url("/lobby")
	var headers: PackedStringArray = [
		"Content-length: 0",
		"Content-Type: application/json",
	]
	self.request(url, headers, HTTPClient.METHOD_POST)

func _start_joining_lobby(lobby_id: String) -> void:
	GlobalVariables.lobby_id = lobby_id
	get_tree().change_scene_to_packed(lobby_scene)

func _on_request_completed(_result: int, _response_code: int, _headers: PackedStringArray, body: PackedByteArray):
	var response = JSON.parse_string(body.get_string_from_utf8())
	if "lobby_id" in response:
		self._start_joining_lobby(response["lobby_id"])

func _on_join_button_pressed():
	var game_id = game_id_input.text
	if len(game_id) == UUID_LEN:
		self._start_joining_lobby(game_id_input.text)


func _on_paste_button_pressed():
	self.game_id_input.text = DisplayServer.clipboard_get()
