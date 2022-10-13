extends Area2D

signal piece_selected

var _piece_id: String
var _player_id: String
var facing_direction: Vector2 = Vector2.DOWN

@export var _light_source: PointLight2D

func setup(piece_id: String, player_id: String):
	self._piece_id = piece_id
	self._player_id = player_id

func is_player_owning() -> bool:
	return self._player_id == GlobalVariables.player_id

func turn_light_on(intensity: float):
	self._light_source.set_energy(intensity)
	self._light_source.set_enabled(true)
		
func turn_light_off():
	self._light_source.set_enabled(false)

func _input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		emit_signal("piece_selected", self._piece_id, self._player_id)
