class_name BoardPlatformTile

var _position: Position
var _texture_id: String
var _tile_type: String

func _init(position: Position, texture_id: String, tile_type: String):
	self._position = position
	self._texture_id = texture_id
	self._tile_type = tile_type
	
func get_dict() -> Dictionary:
	return {
		"position": self._position.get_dict(),
		"texture_id": self._texture_id,
		"tile_type": self._tile_type
	}

