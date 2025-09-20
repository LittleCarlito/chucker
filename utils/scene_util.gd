class_name SceneUtil

## Focuses the first found character using the first found camera rig
static func focus_character(incoming_assets: Dictionary) -> void:
	var primary_player_guid: String = GlobalStateController.get_primary_guid(GameState.DATA_TYPE.PLAYER)
	var primary_camera_guid: String = GlobalStateController.get_primary_guid(GameState.DATA_TYPE.CAMERA)
	# Focus the camera on player
	var focus_camera_dictionary: Dictionary = {
		GameAction.OWNER_GUID: primary_camera_guid,
		GameAction.TARGET_GUID: primary_camera_guid
	}
	var focus_camera_action: GameAction = GameAction.new(GameAction.TYPE.SET_RIG_FOCUS, focus_camera_dictionary)
	GlobalStateController.dispatch(focus_camera_action)
	# Set the camera to track the player
	var state_string: String = StateConfiguration.get_state_string(StateConfiguration.STATE.TRACKING_FULL)
	var set_state_dictionary: Dictionary = {
		GameAction.OWNER_GUID: primary_camera_guid,
		GameAction.STATE: state_string
	}
	var set_state_action: GameAction = GameAction.new(GameAction.TYPE.SET_STATE, set_state_dictionary)
	GlobalStateController.dispatch(set_state_action)
