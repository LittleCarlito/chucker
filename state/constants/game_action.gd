extends Resource
class_name GameAction

const UNSUPPORTED: String = "Incoming action type \"%s\" is not supported"

enum TYPE {
	# TODO Not sure if the older ones are needed in new setup
	# Newer post Resource
	TRACK,
	# Older pre Resource
	SET_STATE,
	TRANSFORM,
	WARN,
	UKNOWN
}
const GAME_ACTION_TYPE: String = "GAME ACTION TYPE"
const _SET_STATE: String = "Set State"
const _TRANSFORM: String = "Transform"
const _WARN: String = "Warn"
const _TRACK: String = "Track"

static func get_type_string(incoming_type: TYPE) -> String:
	match incoming_type:
		TYPE.SET_STATE:
			return _SET_STATE
		TYPE.TRANSFORM:
			return _TRANSFORM
		TYPE.WARN:
			return _WARN
		TYPE.TRACK:
			return _TRACK
		_:
			return GroupData.UNKNOWN

# General headers
const OWNER_GUID: String = "owner_guid" # GUID action will be taken on
const TARGET_GUID: String = "target_guid" # Target for things like tracking; Not target of action
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
# Tags
const TAGS: String = "tags"
const SYNC: String = "sync"

@export var action_type: TYPE
@export var payload: Dictionary = {}

func _init(incoming_type: TYPE, incoming_payload: Dictionary) -> void:
	self.action_type = incoming_type
	self.payload = incoming_payload
