extends HTTPRequest

@export var creat_lobby_url = "http://localhost:8000/lobby"
var lobby_scene = preload("res://scenes/lobby.tscn")
@onready var global_vars = get_node("/root/GlobalVariables")

func _ready():
	self.connect("request_completed", Callable(self, "_on_request_completed"))

func _on_creat_new_game_button_pressed():
	self.request(creat_lobby_url, [], false, HTTPClient.METHOD_POST)

func _on_request_completed(result, response_code, headers, body):
	var json = JSON.parse_string(body.get_string_from_utf8())
	GlobalVariables.id = json["lobby_id"]
	get_tree().change_scene_to_packed(lobby_scene)

