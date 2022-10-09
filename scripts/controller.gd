extends Node2D

enum ACTIONS {NO_ACTION, MOVE_DOWN, MOVE_LEFT, MOVE_RIGHT, MOVE_UP}
enum STATES {AWAITING_ROUND, ROUND_UNDERGOING, AWAITING_RESULT, ANIMATING_MOVES}

var _selected_piece_id: String = ""
var _moves_left: int
var _next_moves: Array
var _current_state: STATES

@export var message: Label
@export var moves_message: Label
@export var timer_message: Label

@onready var board = $Board
@onready var timer = $Timer

func _ready():
	board.update_selected_piece.connect(_on_update_selected_piece)
	self._current_state = STATES.AWAITING_ROUND
	self._moves_left = 5
	timer.start(10)

func _process(_delta):
	self._update_labels()
	match self._current_state:
		STATES.AWAITING_ROUND:
			pass
		STATES.ROUND_UNDERGOING:
			pass
		STATES.AWAITING_RESULT:
			pass
		STATES.ANIMATING_MOVES:
			pass

func _input(_event):
	if Input.is_action_just_pressed("MOVE_DOWN"):
		_append_move(ACTIONS.MOVE_DOWN)
	elif Input.is_action_just_pressed("MOVE_LEFT"):
		_append_move(ACTIONS.MOVE_LEFT)
	elif Input.is_action_just_pressed("MOVE_RIGHT"):
		_append_move(ACTIONS.MOVE_RIGHT)
	elif Input.is_action_just_pressed("MOVE_UP"):
		_append_move(ACTIONS.MOVE_UP)
	elif Input.is_action_just_pressed("NO_ACTION"):
		_append_move(ACTIONS.NO_ACTION)
	elif Input.is_action_just_pressed("REMOVE_MOVE"):
		_remove_latest_move()
	self._update_labels()

func _on_update_selected_piece(piece_id, piece_player_id):
	if GlobalVariables.player_id == piece_player_id:
		self._selected_piece_id = piece_id
		message.text = piece_id

func _remove_latest_move():
	if self._next_moves.size() <= 0:
		return
	self._next_moves.pop_back()
	self._moves_left += 1

func _append_move(action: ACTIONS):
	if self._selected_piece_id == "" or self._moves_left <= 0:
		return
	self._next_moves.append({
		"piece_id": self._selected_piece_id,
		"action": ACTIONS.keys()[action].to_lower()
	})
	self._moves_left -= 1

func _on_timer_timeout():
	_complete_next_moves()
	$GongAudio.play()
	if DSGNetwork.is_online():
		DSGNetwork.send({
			"type": "player_moves",
			"payload": {
				"moves": self._next_moves
			}
		})

func _complete_next_moves():
	if (self._next_moves.size() >= 10):
		return
	while self._next_moves.size() < 10:
		self._next_moves.append({
			"piece_id": "00000000-0000-0000-0000-000000000000",
			"action": ACTIONS.keys()[ACTIONS.NO_ACTION].to_lower()
		})

func _update_labels():
	self.moves_message.text = "Moves left: " + str(self._moves_left)
	self.timer_message.text = "Time left: %.1f" % self.timer.time_left
