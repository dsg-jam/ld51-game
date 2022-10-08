class_name Position

var _x: int
var _y: int

func _init(x: int, y: int):
	self._x = x
	self._y = y

func get_x() -> int:
	return self._x

func get_y() -> int:
	return self._y

func get_dict() -> Dictionary:
	return {
		"x": self._x,
		"y": self._y
	}

static func get_obj_from_dict(data: Dictionary) -> Position:
	assert("x" in data)
	assert("y" in data)
	return Position.new(data["x"], data["y"])
	
