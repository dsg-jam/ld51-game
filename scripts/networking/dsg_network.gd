extends Node

signal connected_to_server()
signal connection_lost()
signal reconnected()
signal connection_closed()
signal message_received()

const SERVER_USE_TLS: bool = true
const SERVER_WS_PROTOCOL: String = "wss" if SERVER_USE_TLS else "ws"
const SERVER_HOST: String = "ld51-server.jam.dsg.li"
const RECONNECT_CODES: Array[int] = [
	4101, 4102, 4103
]

var _socket := WebSocketPeer.new()
var last_state = WebSocketPeer.STATE_CLOSED
var _pending_messages: Array[DSGMessage] = []


func _ready():
	self.set_process(false)


func _process(_delta):
	_poll()


func _poll() -> void:
	var current_state = self._socket.get_ready_state()
	if current_state != WebSocketPeer.STATE_CLOSED:
		self._socket.poll()
	if self.last_state != current_state:
		_handle_state_change(current_state)
	while self._socket.get_ready_state() == WebSocketPeer.STATE_OPEN and self._socket.get_available_packet_count():
		_get_message()


func _handle_state_change(state):
	self.last_state = state
	match self.last_state:
		WebSocketPeer.STATE_CONNECTING:
			DSGLogger.network_log("connecting...")
		WebSocketPeer.STATE_OPEN:
			_on_ws_open()
		WebSocketPeer.STATE_CLOSED:
			_on_ws_closed()


func _on_ws_open():
	DSGLogger.network_log("connection was successful")
	connected_to_server.emit()
	

func _on_ws_closed():
	var close_code = self._socket.get_close_code()
	var close_reason = self._socket.get_close_reason()
	connection_lost.emit()
	if close_code in RECONNECT_CODES:
		DSGLogger.network_log("connection lost with CODE: %s and REASON: %s" % [close_code, close_reason])
		if _try_to_reconnect() == OK:
			reconnected.emit()
			return
	DSGLogger.network_log("connection closed with CODE: %s and REASON: %s" % [close_code, close_reason])
	connection_closed.emit()
	self.set_process(false)


func _try_to_reconnect() -> int:
	DSGLogger.network_log("trying to reconnect with session-id %s" % GlobalVariables.session_id)
	var query = "?session_id=%s" % GlobalVariables.session_id
	return connect_to_lobby(query)


func _build_url(query: String) -> String:
	return "%s://%s/lobby/%s/join%s" % [SERVER_WS_PROTOCOL, SERVER_HOST, GlobalVariables.get_lobby_id_or_code(), query]


func _get_message():
	if self._socket.get_available_packet_count() < 1:
		return null
	var pkt = self._socket.get_packet()
	if not self._socket.was_string_packet():
		return null
	var raw_msg = pkt.get_string_from_utf8()
	var msg: Dictionary = JSON.parse_string(raw_msg)
	var dsg_msg = DSGMessage.parse(msg)
	if dsg_msg == null:
		return
	self._pending_messages.append(dsg_msg)
	self.message_received.emit()


func _close(code := 1000, reason := "") -> void:
	self._socket.close(code, reason)
	self.last_state = self._socket.get_ready_state()


func _clear() -> void:
	self._socket = WebSocketPeer.new()
	self.last_state = self._socket.get_ready_state()


func connect_to_lobby(query: String = "") -> int:
	var url = _build_url(query)
	DSGLogger.network_log("establishing connection with %s" % url)
	var err = self._socket.connect_to_url(url, TLSOptions.client())
	if err != OK:
		DSGLogger.network_log("connection failed - aborting")
		return err
	self.set_process(true)
	return OK


func send(payload: Dictionary) -> int:
	var raw_msg := JSON.stringify(payload)
	return self._socket.send_text(raw_msg)


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
