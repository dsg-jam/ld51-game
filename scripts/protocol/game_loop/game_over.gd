class_name GameOver

var _winner_player_id: String

func _init(winner_player_id: String):
	self._winner_player_id = winner_player_id


func to_dict() -> Dictionary:
	return {
		"winner_player_id": self._winner_player_id,
	}


static func from_dict(payload: Dictionary) -> GameOver:
	var winner_player_id = payload.get("winner_player_id", "")
	if winner_player_id == null:
		winner_player_id = ""
	return GameOver.new(winner_player_id)
