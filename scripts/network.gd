extends Node

signal connected_to_server()
signal connection_closed()
signal message_received(message: String)

const SERVER_USE_TLS: bool = true
const SERVER_HOST: String = "ld51-server.jam.dsg.li"

var socket := WebSocketPeer.new()
var last_state = WebSocketPeer.STATE_CLOSED
var _pending_messages: Array[Dictionary] = []


func connect_to_lobby(lobby_id: String) -> int:
	var protocol: String
	if SERVER_USE_TLS:
		protocol = "wss"
	else:
		protocol = "ws"
	var url := "%s://%s/lobby/%s/join" % [protocol, SERVER_HOST, lobby_id]
	var err = socket.connect_to_url(url, TLSOptions.client())
	if err != OK:
		return err
	last_state = socket.get_ready_state()
	return OK


func send(payload: Dictionary) -> int:
	var raw_msg := JSON.stringify(payload)
	return socket.send_text(raw_msg)


func get_message():
	if socket.get_available_packet_count() < 1:
		return null
	var pkt = socket.get_packet()
	if not socket.was_string_packet():
		return null
	var raw_msg = pkt.get_string_from_utf8()
	var msg: Dictionary = JSON.parse_string(raw_msg)
	self._pending_messages.append(msg)
	self.message_received.emit(msg["type"])


func close(code := 1000, reason := "") -> void:
	socket.close(code, reason)
	last_state = socket.get_ready_state()


func clear() -> void:
	socket = WebSocketPeer.new()
	last_state = socket.get_ready_state()


func is_online() -> bool:
	return last_state == WebSocketPeer.STATE_OPEN


func poll() -> void:
	if socket.get_ready_state() != socket.STATE_CLOSED:
		socket.poll()
	var state = socket.get_ready_state()
	if last_state != state:
		last_state = state
		if state == socket.STATE_OPEN:
			connected_to_server.emit()
		elif state == socket.STATE_CLOSED:
			print("closed:", socket.get_close_code(), socket.get_close_reason())
			connection_closed.emit()
	while socket.get_ready_state() == socket.STATE_OPEN and socket.get_available_packet_count():
		get_message()


func _process(_delta):
	poll()


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
