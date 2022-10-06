extends Area2D

signal piece_selected

var _piece_id: String
var _player_id: String
var is_selected = false
var facing_direction = Vector2.DOWN

func setup(piece_id: String, player_id: String):
	_piece_id = piece_id
	_player_id = player_id

func _input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		emit_signal("piece_selected", _piece_id, _player_id)
