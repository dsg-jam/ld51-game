class_name Piece
extends Area2D

signal piece_selected

var _piece_id: String
var _player_id: String
var facing_direction: Vector2 = Vector2.DOWN
var _coordinates: Vector2
var _virtual_coordinates: Vector2
var _tween: Tween

@export var ROTATION_ANIMATION_DURATION: float = 1.0
@export var MOVE_ANIMATION_DURATION: float = 1.0
@export var MOVE_BACK_ANIMATION_DURATION: float = 0.2
@export var FALLING_ANIMATION_DURATION: float = 1.0

func setup(piece_id: String, player_id: String, coordinates: Vector2):
	self._piece_id = piece_id
	self._player_id = player_id
	self._coordinates = coordinates


func _animate_piece_rotation(direction: Vector2, delay: float = 0.0, transition: int = Tween.TRANS_BACK):
	var angle = self.facing_direction.angle_to(direction)
	self._tween.tween_property(self, "rotation", angle, ROTATION_ANIMATION_DURATION).set_trans(transition).set_delay(delay)


func _animate_piece_move(direction: Vector2, delay: float = 0.0, transition: int = Tween.TRANS_CUBIC):
	var new_position = self.position + direction
	self._tween.tween_property(self, "position", new_position, MOVE_ANIMATION_DURATION).set_trans(transition).set_delay(delay)


func animate_rotation_and_move(direction: Vector2, delay: float = 0.0, slide_back: bool = false) -> Signal:
	var initial_position := position
	self._tween = create_tween()
	self._animate_piece_rotation(direction)
	self._animate_piece_move(direction, delay)
	if slide_back:
		self._tween.tween_property(self, "position", initial_position, MOVE_BACK_ANIMATION_DURATION).set_trans(Tween.TRANS_BOUNCE)
	return self._tween.finished


func animate_rotation(angle: float) -> Signal:
	self._tween = create_tween()
	self._tween.tween_property(self, "rotation", angle, ROTATION_ANIMATION_DURATION).set_trans(Tween.TRANS_BACK)
	return self._tween.finished


func animate_falling() -> Signal:
	self._tween = create_tween()
	self._tween.tween_property(self, "scale", Vector2(), FALLING_ANIMATION_DURATION)
	return self._tween.finished


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


func turn_light_on(is_selected: bool = false):
	$Texture.material.set_shader_parameter("is_flashing", true)
	$Texture.material.set_shader_parameter("is_selected", is_selected)


func turn_dim_on():
	$Texture.material.set_shader_parameter("is_dim", true);


func turn_light_off():
	$Texture.material.set_shader_parameter("is_flashing", false)
	$Texture.material.set_shader_parameter("is_selected", false)
	$Texture.material.set_shader_parameter("is_dim", false);


func _input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		emit_signal("piece_selected", self._piece_id, self._player_id)
