extends Resource
class_name GameAction

enum TYPE {
	SET_RIG_FOCUS,
	FOCUS_RIG,
	UKNOWN
}

const OWNER_GUID: String = "owner_guid"
const TARGET_GUID: String = "target_guid"
# Camera headers
const FOCUS_RIG: String = "focus_rig"

@export var action_type: TYPE
@export var payload: Dictionary = {}

func _init(incoming_type: TYPE, incoming_payload: Dictionary) -> void:
	self.action_type = incoming_type
	self.payload = incoming_payload
