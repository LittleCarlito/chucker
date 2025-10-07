class_name RigResolver

const _RESOLVE_STATE: String = "resolve_state"
const _RESOLVE_FOCUS: String = "resolve_focus"
const _RESOLVE_TOGGLES: String = "resolve_toggles"

static func resolve_focus(incoming_rig: CameraRig, incoming_update: StateUpdate) -> void:
	var update_details = incoming_update.get_details()
	var missing_keys: Array[String] = StateUtil.get_missing_keys(update_details, [StateHeaders.TARGET_POSITION])
	if missing_keys.is_empty():
		var new_position: Vector3 = update_details[StateHeaders.TARGET_POSITION]
		incoming_rig.snap_to(new_position)
	else:
		Logger.error(Logger._CANT_PERFORM, [missing_keys, _RESOLVE_FOCUS], null)

## Right now it is just logic handling transitioning into and out of tracking state
static func resolve_state(incoming_rig: CameraRig, incoming_update: StateUpdate) -> void:
	var missing_keys: Array[String] = StateUtil.get_missing_keys(incoming_update.get_details(), [StateHeaders.PREVIOUS_STATE, StateHeaders.CURRENT_STATE])
	if missing_keys.is_empty():
		var detail_dictionary = incoming_update.get_details()
		var tracking_detection: int = StateUtil.compare_tracking_state(detail_dictionary[StateHeaders.PREVIOUS_STATE], detail_dictionary[StateHeaders.CURRENT_STATE])
		if tracking_detection == 1:
			incoming_rig.apply_tracking_distance()
		if tracking_detection == -1:
			incoming_rig.remove_tracking_distance()
	else:
		Logger.error(Logger._CANT_PERFORM, [missing_keys, _RESOLVE_STATE], null)

static func resolve_toggles(incoming_rig: CameraRig, incoming_details: Dictionary) -> void:
	var missing_keys: Array[String] = StateUtil.get_missing_keys(incoming_details, StateHeaders.TOGGLE_KEYS)
	if missing_keys.is_empty():
		if !missing_keys.has(StateHeaders.IS_CROUCHING):
			var is_crouching: bool = incoming_details[StateHeaders.IS_CROUCHING]
			if is_crouching:
				incoming_rig.apply_crouching_distance()
			else:
				incoming_rig.remove_crouching_distance()
	else:
		Logger.error(Logger._CANT_PERFORM, [missing_keys, _RESOLVE_TOGGLES], null)
