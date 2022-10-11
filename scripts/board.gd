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

@export var ROTATION_ANIMATION_DURATION: float = 1.0
@export var MOVE_ANIMATION_DURATION: float = 1.0
@export var MOVE_BACK_ANIMATION_DURATION: float = 0.2

@onready var texture = $Texture
@onready var tile_prefab = preload("res://prefabs/tile.tscn")
@onready var piece_prefab = preload("res://prefabs/piece.tscn")

func _ready():	
	tile_size = _get_tile_size()
	_draw_board()

func get_piece_by_id(piece_id: String) -> Piece:
	return pieces[piece_id]

func turn_all_player_piece_lights_on(intensity: float):
	for piece in pieces.values():
		piece.turn_light_on(intensity)

func turn_all_piece_lights_off():
	for piece in pieces.values():
		piece.turn_light_off()

func place_piece(piece_id: String, player_id: String, piece_position: Vector2):
	if piece_id in self.pieces:
		self.pieces[piece_id].position = self._get_position_on_grid(piece_position)
		return
	var new_piece = piece_prefab.instantiate()
	var piece_scale = min(
		tile_size / new_piece.get_node("Texture").get_rect().size.x,
		tile_size / new_piece.get_node("Texture").get_rect().size.y
	)
	new_piece.scale.x = piece_scale
	new_piece.scale.y = piece_scale
	new_piece.setup(piece_id, player_id)
	new_piece.position = self._get_position_on_grid(piece_position)
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
		await tween_rotate.tween_interval(ROTATION_ANIMATION_DURATION).finished
		if tween_move.is_valid():
			tween_move.play()
			await tween_move.tween_interval(MOVE_ANIMATION_DURATION).finished
		if tween_move_back.is_valid():
			tween_move_back.play()
			await tween_move_back.tween_interval(MOVE_BACK_ANIMATION_DURATION).finished

func _animate_event(outcomes: Array):
	for outcome in outcomes:
		_animate(outcome)

func _animate_piece_rotation(piece: Piece, direction: Vector2, delay: float = 0.0, transition: int = Tween.TRANS_BACK):
	var angle = piece.facing_direction.angle_to(direction)
	tween_rotate.tween_property(piece, "rotation", angle, ROTATION_ANIMATION_DURATION).set_trans(transition).set_delay(delay)

func _animate_piece_move(piece: Piece, direction: Vector2, delay: float = 0.0, transition: int = Tween.TRANS_CUBIC):
	var new_position = piece.position + direction * tile_size
	tween_move.tween_property(piece, "position", new_position, MOVE_ANIMATION_DURATION).set_trans(transition).set_delay(delay)


func _animate(outcome: Dictionary):
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
			tween_move_back.tween_property(moving_piece, "position", moving_pieces[moving_piece], MOVE_BACK_ANIMATION_DURATION).set_trans(Tween.TRANS_BOUNCE)
	elif outcome["type"] == "push_conflict":
		var piece_ids = outcome["payload"]["piece_ids"]
		for piece_id in piece_ids:
			var piece = self._get_piece_by_id(piece_id)
			tween_rotate.tween_property(piece, "rotation", 2*PI, 1).set_trans(Tween.TRANS_BACK)

func _get_position_on_grid(coordinates: Vector2):
	return Vector2(tile_size/2, tile_size/2) + coordinates * tile_size	

func _on_click(piece_id, piece_player_id):
	emit_signal("update_selected_piece", piece_id, piece_player_id)

func _draw_board():
	for tile in GlobalVariables.map.get_tiles():
		# TODO: Set tile texture
		var tile_type = tile.get_tile_type()
		var tile_position = Vector2(tile.get_position().get_x(), tile.get_position().get_y())
		if tile_type == "floor":
			var new_tile = tile_prefab.instantiate()
			new_tile.get_node("Texture").apply_scale(Vector2(tile_size / new_tile.get_node("Texture").texture.get_width(), tile_size / new_tile.get_node("Texture").texture.get_height()))
			add_child(new_tile)
			new_tile.position = tile_position * tile_size

func _get_tile_size() -> float:
	var max_width = 0
	for tile in GlobalVariables.map.get_tiles():
		var tile_position = tile.get_position()
		if tile_position.get_x() > max_width:
			max_width = tile_position.get_x()
		if tile_position.get_y() > max_width:
			max_width = tile_position.get_y()
	max_width += 1
	return min(floor(texture.polygon[2].x/max_width), floor(texture.polygon[2].y)/max_width)
