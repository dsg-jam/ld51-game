class_name DSGMessage

var _msg_type: String
var _payload: Dictionary

func to_dict() -> Dictionary:
	return {
		"type": self._msg_type,
		"payload": self._payload
	}

static func parse(data: Dictionary) -> DSGMessage:
	if not "type" in data or not "payload" in data:
		return null
	var type = data["type"]
	var payload = data["payload"]
	var res: DSGMessage = null
	match type:
		DSGMessageType.ERROR:
			res = ErrorMessage.from_dict(payload)
		DSGMessageType.PLAYER_MOVES:
			res = ErrorMessage.from_dict(payload)
		DSGMessageType.READY_FOR_NEXT_ROUND:
			res = ReadyForNextRoundMessage.from_dict(payload)
		DSGMessageType.ROUND_RESULT:
			res = RoundResultMessage.from_dict(payload)
		DSGMessageType.ROUND_START:
			res = RoundStartMessage.from_dict(payload)
		DSGMessageType.SERVER_HELLO:
			res = ServerHelloMessage.from_dict(payload)
		DSGMessageType.PLAYER_JOINED:
			res = PlayerJoinedMessage.from_dict(payload)
		DSGMessageType.PLAYER_LEFT:
			res = PlayerLeftMessage.from_dict(payload)
		DSGMessageType.HOST_START_GAME:
			res = HostStartGameMessage.from_dict(payload)
		DSGMessageType.SERVER_START_GAME:
			res = ServerStartGameMessage.from_dict(payload)
		
	return res


class ErrorMessage extends DSGMessage:
	var _type: String
	var _message: String
	var _extra: Dictionary
	
	func _init(type: String, message: String, extra: Dictionary):
		self._msg_type = DSGMessageType.ERROR
		self._type = type
		self._message = message
		self._extra = extra
	
	static func _is_valid(payload: Dictionary) -> bool:
		if not "type" in payload:
			return false
		return true
		
	static func from_dict(payload: Dictionary) -> ErrorMessage:
		if not _is_valid(payload):
			return null
		var type = payload.get("type")
		var message = payload.get("message", "")
		var extra = payload.get("extra", {})
		return ErrorMessage.new(type, message, extra)


class PlayerMovesMessage extends DSGMessage:
	var _moves: Array[PlayerMove]
	
	func _init(moves: Array[PlayerMove]):
		self._msg_type = DSGMessageType.PLAYER_MOVES		
		self._moves = moves
	
	func to_dict():
		var moves = []
		for move in self._moves:
			moves.append(move.to_dict())
		self._payload = {
			"moves": moves
		}
		return super.to_dict()
	
	static func _is_valid(payload: Dictionary) -> bool:
		if not "moves" in payload:
			return false
		return true
	
	static func from_dict(payload: Dictionary) -> PlayerMovesMessage:
		if not _is_valid(payload):
			return null
		var moves: Array[PlayerMove] = []
		for move in payload.get("moves"):
			moves.append(PlayerMove.from_dict(move))
		return PlayerMovesMessage.new(moves)


class ReadyForNextRoundMessage extends DSGMessage:
	func _init():
		self._msg_type = DSGMessageType.READY_FOR_NEXT_ROUND
	
	func to_dict() -> Dictionary:
		self._payload = {}
		return super.to_dict()
	
	static func from_dict(_p: Dictionary) -> ReadyForNextRoundMessage:
		return ReadyForNextRoundMessage.new()


class RoundResultMessage extends DSGMessage:
	var _timeline: Array[TimelineEvent]
	var _game_over: GameOver
	
	func _init(timeline: Array[TimelineEvent], game_over: GameOver = null):
		self._msg_type = DSGMessageType.ROUND_RESULT
		self._timeline = timeline
		self._game_over = game_over
	
	static func _is_valid(payload: Dictionary) -> bool:
		if not "timeline" in payload:
			return false
		return true
	
	static func from_dict(payload: Dictionary) -> RoundResultMessage:
		if not _is_valid(payload):
			return null
		var game_over = null
		if payload.get("game_over") != null:
			game_over = GameOver.from_dict(payload.get("game_over"))
		var timeline: Array[TimelineEvent] = []
		for event in payload.get("timeline"):
			timeline.append(TimelineEvent.from_dict(event))
		return RoundResultMessage.new(timeline, game_over)


class RoundStartMessage extends DSGMessage:
	var _round_number: int
	var _round_duration: float
	var _board_state: Array[PlayerPiecePosition]
	
	func _init(round_number: int, round_duration: float, board_state: Array[PlayerPiecePosition]):
		self._msg_type = DSGMessageType.ROUND_START
		self._round_number = round_number
		self._round_duration = round_duration
		self._board_state = board_state
	
	
	static func _is_valid(payload: Dictionary) -> bool:
		if not "round_number" in payload:
			return false
		if not "round_duration" in payload:
			return false
		if not "board_state" in payload:
			return false
		return true
	
	static func from_dict(payload: Dictionary) -> RoundStartMessage:
		if not _is_valid(payload):
			return null
		var round_number = payload.get("round_number")
		var round_duration = float(payload.get("round_duration"))
		var board_state: Array[PlayerPiecePosition] = []
		for piece in payload.get("board_state"):
			board_state.append(PlayerPiecePosition.from_dict(piece))
		return RoundStartMessage.new(round_number, round_duration, board_state)


class ServerHelloMessage extends DSGMessage:
	var _session_id: String
	var _is_host: bool
	var _player: PlayerInfo
	var _other_players: Array[PlayerInfo]
	
	func _init(session_id: String, is_host: bool, player: PlayerInfo, other_players: Array[PlayerInfo]):
		self._msg_type = DSGMessageType.SERVER_HELLO
		self._session_id = session_id
		self._is_host = is_host
		self._player = player
		self._other_players = other_players
	
	func write_global_variables():
		GlobalVariables.player_id = self._player._id
		GlobalVariables.player_number = self._player._number
		GlobalVariables.session_id = self._session_id
		GlobalVariables.is_host = self._is_host
	
	func get_amount_of_players() -> int:
		return len(self._other_players) + 1
	
	static func _is_valid(payload: Dictionary) -> bool:
		if not "session_id" in payload:
			return false
		if not "is_host" in payload:
			return false
		if not "player" in payload:
			return false
		if not "other_players" in payload:
			return false
		return true
	
	static func from_dict(payload: Dictionary) -> ServerHelloMessage:
		if not _is_valid(payload):
			return null
		var session_id = payload.get("session_id")
		var is_host = payload.get("is_host")
		var player = PlayerInfo.from_dict(payload.get("player"))
		var other_players: Array[PlayerInfo] = []
		for other_player in payload.get("other_players"):
			other_players.append(PlayerInfo.from_dict(other_player))
		return ServerHelloMessage.new(session_id, is_host, player, other_players)


class PlayerJoinedMessage extends DSGMessage:
	var _player: PlayerInfo
	var _reconnect: bool
	
	func _init(player: PlayerInfo, reconnect: bool):
		self._msg_type = DSGMessageType.PLAYER_JOINED
		self._player = player
		self._reconnect = reconnect
	
	func to_dict() -> Dictionary:
		self._payload = {
			"player": self._player.to_dict(),
			"reconnect": self._reconnect,
		}
		return super.to_dict()

	static func _is_valid(payload: Dictionary) -> bool:
		if not "player" in payload:
			return false
		if not "reconnect" in payload:
			return false
		return true
	
	static func from_dict(payload: Dictionary) -> PlayerJoinedMessage:
		if not _is_valid(payload):
			return null
		var player = PlayerInfo.from_dict(payload.get("player"))
		var reconnect = payload.get("reconnect")
		return PlayerJoinedMessage.new(player, reconnect)


class PlayerLeftMessage extends DSGMessage:
	var _player: PlayerInfo
	
	func _init(player: PlayerInfo):
		self._msg_type = DSGMessageType.PLAYER_LEFT
		self._player = player
	
	func to_dict() -> Dictionary:
		self._payload = {
			"player": self._player.to_dict(),
		}
		return super.to_dict()

	static func _is_valid(payload: Dictionary) -> bool:
		if not "player" in payload:
			return false
		return true
	
	static func from_dict(payload: Dictionary) -> PlayerLeftMessage:
		if not _is_valid(payload):
			return null
		var player = PlayerInfo.from_dict(payload.get("player"))
		return PlayerLeftMessage.new(player)


class HostStartGameMessage extends DSGMessage:
	var _platform: BoardPlatform
	
	func _init(platform: BoardPlatform):
		self._msg_type = DSGMessageType.HOST_START_GAME
		self._platform = platform
	
	func to_dict() -> Dictionary:
		self._payload = {
			"platform": self._platform.to_dict()
		}
		return super.to_dict()

	static func _is_valid(payload: Dictionary) -> bool:
		if not "platform" in payload:
			return false
		return true
	
	static func from_dict(payload: Dictionary) -> HostStartGameMessage:
		if not _is_valid(payload):
			return null
		var platform = BoardPlatform.from_dict(payload.get("platform"))
		return HostStartGameMessage.new(platform)


class ServerStartGameMessage extends DSGMessage:
	var _platform: BoardPlatform
	var _players: Array[PlayerInfo]
	var _pieces: Array[PlayerPiecePosition]
	var _round_start_in: float
	
	func _init(platform: BoardPlatform, players: Array[PlayerInfo], pieces: Array[PlayerPiecePosition], round_start_in: float):
		self._msg_type = DSGMessageType.SERVER_START_GAME
		self._platform = platform
		self._players = players
		self._pieces = pieces
		self._round_start_in = round_start_in

	func get_map() -> BoardPlatform:
		return self._platform
		
	func get_players() -> Array[PlayerInfo]:
		return self._players
	
	func get_pieces() -> Array[PlayerPiecePosition]:
		return self._pieces

	static func _is_valid(payload: Dictionary) -> bool:
		if not "platform" in payload:
			return false
		if not "players" in payload:
			return false
		if not "pieces" in payload:
			return false
		if not "round_start_in" in payload:
			return false
		return true
	
	static func from_dict(payload: Dictionary) -> ServerStartGameMessage:
		if not _is_valid(payload):
			return null
		var platform = BoardPlatform.from_dict(payload.get("platform"))
		var players: Array[PlayerInfo] = []
		for player in payload.get("players"):
			players.append(PlayerInfo.from_dict(player))
		var pieces: Array[PlayerPiecePosition] = []
		for piece in payload.get("pieces"):
			pieces.append(PlayerPiecePosition.from_dict(piece))
		var round_start_in = float(payload.get("round_start_in"))
		return ServerStartGameMessage.new(platform, players, pieces, round_start_in)
