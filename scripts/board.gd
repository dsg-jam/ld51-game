class_name Board
extends Node2D

signal update_selected_piece

const directions = {
	"up": Vector2.UP,
	"down": Vector2.DOWN,
	"left": Vector2.LEFT,
	"right": Vector2.RIGHT
}

var _pieces: Dictionary
var _move_arrows: Array
var _floor_coordinates: Array[Vector2]
var _running_animations: Array[Signal]
var tile_size: float

@onready var texture = $Texture
@onready var tile_prefab = preload("res://prefabs/tile.tscn")
@onready var piece_prefab = preload("res://prefabs/piece.tscn")
@onready var _arrow = preload("res://prefabs/arrow.tscn")

func _ready():
	var viewport = get_tree().get_root().size
	var map_size = min(viewport.x, viewport.y)
	texture.polygon *= Transform2D.IDENTITY * map_size 
	self.tile_size = self._get_tile_size()
	self._draw_board()


func _handle_falling_pieces():
	for piece_id in self._pieces.keys():
		var piece = self.get_piece_by_id(piece_id)
		if piece.get_coordinates() in self._floor_coordinates:
			continue
		self._pieces.erase(piece_id)
		piece.animate_falling().connect(_remove_piece.bind(piece))


func _remove_piece(piece: Piece):
	piece.queue_free()


func _get_position_on_grid(coordinates: Vector2) -> Vector2:
	return Vector2(self.tile_size/2.0, self.tile_size/2.0) + coordinates * self.tile_size


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
		new_tile.scale_texture(self.tile_size)
		add_child(new_tile)
		new_tile.position = tile_position * self.tile_size


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
	return roundf(min(texture.polygon[2].x, texture.polygon[2].y)/max_width)


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


func place_input_arrow(piece_id: String, dir: Vector2):
	var piece: Piece = self.get_piece_by_id(piece_id)
	var pos = self._get_position_on_grid(piece.get_virtual_coordinates())
	self.place_move_arrow(pos, dir, piece)
	piece.add_to_virtual_coordinates(dir)


func place_move_arrow(pos: Vector2, dir: Vector2, piece: Piece = null):
	var arrow = self._arrow.instantiate()
	var arrow_scale = self.tile_size / arrow.get_rect().size.x
	var arrow_pos = pos + self.tile_size * dir / 2.0
	arrow.setup(piece, dir, arrow_scale, arrow_pos)
	add_child(arrow)
	self._move_arrows.append(arrow)


func purge_arrows():
	for move_arrow in self._move_arrows:
		move_arrow.queue_free()
	self._move_arrows = []


func remove_latest_arrow():
	if len(self._move_arrows) < 1:
		return
	var move_arrow = self._move_arrows.pop_back()
	var piece = move_arrow.get_piece()
	piece.add_to_virtual_coordinates(- move_arrow.get_direction())
	move_arrow.queue_free()


func get_piece_by_id(piece_id: String) -> Piece:
	return self._pieces.get(piece_id)


func get_sorted_player_pieces() -> Array[String]:
	var piece_ids = self._pieces.keys().filter(self._filter_player_pieces)
	piece_ids.sort_custom(self._sort_by_position)
	return piece_ids


func turn_all_player_piece_lights_on():
	for piece in self._pieces.values():
		if piece.is_player_owning():
			piece.turn_light_on()
		else:
			piece.turn_dim_on()


func turn_all_piece_lights_off():
	for piece in self._pieces.values():
		piece.turn_light_off()


func place_piece(piece_id: String, player_id: String, piece_coordinates: Vector2):
	if piece_id in self._pieces:
		var piece = self.get_piece_by_id(piece_id)
		piece.set_coordinates(piece_coordinates)
		piece.position = self._get_position_on_grid(piece_coordinates)
		return
	var new_piece: Piece = piece_prefab.instantiate()
	new_piece.set_texture(GlobalVariables.players[player_id])
	var piece_scale = min(
		self.tile_size / new_piece.get_node("Texture").get_rect().size.x,
		self.tile_size / new_piece.get_node("Texture").get_rect().size.y
	)
	new_piece.scale.x = piece_scale
	new_piece.scale.y = piece_scale
	new_piece.setup(piece_id, player_id, piece_coordinates)
	new_piece.position = self._get_position_on_grid(piece_coordinates)
	new_piece.piece_selected.connect(_on_click)
	add_child(new_piece)
	self._pieces[piece_id] = new_piece


func animate_events(events: Array):
	for event in events:
		self._running_animations = []
		BoardAnimation.animate_event(self, event["outcomes"])
		for running_animation in self._running_animations:
			if running_animation:
				await running_animation
		self._handle_falling_pieces()
		self.purge_arrows()
