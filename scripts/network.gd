extends Node

var _url: String = "ws://127.0.0.1:8000/lobby/550e8400-e29b-11d4-a716-446655440000/join"
var _client = WebSocketClient.new()

func is_online() -> bool:
	return _client.get_peer(1).is_connected_to_host()

func connect_websocket() -> bool:
	if _client.connect_to_url(_url, []) != OK:
		return false
	_client.get_peer(1).set_write_mode(WebSocketPeer.WRITE_MODE_TEXT)
	return true

func disconnect_websocket():
	_client.disconnect_from_host()
	
func set_url(new_url: String):
	_url = new_url

func send(payload: PackedByteArray):
	_client.get_peer(1).put_packet(payload)

func _receive():
	print("Got data from server: ", _client.get_peer(1).get_packet().get_string_from_utf8())

func _ready():
	_client.connection_closed.connect(_closed)
	_client.connection_error.connect(_closed)
	_client.connection_established.connect(_connected)
	_client.data_received.connect(_on_data)	

func _closed(was_clean = false):
	print("Closed, clean: ", was_clean)

func _connected(_proto = ""):
	pass

func _on_data():
	_receive()

func _process(_delta):
	_client.poll()
