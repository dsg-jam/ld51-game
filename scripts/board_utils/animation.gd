class_name BoardAnimation

static func animate_event(board: Board, outcomes: Array):
	for outcome in outcomes:
		_animate_outcome(board, outcome)


static func _animate_outcome(board: Board, outcome: Dictionary):
	match outcome["type"]:
		"push":
			_animate_push_outcome(board, outcome["payload"])
		"move_conflict":
			_animate_move_conflict_outcome(board, outcome["payload"])
		"push_conflict":
			_animate_push_conflict_outcome(board, outcome["payload"])


static func _animate_push_outcome(board: Board, payload: Dictionary):
	var pusher_piece: String = payload["pusher_piece_id"]
	var piece_ids: Array = payload["victim_piece_ids"]
	piece_ids.push_front(pusher_piece)
	var direction = board.directions[payload["direction"]]
	for idx in piece_ids.size():
		var piece = board.get_piece_by_id(piece_ids[idx])
		_rotate_and_move_piece(board, piece, direction, 0.125 * idx)
		piece.add_to_coordinates(direction)


static func _animate_move_conflict_outcome(board: Board, payload: Dictionary):
	var new_coordinates = Vector2(payload["collision_point"]["x"], payload["collision_point"]["y"])
	for moving_piece_id in payload["piece_ids"]:
		var current_piece = board.get_piece_by_id(moving_piece_id)
		var new_position = board._get_position_on_grid(new_coordinates)
		var direction = (new_position-current_piece.position).normalized()
		_rotate_and_collide_piece(board, current_piece, direction / 2.0)


static func _animate_push_conflict_outcome(board: Board, payload: Dictionary):
	var piece_ids = payload["piece_ids"]
	for piece_id in piece_ids:
		var piece = board.get_piece_by_id(piece_id)
		_rotate_piece(board, piece, 2*PI)


static func _rotate_and_move_piece(board: Board, piece: Piece, direction: Vector2, delay: float = 0.0):
	board.place_move_arrow(piece.position, direction)
	var finished = piece.animate_rotation_and_move(direction * board.tile_size, delay, false)
	board._running_animations.append(finished)


static func _rotate_and_collide_piece(board: Board, piece: Piece, direction: Vector2):
	board.place_move_arrow(piece.position, direction)
	var finished = piece.animate_rotation_and_move(direction * board.tile_size, 0.0, true)
	board._running_animations.append(finished)

	
static func _rotate_piece(board: Board, piece: Piece, angle: float):
	var finished = piece.animate_rotation(angle)
	board._running_animations.append(finished)
