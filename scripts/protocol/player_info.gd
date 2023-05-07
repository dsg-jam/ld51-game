class_name PlayerInfo

var _id: String
var _number: int
	
func _init(id: String, number: int):
	self._id = id
	self._number = number


func to_dict() -> Dictionary:
	return {
		"id": self._id,
		"number": self._number,
	}
	
static func _is_valid(payload: Dictionary) -> bool:
	if "id" not in payload:
		return false
	if "number" not in payload:
		return false
	return true

static func from_dict(payload: Dictionary) -> PlayerInfo:
	if not _is_valid(payload): return null
	var id = payload.get("id")
	var number = payload.get("number")
	return PlayerInfo.new(id, number)
