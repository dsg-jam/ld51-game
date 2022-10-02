extends Node2D

@onready var texture = $Texture
@onready var tile_prefab = preload("res://prefabs/tile.tscn")

func _ready():
	render_board("oo;;o;xxxxxx;xxxoxx;ooooo;;oooxxxx;xx;ooox;xxo;oxxxxx;;;o;o")

func render_board(input: String):
	"""
		input:
			'x': normal tile (habitable)
			'o': empty tile (void - player can fall down) - all board surrounding tiles are implicitly empty tiles
			';': line break
	"""
	var board_grid = get_board_grid(input)	
	var tile_size = get_tile_size(board_grid)
	draw_board(board_grid, tile_size)

func _process(delta):
	pass

func draw_board(board_grid: Array, tile_size: int):
	for row in board_grid.size():
		for col in board_grid[row].size():
			match board_grid[row][col]:
				"x":
					var new_tile = tile_prefab.instantiate()
					new_tile.get_node("Texture").set_polygon(
						[
							Vector2(0, 0),
							Vector2(tile_size, 0),
							Vector2(tile_size, tile_size),
							Vector2(0, tile_size)
						]
					)
					add_child(new_tile)
					new_tile.position = Vector2(col, row) * tile_size
				"o":
					pass

func get_board_grid(input: String) -> Array:
	input = clean_up_input(input)
	var board_grid = []
	for line in input.split(";"):
		var grid_line = []
		for character in line:
			grid_line.append(character)
		board_grid.append(grid_line)
	return board_grid
	

func clean_up_input(input: String) -> String:
	var regex_line_end = RegEx.new()
	regex_line_end.compile("(o*(;|$))")
	
	var regex_top_down = RegEx.new()
	regex_top_down.compile("(^;*)|(;*$)")
	
	input = regex_line_end.sub(input, ";", true)
	input = regex_top_down.sub(input, "", true)
	
	return input

func get_tile_size(board_grid: Array) -> int:
	var max_width = 0
	for line in board_grid:
		if line.size() > max_width:
			max_width = line.size()

	return min(floor(texture.polygon[2].x/max_width), floor(texture.polygon[2].y)/board_grid.size())
