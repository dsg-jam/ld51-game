extends Node

signal ws_received_message

var _client = WebSocketClient.new()

func _ready():
	_client.connection_closed.connect(_closed)
	_client.connection_error.connect(_closed)
	_client.connection_established.connect(_connected)
	_client.data_received.connect(_on_data)	

func _process(_delta):
	_client.poll()

func is_online() -> bool:
	return _client.get_peer(1).is_connected_to_host()

func connect_websocket(url: String) -> bool:
	if _client.connect_to_url(url, []) != OK:
		return false
	_client.get_peer(1).set_write_mode(WebSocketPeer.WRITE_MODE_TEXT)
	return true

func disconnect_websocket():
	_client.disconnect_from_host()

func send(payload: Dictionary):
	_client.get_peer(1).put_packet(JSON.stringify(payload).to_utf8_buffer())

func _receive():
	emit_signal("ws_received_message", _client.get_peer(1).get_packet().get_string_from_utf8())

func _closed(was_clean = false):
	print("Closed, clean: ", was_clean)

func _connected(_proto = ""):
	pass

func _on_data():
	_receive()
