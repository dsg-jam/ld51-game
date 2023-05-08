class_name LobbyNetworking
extends HTTPRequest

const UUID_LEN := 36
const SERVER_PROTOCOL: String = "https" if DSGNetwork.SERVER_USE_TLS else "http"

@onready var lobby_scene = preload("res://scenes/lobby.tscn")


func _ready():
	self.request_completed.connect(self._on_request_completed)


func _build_url(path: String) -> String:
	return "%s://%s%s" % [SERVER_PROTOCOL, DSGNetwork.SERVER_HOST, path]


func _on_request_completed(_result: int, _response_code: int, _headers: PackedStringArray, body: PackedByteArray):
	var response = JSON.parse_string(body.get_string_from_utf8())
	if "join_code" in response:
		GlobalVariables.join_code = response["join_code"]
	if "lobby_id" in response:
		self.join_lobby(response["lobby_id"])


func create_lobby():
	var url := self._build_url("/lobby")
	var headers: PackedStringArray = [
		"Content-length: 0",
		"Content-Type: application/json",
	]
	self.request(url, headers, HTTPClient.METHOD_POST)


func join_lobby(lobby_id_or_code: String):
	if len(lobby_id_or_code) < UUID_LEN:
		GlobalVariables.join_code = lobby_id_or_code.to_upper()
	else:
		GlobalVariables.lobby_id = lobby_id_or_code
	get_tree().change_scene_to_packed(lobby_scene)
