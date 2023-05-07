class_name PlayerMove

var _piece_id: String
var _action: String


func _init(piece_id: String, action: String):
	self._piece_id = piece_id
	self._action = action


func to_dict() -> Dictionary:
	return {
		"piece_id": self._piece_id,
		"action": self._action,
	}


static func _is_valid(payload: Dictionary) -> bool:
	if "piece_id" not in payload:
		return false
	if "action" not in payload:
		return false
	return true


static func from_dict(payload: Dictionary) -> PlayerMove:
	if not _is_valid(payload): return null
	var piece_id = payload.get("piece_id")
	var action = payload.get("action")
	return PlayerMove.new(piece_id, action)
