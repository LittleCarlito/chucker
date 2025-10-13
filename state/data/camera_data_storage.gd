extends StateDataStorage
# TODO Rename to CameraStateStorage
class_name CameraDataStorage

const _MISSING_NODE: String = "Could not perform %s \"$s\" was missing"
const _FOCUS_GUID: String = "Focus GUID"
const _CAMERA: String = "Camera"
const _FOCUS: String = "Focus"

# TODO Refactor the user of this to pull the node from StateStorage functions instead
#		Then delete this class
func set_camera_focus(camera_guid: String, focus_guid: String) -> bool:
	var has_camera: bool = has_guid(camera_guid)
	var node_exists: bool = GlobalStateController.node_has_state(focus_guid)
	if has_camera and node_exists:
		var camera_state_data: StateData = get_header_data(camera_guid, StateHeaders.TYPE.DATA)
		camera_state_data.set_focus(focus_guid)
		return true
	else:
		var missing_variable: String = _CAMERA if !has_camera else ""
		if missing_variable != "":
			missing_variable += "; "
		missing_variable += _FOCUS if !node_exists else ""
		Log.error(_MISSING_NODE, [_FOCUS_GUID, missing_variable], self)
		return false
