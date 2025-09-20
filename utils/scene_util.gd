class_name SceneUtil

## Focuses the first found character using the first found camera rig
static func focus_character(incoming_assets: Dictionary) -> void:
	var primary_player_guid: String = GlobalStateController.get_primary_guid(GameState.DATA_TYPE.PLAYER)
	var primary_camera_guid: String = GlobalStateController.get_primary_guid(GameState.DATA_TYPE.CAMERA)
	var state_string: String = StateConfiguration.get_state_string(StateConfiguration.STATE.TRACKING_FULL)
	var focus_state_dictionary: Dictionary = {
		GameAction.OWNER_GUID: primary_camera_guid,
		GameAction.STATE:  state_string,
		GameAction.TARGET_GUID: primary_player_guid
	}
	var focus_action: GameAction = GameAction.new(GameAction.TYPE.SET_STATE, focus_state_dictionary)
	GlobalStateController.dispatch(focus_action)
