extends Node

signal connected_to_server()
signal connection_lost()
signal reconnected()
signal connection_closed()
signal message_received()

const SERVER_USE_TLS: bool = true
const SERVER_WS_PROTOCOL: String = "wss" if SERVER_USE_TLS else "ws"
const SERVER_HOST: String = "ld51-server.jam.dsg.li"

var socket := WebSocketPeer.new()
var last_state = WebSocketPeer.STATE_CLOSED
var _pending_messages: Array[DSGMessage] = []


func _process(_delta):
	_poll()


func _poll() -> void:
	if self.socket.get_ready_state() != WebSocketPeer.STATE_CLOSED:
		self.socket.poll()
	var state = self.socket.get_ready_state()
	if self.last_state != state:
		_handle_state_change(state)
	while self.socket.get_ready_state() == WebSocketPeer.STATE_OPEN and self.socket.get_available_packet_count():
		_get_message()


func _handle_state_change(state):
	self.last_state = state
	match self.last_state:
		WebSocketPeer.STATE_OPEN:
			_on_ws_open()
		WebSocketPeer.STATE_CLOSED:
			_on_ws_closed()


func _on_ws_open():
	connected_to_server.emit()
	

func _on_ws_closed():
	print("[DSGNetwork] connection closed:", self.socket.get_close_code(), self.socket.get_close_reason())
	connection_lost.emit()
	if _try_to_reconnect() == OK:
		reconnected.emit()
		return
	connection_closed.emit()


func _try_to_reconnect() -> int:
	print("[DSGNetwork] trying to reconnect with session-id %s" % GlobalVariables.session_id)
	var query = "?session_id=%s" % GlobalVariables.session_id
	return connect_to_lobby(query)


func _build_url(query: String) -> String:
	return "%s://%s/lobby/%s/join%s" % [SERVER_WS_PROTOCOL, SERVER_HOST, GlobalVariables.get_lobby_id_or_code(), query]


func _get_message():
	if self.socket.get_available_packet_count() < 1:
		return null
	var pkt = self.socket.get_packet()
	if not self.socket.was_string_packet():
		return null
	var raw_msg = pkt.get_string_from_utf8()
	var msg: Dictionary = JSON.parse_string(raw_msg)
	var dsg_msg = DSGMessage.parse(msg)
	if dsg_msg == null:
		return
	self._pending_messages.append(dsg_msg)
	self.message_received.emit()


func _close(code := 1000, reason := "") -> void:
	self.socket.close(code, reason)
	self.last_state = self.socket.get_ready_state()


func _clear() -> void:
	self.socket = WebSocketPeer.new()
	self.last_state = self.socket.get_ready_state()


func connect_to_lobby(query: String = "") -> int:
	var url = _build_url(query)
	print("[DSGNetwork] initiate connection with %s" % url)
	var err = self.socket.connect_to_url(url, TLSOptions.client())
	if err != OK:
		print("[DSGNetwork] connection failed - aborting")
		return err
	self.last_state = self.socket.get_ready_state()
	print("[DSGNetwork] connection was successful (state: %s)" % self.last_state)
	return OK


func send(payload: Dictionary) -> int:
	var raw_msg := JSON.stringify(payload)
	return self.socket.send_text(raw_msg)


func is_online() -> bool:
	return self.last_state == WebSocketPeer.STATE_OPEN


func has_pending_messages(filter: PackedStringArray) -> bool:
	if filter.is_empty():
		return not self._pending_messages.is_empty()

	for msg in self._pending_messages:
		if filter.has(msg._msg_type):
			return true
	return false


func pop_pending_message(filter: PackedStringArray = []) -> DSGMessage:
	if filter.is_empty():
		return self._pending_messages.pop_front()

	var msg: DSGMessage
	for i in range(self._pending_messages.size()):
		msg = self._pending_messages[i]
		if filter.has(msg._msg_type):
			self._pending_messages.remove_at(i)
			return msg
	return null
