class_name BoardPlatform

var _tiles: Array[BoardPlatformTile]
	
func _init(tiles: Array[BoardPlatformTile]):
	self._tiles = tiles
	
func get_dict() -> Dictionary:
	var tiles_dict = []
	for tile in self._tiles:
		tiles_dict.append(tile.get_dict())
	return {
		"tiles": tiles_dict
	}

