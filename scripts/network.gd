extends Node

signal message_received(String)

const SERVER_USE_TLS: bool = true
const SERVER_HOST: String = "51.jam.dsg.link"

var _client := WebSocketClient.new()
var _pending_messages: Array[Dictionary] = []

func _ready():
	self._client.connection_closed.connect(self._closed)
	self._client.connection_error.connect(self._closed)
	self._client.connection_established.connect(self._connected)
	self._client.data_received.connect(self._on_data)	

func _process(_delta):
	self._client.poll()

func _get_peer() -> WebSocketPeer:
	return self._client.get_peer(1)

func is_online() -> bool:
	return self._get_peer().is_connected_to_host()

func connect_to_lobby(lobby_id: String) -> bool:
	var protocol: String
	if SERVER_USE_TLS:
		protocol = "wss"
	else:
		protocol = "ws"
	var url := "%s://%s/lobby/%s/join" % [protocol, SERVER_HOST, lobby_id]
	if self._client.connect_to_url(url, []) != OK:
		return false
	self._get_peer().set_write_mode(WebSocketPeer.WRITE_MODE_TEXT)
	return true

func disconnect_websocket():
	self._client.disconnect_from_host()

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
