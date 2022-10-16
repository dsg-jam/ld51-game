extends Node

const PLAYER_ASSET_PATH = "res://assets/player/Player_%s.png"

const COLOR_MAPPING = {
	1: "Blue",
	2: "Green",
	3: "Purple",
	4: "Red",
	5: "Base"
}

var id: String = "0"
var player_id: String = ""
var player_number: int = 0
var session_id: String = ""
var is_host: bool = true
var map: BoardPlatform = null
var players: Dictionary = {}
var pieces: Array = []
var winner_id: String = ""

func get_piece_image(piece_player_number: int) -> ImageTexture:
	return load(PLAYER_ASSET_PATH % COLOR_MAPPING[piece_player_number])

func get_player_color(player_id: String) -> String:
	return COLOR_MAPPING[players[player_id]]
