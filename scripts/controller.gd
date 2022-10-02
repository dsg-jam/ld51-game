extends Node2D

var selected_piece_id: String = "UUID PLACEHOLDER"
var next_moves: Array

enum ACTIONS {NOP, MOVE_DOWN, MOVE_LEFT, MOVE_RIGHT, MOVE_UP}

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
		append_move(ACTIONS.NOP)

func append_move(action: ACTIONS):
	next_moves.append({
		"piece_id": selected_piece_id,
		"action": ACTIONS.keys()[action]
	})
	if network.is_online():
		network.send(JSON.stringify(next_moves).to_utf8_buffer())

class Move:
	func _init(piece_id: String, action: ACTIONS):
		self.piece_id = piece_id
		self.action = action
