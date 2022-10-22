extends Sprite2D

const Piece = preload("res://scripts/piece.gd")

var _piece: Piece
var _direction: Vector2

func setup(piece: Piece, dir: Vector2, arrow_scale: float, pos: Vector2):
	self._piece = piece
	self._direction = dir
	scale = arrow_scale * Vector2.ONE
	rotation = Vector2.RIGHT.angle_to(dir)
	position = pos

func get_piece() -> Piece:
	return self._piece

func get_direction() -> Vector2:
	return self._direction
