class_name Outcome

const MOVE_CONFLICT: String = "move_conflict"
const PUSH: String = "push"
const PUSH_CONFLICT: String = "push_conflict"

var _type: String

static func parse(data: Dictionary) -> Outcome:
	if not "type" in data or not "payload" in data:
		return null
	var type = data["type"]
	var payload = data["payload"]
	var res: Outcome = null
	match data["type"]:
		MOVE_CONFLICT:
			res = MoveConflictOutcome.from_dict(payload)
		PUSH:
			res = PushOutcome.from_dict(payload)
		PUSH_CONFLICT:
			res = PushConflictOutcome.from_dict(payload)
	
	if res != null:
		res._type = type
	
	return res


class MoveConflictOutcome extends Outcome:
	var _piece_ids: Array[String]
	var _collision_point: BoardPosition
	
	func _init(piece_ids: Array[String], collision_point: BoardPosition):
		self._piece_ids = piece_ids
		self._collision_point = collision_point
	
	func get_piece_ids() -> Array[String]:
		return self._piece_ids
	
	func get_collision_point_as_vec() -> Vector2:
		return self._collision_point.get_vec()
	
	static func _is_valid(payload: Dictionary) -> bool:
		if not "piece_ids" in payload:
			return false
		if not "collision_point" in payload:
			return false
		return true
	
	static func from_dict(payload: Dictionary) -> MoveConflictOutcome:
		if not _is_valid(payload):
			return null
		var collision_point = BoardPosition.from_dict(payload.get("collision_point"))
		var piece_ids: Array[String] = []
		for piece_id in payload.get("piece_ids"):
			piece_ids.append(piece_id)
		return MoveConflictOutcome.new(piece_ids, collision_point)


class PushOutcome extends Outcome:
	var _pusher_piece_id: String
	var _victim_piece_ids: Array[String]
	var _direction: String
	
	func _init(pusher_piece_id: String, victim_piece_ids: Array[String], direction: String):
		self._pusher_piece_id = pusher_piece_id
		self._victim_piece_ids = victim_piece_ids
		self._direction = direction
		
	func get_piece_ids() -> Array[String]:
		var pusher_piece: String = self._pusher_piece_id
		var piece_ids: Array[String] = self._victim_piece_ids
		piece_ids.push_front(pusher_piece)
		return piece_ids
		
	func get_direction_as_vec() -> Vector2:
		return Utils.direction_to_vec[self._direction]
	
	static func _is_valid(payload: Dictionary) -> bool:
		if not "pusher_piece_id" in payload:
			return false
		if not "victim_piece_ids" in payload:
			return false
		if not "direction" in payload:
			return false
		return true
	
	static func from_dict(payload: Dictionary) -> PushOutcome:
		if not _is_valid(payload):
			return null
		var pusher_piece_id = payload.get("pusher_piece_id")
		var victim_piece_ids: Array[String] = []
		for victim_piece_id in payload.get("victim_piece_ids"):
			victim_piece_ids.append(victim_piece_id)
		var direction = payload.get("direction")		
		return PushOutcome.new(pusher_piece_id, victim_piece_ids, direction)


class PushConflictOutcome extends Outcome:
	var _piece_ids: Array[String]
	var _collision_point: BoardPosition
	
	func _init(piece_ids: Array[String], collision_point: BoardPosition = null):
		self._piece_ids = piece_ids
		self._collision_point = collision_point
	
	func get_piece_ids() -> Array[String]:
		return self._piece_ids
	
	static func _is_valid(payload: Dictionary) -> bool:
		if not "piece_ids" in payload:
			return false
		return true
	
	static func from_dict(payload: Dictionary) -> PushConflictOutcome:
		if not _is_valid(payload):
			return null
		var collision_point = null
		var collision_point_payload = payload.get("collision_point")
		if collision_point_payload != null:
			collision_point = BoardPosition.from_dict(collision_point_payload)
		var piece_ids: Array[String] = []
		for piece_id in payload.get("piece_ids"):
			piece_ids.append(piece_id)
		return PushConflictOutcome.new(piece_ids, collision_point)
