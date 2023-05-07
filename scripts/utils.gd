class_name Utils

const direction_to_vec = {
	"up": Vector2.UP,
	"down": Vector2.DOWN,
	"left": Vector2.LEFT,
	"right": Vector2.RIGHT
}

static func parse_map_to_dict(map: String) -> BoardPlatform:
	var grid = map.split(";")
	var tiles: Array[BoardPlatformTile] = []
	for row in grid.size():
		for col in grid[row].length():
			var tile_char = grid[row][col]
			var position = BoardPosition.new(col, row)
			var tile_type = "floor" if tile_char == "x" else "void"
			var tile_texture = "grass"
			tiles.append(BoardPlatformTile.new(position, tile_texture, tile_type))
	var platform = BoardPlatform.new(tiles)
	return platform


static func parse_dict_to_map(data: Dictionary) -> BoardPlatform:
	assert("platform" in data, "Platform is missing in server_start_game message")
	return BoardPlatform.get_obj_from_dict(data["platform"])


static func is_mobile_device() -> bool:
	if OS.has_feature("web"):
		if JavaScriptBridge.eval("/Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent)") == 1:
			return true
	return false
