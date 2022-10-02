extends Node2D

var selected_piece_id: String = ""
var moves_left: int
var next_moves: Array
var player_id: String

enum ACTIONS {NO_ACTION, MOVE_DOWN, MOVE_LEFT, MOVE_RIGHT, MOVE_UP}

@onready var network = get_node("/root/DSGNetwork")
@onready var board = $Board
@onready var message = $MessageLabel
@onready var moves_message = $MovesLabel
@onready var timer_message = $TimerLabel
@onready var timer = $Timer

func _ready():
	assert(network.connect_websocket())
	board.update_selected_piece.connect(_on_update_selected_piece)
	moves_left = 10
	timer.start(100)
	player_id = "550e8400-e29b-0000-a716-446655440003"
	moves_message.text = "Moves left: " + str(moves_left)

func _on_update_selected_piece(piece_id, piece_player_id):
	if player_id == piece_player_id:
		selected_piece_id = piece_id
		message.text = piece_id

func _process(_delta):
	timer_message.text = "Time left: %.1f" % timer.time_left

func _input(_event):
	if Input.is_action_just_pressed("MOVE_DOWN"):
		append_move(ACTIONS.MOVE_DOWN)
	elif Input.is_action_just_pressed("MOVE_LEFT"):
		append_move(ACTIONS.MOVE_LEFT)
	elif Input.is_action_just_pressed("MOVE_RIGHT"):
		append_move(ACTIONS.MOVE_RIGHT)
	elif Input.is_action_just_pressed("MOVE_UP"):
		append_move(ACTIONS.MOVE_UP)
	elif Input.is_action_just_pressed("NO_ACTION"):
		append_move(ACTIONS.NO_ACTION)
	elif Input.is_action_just_pressed("REMOVE_MOVE"):
		remove_latest_move()
	moves_message.text = "Moves left: " + str(moves_left)

func remove_latest_move():
	if next_moves.size() <= 0:
		return
	next_moves.pop_back()
	moves_left += 1

func append_move(action: ACTIONS):
	if selected_piece_id == "" or moves_left <= 0:
		return
	next_moves.append({
		"piece_id": selected_piece_id,
		"action": ACTIONS.keys()[action].to_lower()
	})
	moves_left -= 1

class Move:
	func _init(piece_id: String, action: ACTIONS):
		self.piece_id = piece_id
		self.action = action


func _on_timer_timeout():
	complete_next_moves()
	if network.is_online():
		network.send(JSON.stringify(
			{
				"type": "player_moves",
				"payload": {
					"moves": next_moves
				}
			}
		).to_utf8_buffer())

func complete_next_moves():
	if (next_moves.size() >= 10):
		return
	while next_moves.size() < 10:
		next_moves.append({
			"piece_id": "00000000-0000-0000-0000-000000000000",
			"action": ACTIONS.keys()[ACTIONS.NO_ACTION].to_lower()
		})
