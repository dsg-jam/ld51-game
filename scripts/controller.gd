extends Node2D

enum ACTIONS {NO_ACTION, MOVE_DOWN, MOVE_LEFT, MOVE_RIGHT, MOVE_UP}

var selected_piece_id: String = ""
var moves_left: int
var next_moves: Array

@export var message: Label
@export var moves_message: Label
@export var timer_message: Label

@onready var network = get_node("/root/DSGNetwork")
@onready var board = $Board
@onready var timer = $Timer

func _ready():
	board.update_selected_piece.connect(_on_update_selected_piece)
	moves_left = 5
	timer.start(10)
	moves_message.text = "Moves left: " + str(moves_left)

func _process(_delta):
	timer_message.text = "Time left: %.1f" % timer.time_left

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
	moves_message.text = "Moves left: " + str(moves_left)

func _on_update_selected_piece(piece_id, piece_player_id):
	if GlobalVariables.player_id == piece_player_id:
		selected_piece_id = piece_id
		message.text = piece_id

func _remove_latest_move():
	if next_moves.size() <= 0:
		return
	next_moves.pop_back()
	moves_left += 1

func _append_move(action: ACTIONS):
	if selected_piece_id == "" or moves_left <= 0:
		return
	next_moves.append({
		"piece_id": selected_piece_id,
		"action": ACTIONS.keys()[action].to_lower()
	})
	moves_left -= 1

func _on_timer_timeout():
	_complete_next_moves()
	$GongAudio.play()
	if network.is_online():
		network.send({
			"type": "player_moves",
			"payload": {
				"moves": next_moves
			}
		})

func _complete_next_moves():
	if (next_moves.size() >= 10):
		return
	while next_moves.size() < 10:
		next_moves.append({
			"piece_id": "00000000-0000-0000-0000-000000000000",
			"action": ACTIONS.keys()[ACTIONS.NO_ACTION].to_lower()
		})
