extends Node2D

signal update_selected_piece

const directions = {
	"up": Vector2.UP,
	"down": Vector2.DOWN,
	"left": Vector2.LEFT,
	"right": Vector2.RIGHT
}
const Piece = preload("res://scripts/piece.gd")

var pieces: Dictionary
var tile_size: float
var tween_move: Tween
var tween_move_back: Tween
var tween_rotate: Tween

@onready var texture = $Texture
@onready var tile_prefab = preload("res://prefabs/tile.tscn")
@onready var piece_prefab = preload("res://prefabs/piece.tscn")

func _ready():	
	tile_size = _get_tile_size()
	_draw_board()

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

func animate_events(events: Array):
	for event in events:
		tween_move = get_tree().create_tween().set_parallel()
		tween_move_back = get_tree().create_tween().set_parallel()
		tween_move.stop()
		tween_move_back.stop()
		tween_rotate = get_tree().create_tween().set_parallel()
		_animate_event(event["outcomes"])
		await tween_rotate.finished
		tween_move.play()
		await tween_move.finished
		tween_move_back.play()
		await tween_move_back.tween_interval(0.2).finished

func _animate_event(outcomes: Array):
	for outcome in outcomes:
		_animate(outcome)

func _animate_piece_rotation(piece: Piece, direction: Vector2, delay: float = 0.0, transition: int = Tween.TRANS_BACK):
	var angle = piece.facing_direction.angle_to(direction)
	tween_rotate.tween_property(piece, "rotation", angle, 1).set_trans(transition).set_delay(delay)

func _animate_piece_move(piece: Piece, direction: Vector2, delay: float = 0.0, transition: int = Tween.TRANS_CUBIC):
	var new_position = piece.position + direction * tile_size
	tween_move.tween_property(piece, "position", new_position, 1).set_trans(transition).set_delay(delay)


func _animate(outcome: Dictionary):
	if outcome["type"] == "push":
		var pusher_piece = _get_piece_by_id(outcome["payload"]["pusher_piece_id"])
		var victim_piece_ids = outcome["payload"]["victim_piece_ids"]
		var direction = directions[outcome["payload"]["direction"]]
		_animate_piece_rotation(pusher_piece, direction)
		_animate_piece_move(pusher_piece, direction)
		var i = 1
		for victim_piece_id in victim_piece_ids:
			var victim_piece = _get_piece_by_id(victim_piece_id)
			_animate_piece_rotation(victim_piece, direction)
			_animate_piece_move(victim_piece, direction, 0.125 * i)
			i += 1
	elif outcome["type"] == "move_conflict":
		var new_coordinates = Vector2(outcome["payload"]["collision_point"]["x"], outcome["payload"]["collision_point"]["y"])
		var moving_pieces = {}
		for moving_piece_id in outcome["payload"]["piece_ids"]:
			var current_piece = _get_piece_by_id(moving_piece_id)
			moving_pieces[current_piece] = current_piece.position
			var new_position = _get_position_on_grid(new_coordinates)
			var direction = (new_position-current_piece.position).normalized()
			_animate_piece_rotation(current_piece, direction)
			_animate_piece_move(current_piece, direction/2)
		for moving_piece in moving_pieces:
			tween_move_back.tween_property(moving_piece, "position", moving_pieces[moving_piece], 0.2).set_trans(Tween.TRANS_BOUNCE)
	elif outcome["type"] == "push_conflict":
		var piece_a = _get_piece_by_id(outcome["payload"]["piece_a"])
		var piece_b = _get_piece_by_id(outcome["payload"]["piece_b"])
		var initial_position_a = piece_a.position
		var initial_position_b = piece_b.position
		var direction_a = (piece_b.position - piece_a.position).normalized()
		var direction_b = (piece_a.position - piece_b.position).normalized()
		_animate_piece_rotation(piece_a, direction_a / 4)
		_animate_piece_rotation(piece_b, direction_b / 4)
		_animate_piece_move(piece_a, direction_a / 4, 0.0, Tween.TRANS_BACK)
		_animate_piece_move(piece_b, direction_b / 4, 0.0, Tween.TRANS_BACK)
		
		tween_move_back.tween_property(piece_a, "position", initial_position_a, 0.2).set_trans(Tween.TRANS_BOUNCE)
		tween_move_back.tween_property(piece_b, "position", initial_position_b, 0.2).set_trans(Tween.TRANS_BOUNCE)

func _get_position_on_grid(coordinates: Vector2):
	return Vector2(tile_size/2, tile_size/2) + coordinates * tile_size	

func _get_piece_by_id(piece_id: String):
	return pieces[piece_id]

func _on_click(piece_id, piece_player_id):
	emit_signal("update_selected_piece", piece_id, piece_player_id)

func _draw_board():
	for tile in GlobalVariables.map.get_tiles():
		# TODO: Set tile texture
		var tile_type = tile.get_tile_type()
		var position = Vector2(tile.get_position().get_x(), tile.get_position().get_y())
		if tile_type == "floor":
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
			new_tile.position = position * tile_size

func _get_tile_size() -> float:
	var max_width = 0
	for tile in GlobalVariables.map.get_tiles():
		var position = tile.get_position()
		if position.get_x() > max_width:
			max_width = position.get_x()
		if position.get_y() > max_width:
			max_width = position.get_y()
	max_width += 1
	return min(floor(texture.polygon[2].x/max_width), floor(texture.polygon[2].y)/max_width)
