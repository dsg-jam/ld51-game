class_name BoardPlatformTile

var _position: Position
var _texture_id: String
var _tile_type: String

func _init(position: Position, texture_id: String, tile_type: String):
	self._position = position
	self._texture_id = texture_id
	self._tile_type = tile_type
	
func get_position() -> Position:
	return self._position
	
func get_texture_id() -> String:
	return self._texture_id
	
func get_tile_type() -> String:
	return self._tile_type

func get_dict() -> Dictionary:
	return {
		"position": self._position.get_dict(),
		"texture_id": self._texture_id,
		"tile_type": self._tile_type
	}

static func get_obj_from_dict(data: Dictionary) -> BoardPlatformTile:
	assert("position" in data)
	assert("texture_id" in data)
	assert("tile_type" in data)
	var position = Position.get_obj_from_dict(data["position"])
	return BoardPlatformTile.new(
		position,
		data["texture_id"],
		data["tile_type"]
	)
