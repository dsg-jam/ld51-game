extends Area2D

signal piece_selected

var _piece_id: String
var _player_id: String
var facing_direction: Vector2 = Vector2.DOWN
var _coordinates: Vector2
var _virtual_coordinates: Vector2

@export var _light_source: Sprite2D

func setup(piece_id: String, player_id: String, coordinates: Vector2):
	self._piece_id = piece_id
	self._player_id = player_id
	self._coordinates = coordinates

func set_coordinates(coordinates: Vector2):
	self._coordinates = coordinates
	self._virtual_coordinates = coordinates

func add_to_virtual_coordinates(direction: Vector2):
	self._virtual_coordinates += direction

func add_to_coordinates(direction: Vector2):
	self._coordinates += direction

func get_virtual_coordinates() -> Vector2:
	return self._virtual_coordinates

func get_coordinates() -> Vector2:
	return self._coordinates

func is_player_owning() -> bool:
	return self._player_id == GlobalVariables.player_id

func set_texture(player_number: int):
	$Texture.texture = GlobalVariables.get_piece_image(player_number)

func turn_light_on(intensity: float):
	self._light_source.set_modulate(Color(1, 1, 1, intensity))
	self._light_source.set_visible(true)
		
func turn_light_off():
	self._light_source.set_visible(false)

func _input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		emit_signal("piece_selected", self._piece_id, self._player_id)
