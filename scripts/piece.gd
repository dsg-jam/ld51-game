extends Area2D

var _piece_id: String
var is_selected = false

signal piece_selected

func set_piece_id(piece_id: String):
	self._piece_id = piece_id

func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		emit_signal("piece_selected", _piece_id)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
