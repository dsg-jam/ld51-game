extends Sprite2D

var _piece_id: String
var _direction: Vector2

func setup(piece_id: String, direction: Vector2):
	self._piece_id = piece_id
	self._direction = direction

func get_piece_id() -> String:
	return self._piece_id

func get_direction() -> Vector2:
	return self._direction
