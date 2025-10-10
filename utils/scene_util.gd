class_name SceneUtil

const _PRIMARY_RIG: String = "Primary Camera Rig"
const _FOCUS_CHARACTER: String = "focus_character"

## Focuses the first found character using the first found camera rig
static func focus_character() -> void:
	var primary_player_guid: String = GlobalStateController.get_primary_guid(STATE.DATA_TYPE.PLAYER)
	var primary_camera_guid: String = GlobalStateController.get_primary_guid(STATE.DATA_TYPE.CAMERA)
	var primary_rig: CameraRig = GlobalStateController.get_header_data(primary_camera_guid, StateHeaders.TYPE.NODE)
	if primary_rig != null:
		primary_rig.track_guid(primary_player_guid, STATE.ASSET.TRACKING_FULL)
	else:
		Log.error(Log._CANT_PERFORM, [_PRIMARY_RIG, _FOCUS_CHARACTER], null)
