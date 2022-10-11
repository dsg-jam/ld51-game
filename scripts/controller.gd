extends Node2D

enum ACTIONS {NO_ACTION, MOVE_DOWN, MOVE_LEFT, MOVE_RIGHT, MOVE_UP}
enum STATES {AWAITING_ROUND, AWAITING_RESULT}

const MAX_MOVES = 5

var MSG_FILTER := PackedStringArray([
	DSGMessageType.ROUND_RESULT,
	DSGMessageType.ROUND_START,
])

var _selected_piece_id: String = ""
var _moves_left: int = 0
var _next_moves: Array
var _current_state: STATES
var _round_number: int = 0

@export var message: Label
@export var moves_message: Label
@export var timer_message: Label

@onready var board = $Board
@onready var timer = $Timer

func _ready():
	DSGNetwork.message_received.connect(_on_ws_received_message)
	board.update_selected_piece.connect(_on_update_selected_piece)
	self._current_state = STATES.AWAITING_ROUND

	# catch up on all the messages we missed while loading
	self._on_ws_received_message("")

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

func _on_ws_received_message(_msg_type: String) -> void:
	while true:
		var msg: Variant = DSGNetwork.pop_pending_message(MSG_FILTER)
		if msg == null:
			break

		match msg["type"]:
			DSGMessageType.ROUND_START:
				if self._current_state == STATES.AWAITING_ROUND:
					self._start_round(msg["payload"])
			DSGMessageType.ROUND_RESULT:
				if self._current_state == STATES.AWAITING_RESULT:
					self._animate_round(msg["payload"])

func _start_round(payload: Dictionary):
	self._next_moves = []
	self._moves_left = 5
	self._selected_piece_id = ""
	self._round_number = payload["round_number"]
	timer.start(payload["round_duration"])
	var pieces = payload["board_state"]
	for piece in pieces:
		board.place_piece(piece["piece_id"], piece["player_id"], Vector2(piece["position"]["x"], piece["position"]["y"]))
	board.turn_all_player_piece_lights_on(0.4)

func _animate_round(payload: Dictionary):
	await board.animate_events(payload["timeline"])
	DSGNetwork.send({
		"type": DSGMessageType.READY_FOR_NEXT_ROUND,
		"payload": {}
	})
	self._current_state = STATES.AWAITING_ROUND

func _on_update_selected_piece(piece_id, piece_player_id):
	if GlobalVariables.player_id == piece_player_id:
		board.turn_all_player_piece_lights_on(0.4)
		board.get_piece_by_id(piece_id).turn_light_on(0.6)
		self._selected_piece_id = piece_id

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
	$GongAudio.play()
	if DSGNetwork.is_online():
		DSGNetwork.send({
			"type": DSGMessageType.PLAYER_MOVES,
			"payload": {
				"moves": self._next_moves
			}
		})
	self._current_state = STATES.AWAITING_RESULT
	board.turn_all_piece_lights_off()

func _update_labels():
	self.moves_message.text = "Moves left: " + str(self._moves_left)
	self.timer_message.text = "Time left: %.1f" % self.timer.time_left
	self.message.text = "Round " + str(self._round_number)
