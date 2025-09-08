# TODO OOOOOO
#			Create a constructor in CameraState to handle the incoming rig
#			Ensure that CameraState has a duplicate function
#			Ensure that null can be returned after the log (don't think it can)
#			Then get AssetFactory passing in newly created cameras to here to ahve their states registered
#	->		Then confirm that cameras are in fact in state
#			Then get the other types of stuff integrated and registered on creation with state
#			Then confirm other created things are in fact in state
#			THEN finally get to integrating the global state controller with this stuff and the actual logic

# Holds current camera information
class_name CameraState

const _MISSING_GUID: String = "Incoming associated rig \"%s\" is missing a GUID"

var _cameras: Dictionary = {}

func _init(incoming_cameras: Dictionary = {}) -> void:
	self._cameras = incoming_cameras

func register_new_rig(incoming_rig: CameraRig) -> CameraStateData:
	if incoming_rig.has_meta(GroupData.GUID):
		var rig_state: CameraStateData = CameraStateData.new(incoming_rig)
		_cameras[incoming_rig.get_meta(GroupData.GUID)] = rig_state
		return rig_state.duplicate()
	else:
		Logger.error(self._MISSING_GUID, [incoming_rig.name], self)
		return null

func duplicate() -> CameraState:
	var copy := CameraState.new()
	for guid in _cameras.keys():
		var state: CameraStateData = _cameras[guid]
		copy._cameras[guid] = state.duplicate()
	return copy

func print_details() -> void:
	Logger.debug("CameraState Cameras: \"%d\"", [_cameras.size()], self)
	for guid in _cameras.keys():
		var state: CameraStateData = _cameras[guid]
		if state.has_method("print_details"):
			state.print_details()
