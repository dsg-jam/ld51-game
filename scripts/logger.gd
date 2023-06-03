class_name DSGLogger

enum SERVICES {NETWORKING=0, LOBBY=1, GAME_LOOP=2}

const SERVICE_MAPPING = {
	0: "[DSGNetwork]",
	1: "[Lobby]",
	2: "[Game-Loop]",
}

static func _log(service: SERVICES, msg: String):
	print("%sZ: %s %s" % [Time.get_datetime_string_from_system(true), SERVICE_MAPPING[service], msg])

static func network_log(msg: String):
	_log(SERVICES.NETWORKING, msg)

static func lobby_log(msg: String):
	_log(SERVICES.LOBBY, msg)

static func game_log(msg: String):
	_log(SERVICES.GAME_LOOP, msg)
