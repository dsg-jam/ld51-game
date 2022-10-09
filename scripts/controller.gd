extends Node2D

enum ACTIONS {NO_ACTION, MOVE_DOWN, MOVE_LEFT, MOVE_RIGHT, MOVE_UP}
enum STATES {AWAITING_ROUND, AWAITING_RESULT}

const MAX_MOVES = 5

var _selected_piece_id: String = ""
var _moves_left: int = 0
var _next_moves: Array
var _current_state: STATES

@export var message: Label
@export var moves_message: Label
@export var timer_message: Label

@onready var board = $Board
@onready var timer = $Timer

func _ready():
	DSGNetwork.ws_received_message.connect(_on_ws_received_message)
	board.update_selected_piece.connect(_on_update_selected_piece)
	self._current_state = STATES.AWAITING_ROUND

func _process(_delta):
	self._update_labels()

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

func _on_ws_received_message(stream: String):
	var message = JSON.parse_string(stream)
	print(message)
	match self._current_state:
		STATES.AWAITING_ROUND:
			if message["type"] == "round_start":
				self._next_moves = []
				self._moves_left = 5
				timer.start(message["payload"]["round_duration"])
				var pieces = message["payload"]["board_state"]
				for piece in pieces:
					board.place_piece(piece["piece_id"], piece["player_id"], Vector2(piece["position"]["x"], piece["position"]["y"]))
		STATES.AWAITING_RESULT:
			if message["type"] == "round_result":
				await board.animate_events(message["payload"]["timeline"])
				DSGNetwork.send({
					"type": "ready_for_next_round",
					"payload": {}
				})
				self._current_state = STATES.AWAITING_ROUND

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
	self._current_state = STATES.AWAITING_RESULT

func _complete_next_moves():
	if (self._next_moves.size() >= MAX_MOVES):
		return
	while self._next_moves.size() < MAX_MOVES:
		self._next_moves.append({
			"piece_id": board.pieces.keys()[0],
			"action": ACTIONS.keys()[ACTIONS.NO_ACTION].to_lower()
		})

func _update_labels():
	self.moves_message.text = "Moves left: " + str(self._moves_left)
	self.timer_message.text = "Time left: %.1f" % self.timer.time_left
