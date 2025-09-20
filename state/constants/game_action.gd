extends Resource
class_name GameAction

enum TYPE {
	# TODO Combine SET_RIG_FOCUS and FOCUS_RIG into SET_STATE
	#			Really are just details of state change so it makes sense
	SET_STATE,
	# TODO Combine rig focus and focus rig to a single action (dictionary can hold all details)
	SET_RIG_FOCUS, # Setting the guid the camera is focused on


	TRANSFORM,
	WARN,
	UKNOWN
}
const GAME_ACTION_TYPE: String = "GAME ACTION TYPE"
const _SET_RIG_FOCUS: String = "Set Rig Focus"
const _TRANSFORM: String = "Transform"
const _WARN: String = "Warn"

static func get_type_string(incoming_type: TYPE) -> String:
	match incoming_type:
		TYPE.SET_RIG_FOCUS:
			return _SET_RIG_FOCUS
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
# Transform
const IS_SPRINTING: String = "is_sprinting"
const ROTATION: String = "rotation"
const POSITION: String = "position"
const SCALE: String = "scale"
const X: String = "x"
const Y: String = "y"
const Z: String = "z"
const DIMENSION_KEYS: Array[String] = [GameAction.X, GameAction.Y, GameAction.Z]
const TRANSFORM_KEYS: Array[String] = [GameAction.ROTATION, GameAction.POSITION, GameAction.SCALE, GameAction.IS_SPRINTING]

@export var action_type: TYPE
@export var payload: Dictionary = {}

func _init(incoming_type: TYPE, incoming_payload: Dictionary) -> void:
	self.action_type = incoming_type
	self.payload = incoming_payload
