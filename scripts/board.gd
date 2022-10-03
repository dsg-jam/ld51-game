extends Node2D

var board_grid: Array
var pieces: Dictionary
var tile_size: float
var tween: Tween

@onready var texture = $Texture
@onready var tile_prefab = preload("res://prefabs/tile.tscn")
@onready var piece_prefab = preload("res://prefabs/piece.tscn")

signal update_selected_piece

func _ready():
	"""
		input:
			'x': normal tile (habitable)
			'o': empty tile (void - player can fall down) - all board surrounding tiles are implicitly empty tiles
			';': line break
	"""
	var input = ";oooxxooo;ooxxxxoo;oxxxxxxo;oxxxxxxo;ooxxxxoo;oooxxooo;"
	board_grid = _get_board_grid(input)
	tile_size = _get_tile_size(board_grid)
	tween = get_tree().create_tween()
	_draw_board(board_grid, tile_size)
	place_piece("550e8400-e29b-11d4-a716-446655440000", "550e8400-e29b-0000-a716-446655440003", Vector2(3,1))
	place_piece("550e8400-e29b-11d4-a716-446655440001", "550e8400-e29b-0000-a716-446655440004", Vector2(4,6))
	animate({
		"type": "move",
		"payload": {
			"piece_id": "550e8400-e29b-11d4-a716-446655440000",
			"off_board": false,
			"new_position": {
				"x": 5,
				"y": 1
			}
		}
	})

func animate(outcome: Dictionary):
	if outcome["type"] == "move":
		var current_piece = get_piece_by_id(outcome["payload"]["piece_id"])
		var new_position = outcome["payload"]["new_position"]
		print(Vector2(new_position["x"] * tile_size, new_position["y"] * tile_size))
		print(Vector2(tile_size/2, tile_size/2))
		new_position = Vector2(tile_size/2, tile_size/2) + Vector2(new_position["x"] * tile_size, new_position["y"] * tile_size)
		print( current_piece.facing_direction)
		print(new_position.normalized())
		var direction = current_piece.facing_direction.angle_to(new_position-current_piece.position)
		#current_piece.rotate(direction)
		tween.tween_property(current_piece, "rotation", direction, 1)
		tween.tween_property(current_piece, "position", new_position, 1)


func place_piece(piece_id: String, player_id: String, piece_position: Vector2):
	var new_piece = piece_prefab.instantiate()
	var piece_scale = min(
		tile_size / new_piece.get_node("Texture").get_rect().size.x,
		tile_size / new_piece.get_node("Texture").get_rect().size.y
	)
	new_piece.scale.x = piece_scale
	new_piece.scale.y = piece_scale
	new_piece.setup(piece_id, player_id)
	new_piece.position = Vector2(tile_size/2, tile_size/2) + tile_size * piece_position
	new_piece.piece_selected.connect(_on_click)
	add_child(new_piece)
	pieces[piece_id] = new_piece
	

func get_piece_by_id(piece_id: String):
	return pieces[piece_id]

func _on_click(piece_id, piece_player_id):
	emit_signal("update_selected_piece", piece_id, piece_player_id)

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
	var board_grid = []
	for line in input.split(";"):
		var grid_line = []
		for character in line:
			grid_line.append(character)
		board_grid.append(grid_line)
	return board_grid

func _get_tile_size(board_grid: Array) -> int:
	var max_width = 0
	for line in board_grid:
		if line.size() > max_width:
			max_width = line.size()

	return min(floor(texture.polygon[2].x/max_width), floor(texture.polygon[2].y)/board_grid.size())
