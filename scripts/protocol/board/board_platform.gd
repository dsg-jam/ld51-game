class_name BoardPlatform

var _tiles: Array[BoardPlatformTile]
	
func _init(tiles: Array[BoardPlatformTile]):
	self._tiles = tiles

func get_tiles() -> Array[BoardPlatformTile]:
	return self._tiles

func to_dict() -> Dictionary:
	var tiles_dict = []
	for tile in self._tiles:
		tiles_dict.append(tile.to_dict())
	return {
		"tiles": tiles_dict
	}

static func _is_valid(payload: Dictionary) -> bool:
	if not "tiles" in payload:
		return false
	return true

static func from_dict(payload: Dictionary) -> BoardPlatform:
	if not _is_valid(payload): return null
	var tiles: Array[BoardPlatformTile] = []
	for tile in payload.get("tiles"):
		tiles.append(BoardPlatformTile.from_dict(tile))
	return BoardPlatform.new(tiles)
