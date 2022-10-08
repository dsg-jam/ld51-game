class_name Utils

static func parse_map_to_dict(map: String) -> Dictionary:
	var grid = map.split(";")
	var tiles: Array[BoardPlatformTile]
	for row in grid.size():
		for col in grid[row].length():
			var tile_char = grid[row][col]
			var position = Position.new(col, row)
			var tile_type = "floor" if tile_char == "x" else "void"
			var tile_texture = "grass"
			tiles.append(BoardPlatformTile.new(position, tile_texture, tile_type))
	var platform = BoardPlatform.new(tiles)
	return platform.get_dict()

func parse_dict_to_map():
	# TODO
	pass
