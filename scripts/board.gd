extends Node2D

var board_grid: Array

@onready var texture = $Texture
@onready var tile_prefab = preload("res://prefabs/tile.tscn")
@onready var piece_prefab = preload("res://prefabs/piece.tscn")

signal update_selected_piece

func _ready():
	render_board("oo;;o;xxxxxx;xxxoxx;ooooo;;oooxxxx;xx;ooox;xxo;oxxxxx;;;o;o")
	var tile_size = _get_tile_size(board_grid)
	place_piece("550e8400-e29b-11d4-a716-446655440000", Vector2(0,0))
	place_piece("550e8400-e29b-11d4-a716-446655440001", Vector2(6,4))
	

func place_piece(piece_id: String, piece_position: Vector2):
	var tile_size = _get_tile_size(board_grid)
	var new_piece = piece_prefab.instantiate()
	var piece_scale = min(
		tile_size / new_piece.get_node("Texture").get_rect().size.x,
		tile_size / new_piece.get_node("Texture").get_rect().size.y
	)
	new_piece.scale.x = piece_scale
	new_piece.scale.y = piece_scale
	new_piece.set_piece_id(piece_id)
	new_piece.position = Vector2(tile_size/2, tile_size/2) + tile_size * piece_position
	
	print(new_piece.get_node("Texture").get_rect())
	new_piece.piece_selected.connect(_on_click)
	add_child(new_piece)
	

func render_board(input: String):
	"""
		input:
			'x': normal tile (habitable)
			'o': empty tile (void - player can fall down) - all board surrounding tiles are implicitly empty tiles
			';': line break
	"""
	board_grid = _get_board_grid(input)	
	var tile_size = _get_tile_size(board_grid)
	_draw_board(board_grid, tile_size)

func _on_click(piece_id):
	emit_signal("update_selected_piece", piece_id)

func _process(delta):
	pass

func _draw_board(board_grid: Array, tile_size: int):
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

func _get_board_grid(input: String) -> Array:
	input = _clean_up_input(input)
	var board_grid = []
	for line in input.split(";"):
		var grid_line = []
		for character in line:
			grid_line.append(character)
		board_grid.append(grid_line)
	return board_grid
	

func _clean_up_input(input: String) -> String:
	var regex_line_end = RegEx.new()
	regex_line_end.compile("(o*(;|$))")
	
	var regex_top_down = RegEx.new()
	regex_top_down.compile("(^;*)|(;*$)")
	
	input = regex_line_end.sub(input, ";", true)
	input = regex_top_down.sub(input, "", true)
	
	return input

func _get_tile_size(board_grid: Array) -> int:
	var max_width = 0
	for line in board_grid:
		if line.size() > max_width:
			max_width = line.size()

	return min(floor(texture.polygon[2].x/max_width), floor(texture.polygon[2].y)/board_grid.size())
