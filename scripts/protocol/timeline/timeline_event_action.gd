class_name TimelineEventAction

var _player_id: String
var _piece_id: String
var _action: String

func _init(player_id: String, piece_id: String, action: String):
	self._player_id = player_id
	self._piece_id = piece_id
	self._action = action


func to_dict() -> Dictionary:
	return {
		"player_id": self._player_id,
		"piece_id": self._piece_id,
		"action": self._action,
	}
	
static func _is_valid(payload: Dictionary) -> bool:
	if "player_id" not in payload:
		return false
	if "piece_id" not in payload:
		return false
	if "action" not in payload:
		return false
	return true

static func from_dict(payload: Dictionary) -> TimelineEventAction:
	if not _is_valid(payload): return null
	var player_id = payload.get("player_id")
	var piece_id = payload.get("piece_id")
	var action = payload.get("action")
	return TimelineEventAction.new(player_id, piece_id, action)
