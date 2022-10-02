extends Node2D


const MAX_BOARD_DIMENSIONS = Vector2(1,1)

@onready var texture = $Texture
@onready var tile_prefab = preload("res://prefabs/tile.tscn")

func _ready():
	render_board("oo;;o;xxxxxx;xxxoxx;ooooo;oooxxxx;xx;ooox;xxo;oxxxxx;;;o;")


func render_board(input: String):
	"""
		input:
			'x': normal tile (habitable)
			'o': empty tile (void - player can fall down) - all board surrounding tiles are implicitly empty tiles
			';': line break
	"""
	
	var regex_line_end = RegEx.new()
	regex_line_end.compile("(o*;)")
	
	var regex_top_down = RegEx.new()
	regex_top_down.compile("(^;*)|(;*$)")
	
	input = regex_line_end.sub(input, ";", true)
	input = regex_top_down.sub(input, "", true)
	
	var board_grid = input.split(";")
	
	var max_width = 0
	for line in board_grid:
		if len(line) > max_width:
			max_width = len(line)

	var tile_size = min(floor(texture.polygon[2].x/max_width), floor(texture.polygon[2].y)/board_grid.size())
	
	print(tile_size)
	
	for i in board_grid.size():
		for j in len(board_grid[i]):
			match board_grid[i][j]:
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
					new_tile.position = Vector2(j, i) * tile_size
					
				"o":
					pass

func _process(delta):
	pass
