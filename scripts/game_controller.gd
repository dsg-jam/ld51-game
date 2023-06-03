extends Node2D

enum ACTIONS {NO_ACTION, MOVE_DOWN, MOVE_LEFT, MOVE_RIGHT, MOVE_UP}
enum STATES {AWAITING_ROUND, ONGOING_ROUND, AWAITING_RESULT, ONGOING_ANIMATION}

const MAX_MOVES: int = 5
const Piece = preload("res://scripts/piece.gd")

var MSG_FILTER := PackedStringArray([
	DSGMessageType.ROUND_RESULT,
	DSGMessageType.ROUND_START,
])

var _selected_piece_id: String = ""
var _moves_left: int = 0
var _next_moves: Array[PlayerMove]
var _current_state: STATES
var _round_number: int = 0
var _latest_round_result: DSGMessage.RoundResultMessage

@export var _message: Label
@export var _moves_message: Label
@export var _timer_message: Label
@export var _control: HBoxContainer
@export var _pop_up_panel: Panel
@export var _pop_up_label: Label

@onready var _board = $Board
@onready var _timer = $Timer

func _ready():
	_handle_screen_resize()
	get_tree().get_root().connect("size_changed", _handle_screen_resize)
	DSGNetwork.message_received.connect(self._on_ws_received_message)
	DSGNetwork.connection_lost.connect(_on_connection_lost)
	DSGNetwork.connection_closed.connect(_on_connection_closed)
	DSGNetwork.reconnected.connect(_on_reconnection)
	self._board.update_selected_piece.connect(self._on_update_selected_piece)
	self._board.ready_for_next_round.connect(_ready_for_next_round)
	self._current_state = STATES.AWAITING_ROUND
	self._place_pieces(GlobalVariables.pieces)

	# catch up on all the messages we missed while loading
	self._on_ws_received_message()


func _handle_screen_resize():
	var viewport = get_tree().get_root().size
	_control.hide()
	if Utils.is_mobile_device():
		_control.show()
	position.x = max(viewport.x / 2 - viewport.y / 2, 0)
	position.y = max(viewport.y / 2 - viewport.x / 2, 0)


func _process(_delta):
	self._update_labels()


func _input(_event):
	if self._current_state != STATES.ONGOING_ROUND:
		return
	if Input.is_action_just_pressed("MOVE_DOWN"):
		self._append_move(ACTIONS.MOVE_DOWN, Vector2.DOWN)
	elif Input.is_action_just_pressed("MOVE_LEFT"):
		self._append_move(ACTIONS.MOVE_LEFT, Vector2.LEFT)
	elif Input.is_action_just_pressed("MOVE_RIGHT"):
		self._append_move(ACTIONS.MOVE_RIGHT, Vector2.RIGHT)
	elif Input.is_action_just_pressed("MOVE_UP"):
		self._append_move(ACTIONS.MOVE_UP, Vector2.UP)
	elif Input.is_action_just_pressed("NO_ACTION"):
		self._append_move(ACTIONS.NO_ACTION, Vector2.ZERO)
	elif Input.is_action_just_pressed("REMOVE_MOVE"):
		self._remove_latest_move()
	elif Input.is_action_just_pressed("SELECT_NEXT"):
		self._select_next_piece()


func _on_ws_received_message() -> void:
	while true:
		var msg: DSGMessage = DSGNetwork.pop_pending_message(MSG_FILTER)
		if msg == null:
			break

		if msg is DSGMessage.RoundStartMessage:
			self._current_state = STATES.ONGOING_ROUND
			self._pop_up_panel.hide()
			self._start_round(msg)
		if msg is DSGMessage.RoundResultMessage:
			if self._current_state == STATES.AWAITING_RESULT:
				self._current_state = STATES.ONGOING_ANIMATION
				self._animate_round(msg)


func _start_round(msg: DSGMessage.RoundStartMessage):
	self._next_moves = []
	self._moves_left = 5
	self._selected_piece_id = ""
	self._round_number = msg._round_number
	self._timer.start(msg._round_duration)
	var pieces = msg._board_state
	self._place_pieces(pieces)
	self._board.turn_all_player_piece_lights_on()


func _place_pieces(pieces: Array[PlayerPiecePosition]):
	for piece in pieces:
		self._board.place_piece(piece._piece_id, piece._player_id, piece._position.get_vec())


func _animate_round(msg: DSGMessage.RoundResultMessage):
	self._latest_round_result = msg
	self._board.animate_events(msg._timeline)


func _ready_for_next_round():
	self._current_state = STATES.AWAITING_ROUND
	GlobalVariables.winner_id = ""
	var ready_message = DSGMessage.ReadyForNextRoundMessage.new()
	DSGNetwork.send(ready_message.to_dict())
	var msg = self._latest_round_result
	var game_over: GameOver = msg._game_over
	if game_over == null:
		return
	GlobalVariables.winner_id = game_over._winner_player_id
	get_tree().change_scene_to_file("res://scenes/lobby.tscn")


func _on_update_selected_piece(piece_id, piece_player_id):
	if GlobalVariables.player_id == piece_player_id:
		self._selected_piece_id = piece_id
		self._update_lights()


func _remove_latest_move():
	if self._next_moves.size() <= 0:
		return
	self._next_moves.pop_back()
	self._board.remove_latest_arrow()
	self._moves_left += 1


func _append_move(action: ACTIONS, direction: Vector2):
	if self._selected_piece_id == "" or self._moves_left <= 0:
		return
	var player_move = PlayerMove.new(
		self._selected_piece_id,
		ACTIONS.keys()[action].to_lower()
	)
	self._next_moves.append(player_move)
	if direction != Vector2.ZERO:
		self._board.place_input_arrow(self._selected_piece_id, direction)
	self._moves_left -= 1


func _on_timer_timeout():
	$GongAudio.play()
	self._current_state = STATES.AWAITING_RESULT
	var player_moves = DSGMessage.PlayerMovesMessage.new(self._next_moves)
	DSGNetwork.send(player_moves.to_dict())
	self._board.purge_arrows()
	self._board.turn_all_piece_lights_off()


func _select_next_piece():
	self._selected_piece_id = self._get_next_piece_id()
	self._update_lights()


func _get_next_piece_id() -> String:
	var sorted = self._board.get_sorted_player_pieces()
	if sorted.is_empty():
		return ""
	if self._selected_piece_id == "":
		return sorted[0]
	var idx = sorted.find(self._selected_piece_id)
	var next_idx = (idx + 1) % len(sorted)
	return sorted[next_idx]


func _update_lights():
	if self._current_state != STATES.ONGOING_ROUND:
		return
	self._board.turn_all_player_piece_lights_on()
	var piece: Piece = self._board.get_piece_by_id(self._selected_piece_id)
	if piece != null:
		piece.turn_light_on(true)


func _update_labels():
	self._moves_message.text = "Moves left: " + str(self._moves_left)
	self._timer_message.text = "%.1f s" % self._timer.time_left
	self._message.text = "Round " + str(self._round_number)


func _on_up_button_pressed():
	self._append_move(ACTIONS.MOVE_UP, Vector2.UP)


func _on_down_button_pressed():
	self._append_move(ACTIONS.MOVE_DOWN, Vector2.DOWN)


func _on_left_button_pressed():
	self._append_move(ACTIONS.MOVE_LEFT, Vector2.LEFT)


func _on_right_button_pressed():
	self._append_move(ACTIONS.MOVE_RIGHT, Vector2.RIGHT)

func _on_reconnection():
	self._ready_for_next_round()
	self._pop_up_label.text = "Waiting for next round..."
	self._pop_up_panel.show()

func _on_connection_lost():
	self._pop_up_label.text = "Establishing connection..."
	self._pop_up_panel.show()
	
func _on_connection_closed():
	get_tree().change_scene_to_file("res://scenes/start.tscn")
