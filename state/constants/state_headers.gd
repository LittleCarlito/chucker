class_name StateHeaders

const OWNER_NAME: String = "owner_name"
const OWNER_GUID: String = "owner_guid"
const TARGET_GUID: String = "target_guid"
const ROTATION: String = "rotation"
const POSITION: String = "position"
const SCALE: String = "scale"
const TOGGLE: String = "toggle"
# TODO Look to delete below
const TARGET_POSITION: String = "target_position"
const CURRENT_STATE: String = "current_state"
const PREVIOUS_STATE: String = "previous_state"
const SET_STATE: String = "set_state"
const CURRENT_STATE_DURATION: String = "current_state_duration"
const STATE_WINDOWS: String = "state_windows"
const VALID_TRANSITIONS: String = "valid_transitions"
const STATE_VALUES: String = "state_values"

const STATE_DICTIONARY: String = "state_dictionary"
const STATE_DATA: String = "state_data"
const STATE_NODE: String = "state_node"

# TODO Look to move this to state_def or something
enum TYPE {
	DATA_STORAGE,
	DATA,
	NODE,
	UNKNOWN
}

static func get_type_string(incoming_type: TYPE) -> String:
	match incoming_type:
		TYPE.DATA_STORAGE:
			return STATE_DICTIONARY
		TYPE.DATA:
			return STATE_DATA
		TYPE.NODE:
			return STATE_NODE
		_:
			return GroupData.UNKNOWN
