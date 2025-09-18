extends Resource
class_name GameAction

enum TYPE {
	SET_STATE,
	# TODO Combine rig focus and focus rig to a single action (dictionary can hold all details)
	SET_RIG_FOCUS,
	FOCUS_RIG,
	TRANSFORM,
	WARN,
	UKNOWN
}
const GAME_ACTION_TYPE: String = "GAME ACTION TYPE"
const _SET_RIG_FOCUS: String = "Set Rig Focus"
const _FOCUS_RIG: String = "Focus Rig"
const _TRANSFORM: String = "Transform"
const _WARN: String = "Warn"

static func get_type_string(incoming_type: TYPE) -> String:
	match incoming_type:
		TYPE.SET_RIG_FOCUS:
			return _SET_RIG_FOCUS
		TYPE.FOCUS_RIG:
			return _FOCUS_RIG
		TYPE.TRANSFORM:
			return _TRANSFORM
		TYPE.WARN:
			return _WARN
		_:
			return GroupData.UNKNOWN

# General headers
const OWNER_GUID: String = "owner_guid"
const TARGET_GUID: String = "target_guid"
const STATE: String = "state_string"
const MESSAGE: String = "message"
# Camera headers
const FOCUS_RIG: String = "focus_rig"
# Transform
const ROTATION: String = "rotation"
const POSITION: String = "position"
const SCALE: String = "scale"
const X: String = "x"
const Y: String = "y"
const Z: String = "z"
const DIMENSION_KEYS: Array[String] = [GameAction.X, GameAction.Y, GameAction.Z]

@export var action_type: TYPE
@export var payload: Dictionary = {}

func _init(incoming_type: TYPE, incoming_payload: Dictionary) -> void:
	self.action_type = incoming_type
	self.payload = incoming_payload
