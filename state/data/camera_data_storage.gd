extends StateDataStorage
# TODO Rename to CameraStateStorage
class_name CameraDataStorage

const _MISSING_NODE: String = "Could not perform %s \"$s\" was missing"
const _FOCUS_GUID: String = "Focus GUID"
const _CAMERA: String = "Camera"
const _FOCUS: String = "Focus"

func set_camera_focus(camera_guid: String, focus_guid: String) -> bool:
	var has_camera: bool = self.has_guid(camera_guid)
	var node_exists: bool = GlobalStateController.node_has_state(focus_guid)
	if has_camera and node_exists:
		var camera_state_data: CameraStateData = self.get_header_data(camera_guid, StateHeaders.TYPE.DATA)
		camera_state_data.set_focus(focus_guid)
		return true
	else:
		var missing_variable: String = self._CAMERA if !has_camera else ""
		if missing_variable != "":
			missing_variable += "; "
		missing_variable += self._FOCUS if !node_exists else ""
		Log.error(self._MISSING_NODE, [self._FOCUS_GUID, missing_variable], self)
		return false
