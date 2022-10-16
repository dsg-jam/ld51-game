extends Node2D

signal update_selected_piece

const directions = {
	"up": Vector2.UP,
	"down": Vector2.DOWN,
	"left": Vector2.LEFT,
	"right": Vector2.RIGHT
}

const Piece = preload("res://scripts/piece.gd")

var _pieces: Dictionary
var _floor_coordinates: Array[Vector2]
var _tile_size: float
var _tween_move: Tween
var _tween_move_back: Tween
var _tween_rotate: Tween

@export var ROTATION_ANIMATION_DURATION: float = 1.0
@export var MOVE_ANIMATION_DURATION: float = 1.0
@export var MOVE_BACK_ANIMATION_DURATION: float = 0.2

@onready var texture = $Texture
@onready var tile_prefab = preload("res://prefabs/tile.tscn")
@onready var piece_prefab = preload("res://prefabs/piece.tscn")

func _ready():	
	self._tile_size = self._get_tile_size()
	self._draw_board()

func get_piece_by_id(piece_id: String) -> Piece:
	return self._pieces.get(piece_id)

func get_sorted_player_pieces() -> Array[String]:
	var piece_ids = self._pieces.keys().filter(self._filter_player_pieces)
	piece_ids.sort_custom(self._sort_by_position)
	return piece_ids

func _filter_player_pieces(piece_id: String) -> bool:
	var piece = self.get_piece_by_id(piece_id)
	return piece.is_player_owning()

func _sort_by_position(piece_id_a: String, piece_id_b: String) -> bool:
	var piece_a = self.get_piece_by_id(piece_id_a)
	var piece_b = self.get_piece_by_id(piece_id_b)
	if piece_a.position.y < piece_b.position.y:
		return true
	if piece_a.position.y == piece_b.position.y && piece_a.position.x < piece_b.position.x:
		return true
	return false

func turn_all_player_piece_lights_on(intensity: float):
	for piece in self._pieces.values():
		if piece.is_player_owning():
			piece.turn_light_on(intensity)

func turn_all_piece_lights_off():
	for piece in self._pieces.values():
		piece.turn_light_off()

func place_piece(piece_id: String, player_id: String, piece_position: Vector2):
	if piece_id in self._pieces:
		self.get_piece_by_id(piece_id).position = self._get_position_on_grid(piece_position)
		return
	var new_piece = piece_prefab.instantiate()
	new_piece.set_texture(GlobalVariables.players[player_id])
	var piece_scale = min(
		self._tile_size / new_piece.get_node("Texture").get_rect().size.x,
		self._tile_size / new_piece.get_node("Texture").get_rect().size.y
	)
	new_piece.scale.x = piece_scale
	new_piece.scale.y = piece_scale
	new_piece.setup(piece_id, player_id)
	new_piece.position = self._get_position_on_grid(piece_position)
	new_piece.piece_selected.connect(_on_click)
	add_child(new_piece)
	self._pieces[piece_id] = new_piece

func animate_events(events: Array):
	for event in events:
		self._tween_move = get_tree().create_tween().set_parallel()
		self._tween_move_back = get_tree().create_tween().set_parallel()
		self._tween_move.stop()
		self._tween_move_back.stop()
		self._tween_rotate = get_tree().create_tween().set_parallel()
		self._animate_event(event["outcomes"])
		await self._tween_rotate.tween_interval(ROTATION_ANIMATION_DURATION).finished
		if self._tween_move.is_valid():
			self._tween_move.play()
			await self._tween_move.tween_interval(MOVE_ANIMATION_DURATION).finished
		if self._tween_move_back.is_valid():
			self._tween_move_back.play()
			await self._tween_move_back.tween_interval(MOVE_BACK_ANIMATION_DURATION).finished
		self._handle_falling_pieces()

func _animate_event(outcomes: Array):
	for outcome in outcomes:
		self._animate(outcome)

func _animate_piece_rotation(piece: Piece, direction: Vector2, delay: float = 0.0, transition: int = Tween.TRANS_BACK):
	var angle = piece.facing_direction.angle_to(direction)
	self._tween_rotate.tween_property(piece, "rotation", angle, ROTATION_ANIMATION_DURATION).set_trans(transition).set_delay(delay)

func _animate_piece_move(piece: Piece, direction: Vector2, delay: float = 0.0, transition: int = Tween.TRANS_CUBIC):
	var new_position = piece.position + direction * self._tile_size
	self._tween_move.tween_property(piece, "position", new_position, MOVE_ANIMATION_DURATION).set_trans(transition).set_delay(delay)

func _animate(outcome: Dictionary):
	if outcome["type"] == "push":
		var pusher_piece = self.get_piece_by_id(outcome["payload"]["pusher_piece_id"])
		var victim_piece_ids = outcome["payload"]["victim_piece_ids"]
		var direction = directions[outcome["payload"]["direction"]]
		self._animate_piece_rotation(pusher_piece, direction)
		self._animate_piece_move(pusher_piece, direction)
		var i = 1
		for victim_piece_id in victim_piece_ids:
			var victim_piece = self.get_piece_by_id(victim_piece_id)
			self._animate_piece_rotation(victim_piece, direction)
			self._animate_piece_move(victim_piece, direction, 0.125 * i)
			i += 1
	elif outcome["type"] == "move_conflict":
		var new_coordinates = Vector2(outcome["payload"]["collision_point"]["x"], outcome["payload"]["collision_point"]["y"])
		var moving_pieces = {}
		for moving_piece_id in outcome["payload"]["piece_ids"]:
			var current_piece = self.get_piece_by_id(moving_piece_id)
			moving_pieces[current_piece] = current_piece.position
			var new_position = self._get_position_on_grid(new_coordinates)
			var direction = (new_position-current_piece.position).normalized()
			self._animate_piece_rotation(current_piece, direction)
			self._animate_piece_move(current_piece, direction/2)
		for moving_piece in moving_pieces:
			self._tween_move_back.tween_property(moving_piece, "position", moving_pieces[moving_piece], MOVE_BACK_ANIMATION_DURATION).set_trans(Tween.TRANS_BOUNCE)
	elif outcome["type"] == "push_conflict":
		var piece_ids = outcome["payload"]["piece_ids"]
		for piece_id in piece_ids:
			var piece = self.get_piece_by_id(piece_id)
			self._tween_rotate.tween_property(piece, "rotation", 2*PI, 1).set_trans(Tween.TRANS_BACK)

func _handle_falling_pieces():
	for piece_id in self._pieces.keys():
		var piece = self.get_piece_by_id(piece_id)
		var piece_coordinates = self._get_coordinates_from_position(piece.position)
		if not piece_coordinates in self._floor_coordinates:
			self._pieces.erase(piece_id)
			piece.queue_free()

func _get_position_on_grid(coordinates: Vector2) -> Vector2:
	return Vector2(self._tile_size/2, self._tile_size/2) + coordinates * self._tile_size	

func _get_coordinates_from_position(grid_position: Vector2) -> Vector2:
	return (grid_position - Vector2(self._tile_size/2, self._tile_size/2)) / self._tile_size

func _on_click(piece_id, piece_player_id):
	emit_signal("update_selected_piece", piece_id, piece_player_id)

func _draw_board():
	for tile in GlobalVariables.map.get_tiles():
		# TODO: Set tile texture
		var tile_type = tile.get_tile_type()
		var tile_position = tile.get_position().get_vec()
		var new_tile = tile_prefab.instantiate()
		if tile_type == "floor":
			self._floor_coordinates.append(tile_position)
		else:
			new_tile.set_void_texture()
		new_tile.scale_texture(self._tile_size)
		add_child(new_tile)
		new_tile.position = tile_position * self._tile_size

func _get_tile_size() -> float:
	var max_width = 0
	for tile in GlobalVariables.map.get_tiles():
		var tile_position = tile.get_position()
		var x = tile_position.get_x()
		var y = tile_position.get_y()
		if x > max_width:
			max_width = x
		if y > max_width:
			max_width = y
	max_width += 1
	return min(texture.polygon[2].x, texture.polygon[2].y)/max_width
