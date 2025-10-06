class_name SceneUtil

## Focuses the first found character using the first found camera rig
static func focus_character() -> void:
	var primary_player_guid: String = GlobalStateController.get_primary_guid(STATE.DATA_TYPE.PLAYER)
	var primary_camera_guid: String = GlobalStateController.get_primary_guid(STATE.DATA_TYPE.CAMERA)
	var state_string: String = STATE.get_state_string(STATE.ASSET.TRACKING_FULL)
	var focus_state_dictionary: Dictionary = {
		StateHeaders.OWNER_GUID: primary_camera_guid,
		StateHeaders.SET_STATE:  state_string,
		StateHeaders.TARGET_GUID: primary_player_guid
	}
	var focus_action: GameAction = GameAction.new(GameAction.TYPE.SET_STATE, focus_state_dictionary)
	GlobalStateController.dispatch(focus_action)
