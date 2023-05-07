class_name BoardAnimation

static func animate_event(board: Board, outcomes: Array[Outcome]):
	for outcome in outcomes:
		_animate_outcome(board, outcome)


static func _animate_outcome(board: Board, outcome: Outcome):
	if outcome is Outcome.PushOutcome:
		_animate_push_outcome(board, outcome)
	if outcome is Outcome.MoveConflictOutcome:
		_animate_move_conflict_outcome(board, outcome)
	if outcome is Outcome.PushConflictOutcome:
		_animate_push_conflict_outcome(board, outcome)


static func _animate_push_outcome(board: Board, outcome: Outcome.PushOutcome):
	var piece_ids = outcome.get_piece_ids()
	var direction = outcome.get_direction_as_vec()
	for idx in piece_ids.size():
		var piece = board.get_piece_by_id(piece_ids[idx])
		_rotate_and_move_piece(board, piece, direction, 0.125 * idx)
		piece.add_to_coordinates(direction)


static func _animate_move_conflict_outcome(board: Board, outcome: Outcome.MoveConflictOutcome):
	var collision_point = outcome.get_collision_point_as_vec()
	for moving_piece_id in outcome.get_piece_ids():
		var current_piece = board.get_piece_by_id(moving_piece_id)
		var new_position = board._get_position_on_grid(collision_point)
		var direction = (new_position-current_piece.position).normalized()
		_rotate_and_collide_piece(board, current_piece, direction / 2.0)


static func _animate_push_conflict_outcome(board: Board, outcome: Outcome.PushConflictOutcome):
	for piece_id in outcome.get_piece_ids():
		var piece = board.get_piece_by_id(piece_id)
		_rotate_piece(board, piece, 2*PI)


static func _rotate_and_move_piece(board: Board, piece: Piece, direction: Vector2, delay: float = 0.0):
	board.place_move_arrow(piece.position, direction)
	var finished = piece.animate_rotation_and_move(direction * board.tile_size, delay, false)
	finished.connect(board.outcome_animation_finished)
	board._running_animations += 1


static func _rotate_and_collide_piece(board: Board, piece: Piece, direction: Vector2):
	board.place_move_arrow(piece.position, direction)
	var finished = piece.animate_rotation_and_move(direction * board.tile_size, 0.0, true)
	finished.connect(board.outcome_animation_finished)
	board._running_animations += 1

	
static func _rotate_piece(board: Board, piece: Piece, angle: float):
	var finished = piece.animate_rotation(angle)
	finished.connect(board.outcome_animation_finished)
	board._running_animations += 1
