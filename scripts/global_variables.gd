extends Node

const PLAYER_ASSET_PATH = "res://assets/player/Player_%s.png"

const COLOR_MAPPING = {
	1: "Blue",
	2: "Green",
	3: "Purple",
	4: "Red",
	5: "Base"
}

var lobby_id: String = "0"
var join_code: String = ""
var player_id: String = ""
var session_id: String = ""
var winner_id: String = ""
var player_number: int = 0
var is_host: bool = true
var map: BoardPlatform = null
var players: Dictionary = {}
var pieces: Array[PlayerPiecePosition] = []

func get_piece_image(piece_player_number: int) -> ImageTexture:
	return load(PLAYER_ASSET_PATH % COLOR_MAPPING[piece_player_number])

func get_player_color(current_player_id: String) -> String:
	return COLOR_MAPPING[players[current_player_id]]

func get_lobby_id_or_code() -> String:
	if len(self.join_code) > 0:
		return self.join_code
	return self.lobby_id
