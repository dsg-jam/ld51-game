extends HTTPRequest

@export var lobby_url = "http://localhost:8000/lobby"
@export var game_id_path: NodePath

@onready var lobby_scene = preload("res://scenes/lobby.tscn")
@onready var global_vars = get_node("/root/GlobalVariables")
@onready var game_id_input = get_node(game_id_path)

func _ready():
	self.connect("request_completed", Callable(self, "_on_request_completed"))

func _on_creat_new_game_button_pressed():
	self.request(lobby_url, [], false, HTTPClient.METHOD_POST)

func _on_request_completed(_result, _response_code, _headers, body):
	var response = JSON.parse_string(body.get_string_from_utf8())
	print(response)
	if "lobby_id" in response:
		GlobalVariables.id = response["lobby_id"]
		get_tree().change_scene_to_packed(lobby_scene)

func _on_join_button_pressed():
	# TODO: Further check game id before sending a (unnecessary) request
	var game_id = game_id_input.text
	if len(game_id) == 36:
		self.request(lobby_url + "/" + game_id_input.text)
