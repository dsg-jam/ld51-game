class_name PlayerPiecePosition

var _player_id: String
var _piece_id: String
var _position: BoardPosition


func _init(player_id: String, piece_id: String, position: BoardPosition):
	self._player_id = player_id
	self._piece_id = piece_id
	self._position = position


func to_dict() -> Dictionary:
	return {
		"player_id": self._piece_id,
		"piece_id": self._piece_id,
		"position": self._position,
	}


static func _is_valid(payload: Dictionary) -> bool:
	if "player_id" not in payload:
		return false
	if "piece_id" not in payload:
		return false
	if "position" not in payload:
		return false
	return true


static func from_dict(payload: Dictionary) -> PlayerPiecePosition:
	if not _is_valid(payload): return null
	var player_id = payload.get("player_id")
	var piece_id = payload.get("piece_id")
	var position = BoardPosition.from_dict(payload.get("position"))
	return PlayerPiecePosition.new(player_id, piece_id, position)
