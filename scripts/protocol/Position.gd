class_name Position

var _x: int
var _y: int

func _init(x: int, y: int):
	self._x = x
	self._y = y

func get_dict() -> Dictionary:
	return {
		"x": self._x,
		"y": self._y
	}
