extends Node2D

var board_grid: Array
var pieces: Dictionary
var tile_size: float

var tween_move: Tween
var tween_move_back: Tween
var tween_rotate: Tween

const directions = {
	"up": Vector2.UP,
	"down": Vector2.DOWN,
	"left": Vector2.LEFT,
	"right": Vector2.RIGHT
}

const Piece = preload("res://scripts/piece.gd")

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
	_draw_board(board_grid, tile_size)
	
	############## SAMPLE - BEGIN
	place_piece("550e8400-e29b-11d4-a716-446655440000", "550e8400-e29b-0000-a716-446655440003", Vector2(3,1))
	place_piece("550e8400-e29b-11d4-a716-446655440001", "550e8400-e29b-0000-a716-446655440004", Vector2(3,2))
	place_piece("550e8400-e29b-11d4-a716-446655440002", "550e8400-e29b-0000-a716-446655440004", Vector2(3,3))
	place_piece("550e8400-e29b-11d4-a716-446655440003", "550e8400-e29b-0000-a716-446655440004", Vector2(6,2))
	place_piece("550e8400-e29b-11d4-a716-446655440004", "550e8400-e29b-0000-a716-446655440004", Vector2(6,3))
	place_piece("550e8400-e29b-11d4-a716-446655440005", "550e8400-e29b-0000-a716-446655440004", Vector2(4,4))
	
	var events = [
		{
			"outcomes": [
				{
					"type": "push",
					"payload": {
						"pusher_piece_id": "550e8400-e29b-11d4-a716-446655440000",
						"victim_piece_ids": [
							"550e8400-e29b-11d4-a716-446655440001",
							"550e8400-e29b-11d4-a716-446655440002"
						],
						"direction": "down"
					}
				},
				{
					"type": "push",
					"payload": {
						"pusher_piece_id": "550e8400-e29b-11d4-a716-446655440003",
						"victim_piece_ids": [],
						"direction": "left"
					}
				},
				{
					"type": "push",
					"payload": {
						"pusher_piece_id": "550e8400-e29b-11d4-a716-446655440004",
						"victim_piece_ids": [],
						"direction": "left"
					}
				}
			]
		},
		{
			"outcomes": [
				{
					"type": "move_conflict",
					"payload": {
						"piece_ids": ["550e8400-e29b-11d4-a716-446655440000", "550e8400-e29b-11d4-a716-446655440003"],
						"collision_point": {
							"x": 4,
							"y": 2
						}
					}
				},
				{
					"type": "move_conflict",
					"payload": {
						"piece_ids": ["550e8400-e29b-11d4-a716-446655440001", "550e8400-e29b-11d4-a716-446655440004"],
						"collision_point": {
							"x": 4,
							"y": 3
						}
					}
				},
				{
					"type": "push_conflict",
					"payload": {
						"piece_a": "550e8400-e29b-11d4-a716-446655440002",
						"piece_b": "550e8400-e29b-11d4-a716-446655440005"
					}
				}
			]
		}
	]
	
	animate_events(events)
	############## SAMPLE - END

func animate_events(events: Array):
	for event in events:
		tween_move = get_tree().create_tween().set_parallel()
		tween_move_back = get_tree().create_tween().set_parallel()
		tween_move.stop()
		tween_move_back.stop()
		tween_rotate = get_tree().create_tween().set_parallel()
		animate_event(event["outcomes"])
		await tween_rotate.finished
		tween_move.play()
		await tween_move.finished
		tween_move_back.play()
		# TODO: tween_interval(0.0) might result in an unexpected behavior!
		await tween_move_back.tween_interval(0.0).finished

func animate_event(outcomes: Array):
	for outcome in outcomes:
		animate(outcome)

func _animate_piece_rotation(piece: Piece, direction: Vector2, delay: float = 0.0, transition: int = Tween.TRANS_BACK, ease: int = 0):
	var angle = piece.facing_direction.angle_to(direction)
	tween_rotate.tween_property(piece, "rotation", angle, 1).set_trans(transition).set_delay(delay)

func _animate_piece_move(piece: Piece, direction: Vector2, delay: float = 0.0, transition: int = Tween.TRANS_CUBIC, ease: int = 0):
	var new_position = piece.position + direction * tile_size
	tween_move.tween_property(piece, "position", new_position, 1).set_trans(transition).set_delay(delay)


func animate(outcome: Dictionary):
	if outcome["type"] == "push":
		var pusher_piece = get_piece_by_id(outcome["payload"]["pusher_piece_id"])
		var victim_piece_ids = outcome["payload"]["victim_piece_ids"]
		var direction = directions[outcome["payload"]["direction"]]
		_animate_piece_rotation(pusher_piece, direction)
		_animate_piece_move(pusher_piece, direction)
		var i = 1
		for victim_piece_id in victim_piece_ids:
			var victim_piece = get_piece_by_id(victim_piece_id)
			_animate_piece_rotation(victim_piece, direction)
			_animate_piece_move(victim_piece, direction, 0.125 * i)
			i += 1
	elif outcome["type"] == "move_conflict":
		var new_coordinates = Vector2(outcome["payload"]["collision_point"]["x"], outcome["payload"]["collision_point"]["y"])
		var moving_pieces = {}
		for moving_piece_id in outcome["payload"]["piece_ids"]:
			var current_piece = get_piece_by_id(moving_piece_id)
			moving_pieces[current_piece] = current_piece.position
			var new_position = _get_position_on_grid(new_coordinates)
			var direction = (new_position-current_piece.position).normalized()
			_animate_piece_rotation(current_piece, direction)
			_animate_piece_move(current_piece, direction/2)
		for moving_piece in moving_pieces:
			tween_move_back.tween_property(moving_piece, "position", moving_pieces[moving_piece], 0.2).set_trans(Tween.TRANS_BOUNCE)
	elif outcome["type"] == "push_conflict":
		var piece_a = get_piece_by_id(outcome["payload"]["piece_a"])
		var piece_b = get_piece_by_id(outcome["payload"]["piece_b"])
		var initial_position_a = piece_a.position
		var initial_position_b = piece_b.position
		var direction_a = (piece_b.position - piece_a.position).normalized()
		var direction_b = (piece_a.position - piece_b.position).normalized()
		_animate_piece_rotation(piece_a, direction_a / 4)
		_animate_piece_rotation(piece_b, direction_b / 4)
		_animate_piece_move(piece_a, direction_a / 4, 0.0, Tween.TRANS_BACK, Tween.EASE_IN_OUT)
		_animate_piece_move(piece_b, direction_b / 4, 0.0, Tween.TRANS_BACK, Tween.EASE_IN_OUT)
		
		tween_move_back.tween_property(piece_a, "position", initial_position_a, 0.2).set_trans(Tween.TRANS_BOUNCE)
		tween_move_back.tween_property(piece_b, "position", initial_position_b, 0.2).set_trans(Tween.TRANS_BOUNCE)

func _get_position_on_grid(coordinates: Vector2):
	return Vector2(tile_size/2, tile_size/2) + coordinates * tile_size

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
