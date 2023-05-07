class_name TimelineEvent

var _actions: Array[TimelineEventAction]
var _outcomes: Array[Outcome]

func _init(actions: Array[TimelineEventAction], outcomes: Array[Outcome]):
	self._actions = actions
	self._outcomes = outcomes


func to_dict() -> Dictionary:
	return {
		"actions": [],
		"outcomes": [],
	}
	
static func _is_valid(payload: Dictionary) -> bool:
	if "actions" not in payload:
		return false
	if "outcomes" not in payload:
		return false
	return true

static func from_dict(payload: Dictionary) -> TimelineEvent:
	if not _is_valid(payload): return null
	var actions: Array[TimelineEventAction] = []
	for action in payload.get("actions"):
		actions.append(TimelineEventAction.from_dict(action))
	var outcomes: Array[Outcome] = []
	for outcome in payload.get("outcomes"):
		outcomes.append(Outcome.parse(outcome))
	return TimelineEvent.new(actions, outcomes)
