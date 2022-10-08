class_name BoardPlatform

var _tiles: Array[BoardPlatformTile]
	
func _init(tiles: Array[BoardPlatformTile]):
	self._tiles = tiles

func get_tiles() -> Array[BoardPlatformTile]:
	return self._tiles

func get_dict() -> Dictionary:
	var tiles_dict = []
	for tile in self._tiles:
		tiles_dict.append(tile.get_dict())
	return {
		"tiles": tiles_dict
	}

static func get_obj_from_dict(data: Dictionary) -> BoardPlatform:
	assert("tiles" in data)
	var tiles: Array[BoardPlatformTile] = []
	for tile in data["tiles"]:
		tiles.append(BoardPlatformTile.get_obj_from_dict(tile))
	return BoardPlatform.new(tiles)
