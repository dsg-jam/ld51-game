extends Node

signal message_received(String)

var _client := WebSocketClient.new()
var _pending_messages: Array[Dictionary] = []

func _ready():
	_client.connection_closed.connect(_closed)
	_client.connection_error.connect(_closed)
	_client.connection_established.connect(_connected)
	_client.data_received.connect(_on_data)	

func _process(_delta):
	_client.poll()

func _get_peer() -> WebSocketPeer:
	return self._client.get_peer(1)

func is_online() -> bool:
	return self._get_peer().is_connected_to_host()

func connect_websocket(url: String) -> bool:
	if _client.connect_to_url(url, []) != OK:
		return false
	self._get_peer().set_write_mode(WebSocketPeer.WRITE_MODE_TEXT)
	return true

func disconnect_websocket():
	_client.disconnect_from_host()

func send(payload: Dictionary):
	var raw_msg := JSON.stringify(payload).to_utf8_buffer()
	self._get_peer().put_packet(raw_msg)

func _closed(was_clean = false):
	print("Closed, clean: ", was_clean)

func _connected(_proto):
	pass

func _on_data() -> void:
	var raw_msg := self._get_peer().get_packet().get_string_from_utf8()
	var msg: Dictionary = JSON.parse_string(raw_msg)
	self._pending_messages.append(msg)
	self.message_received.emit(msg["type"])

func has_pending_messages(filter: PackedStringArray) -> bool:
	if filter.is_empty():
		return not self._pending_messages.is_empty()

	for msg in self._pending_messages:
		if filter.has(msg["type"]):
			return true
	return false

func pop_pending_message(filter: PackedStringArray) -> Variant:
	if filter.is_empty():
		return self._pending_messages.pop_front()

	var msg: Variant
	for i in range(self._pending_messages.size()):
		msg = self._pending_messages[i]
		if filter.has(msg["type"]):
			self._pending_messages.remove_at(i)
			return msg
	return null
