class_name BoardPosition

var _x: int
var _y: int

func _init(x: int, y: int):
	self._x = x
	self._y = y

func get_x() -> int:
	return self._x

func get_y() -> int:
	return self._y

func get_vec() -> Vector2:
	return Vector2(self._x, self._y)

func to_dict() -> Dictionary:
	return {
		"x": self._x,
		"y": self._y
	}

static func _is_valid(payload: Dictionary) -> bool:
	if not "x" in payload:
		return false
	if not "y" in payload:
		return false
	return true

static func from_dict(payload: Dictionary) -> BoardPosition:
	if not _is_valid(payload): return null
	return BoardPosition.new(payload["x"], payload["y"])
	
