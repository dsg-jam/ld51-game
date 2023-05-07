class_name BoardPlatformTile

var _position: BoardPosition
var _texture_id: String
var _tile_type: String

func _init(position: BoardPosition, texture_id: String, tile_type: String):
	self._position = position
	self._texture_id = texture_id
	self._tile_type = tile_type
	
func get_position() -> BoardPosition:
	return self._position
	
func get_texture_id() -> String:
	return self._texture_id
	
func get_tile_type() -> String:
	return self._tile_type

func to_dict() -> Dictionary:
	return {
		"position": self._position.to_dict(),
		"texture_id": self._texture_id,
		"tile_type": self._tile_type
	}

static func _is_valid(payload: Dictionary) -> bool:
	if not "position" in payload:
		return false
	if not "texture_id" in payload:
		return false
	if not "tile_type" in payload:
		return false
	return true

static func from_dict(payload: Dictionary) -> BoardPlatformTile:
	if not _is_valid(payload): return null
	var position = BoardPosition.from_dict(payload.get("position"))
	return BoardPlatformTile.new(
		position,
		payload.get("texture_id"),
		payload.get("tile_type")
	)
