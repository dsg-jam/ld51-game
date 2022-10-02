extends Node2D

var selected_piece_id: String = "550e8400-e29b-11d4-a716-446655440000"
var next_moves: Array

enum ACTIONS {NO_ACTION, MOVE_DOWN, MOVE_LEFT, MOVE_RIGHT, MOVE_UP}

@onready var network = get_node("/root/DSGNetwork")

func _ready():
	assert(network.connect_websocket())

func _process(_delta):
	pass

func _input(_event):
	if Input.is_action_pressed("MOVE_DOWN"):
		append_move(ACTIONS.MOVE_DOWN)
	elif Input.is_action_pressed("MOVE_LEFT"):
		append_move(ACTIONS.MOVE_LEFT)
	elif Input.is_action_pressed("MOVE_RIGHT"):
		append_move(ACTIONS.MOVE_RIGHT)
	elif Input.is_action_pressed("MOVE_UP"):
		append_move(ACTIONS.MOVE_UP)
	elif Input.is_action_pressed("NOP"):
		append_move(ACTIONS.NO_ACTION)

func append_move(action: ACTIONS):
	next_moves.append({
		"piece_id": selected_piece_id,
		"action": ACTIONS.keys()[action].to_lower()
	})
	if network.is_online():
		network.send(JSON.stringify(
			{
				"type": "player_moves",
				"payload": {
					"moves": next_moves
				}
			}
		).to_utf8_buffer())

class Move:
	func _init(piece_id: String, action: ACTIONS):
		self.piece_id = piece_id
		self.action = action
