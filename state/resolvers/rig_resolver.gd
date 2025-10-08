class_name RigResolver

const _RESOLVE_STATE: String = "resolve_state"
const _RESOLVE_FOCUS: String = "resolve_focus"
const _RESOLVE_TOGGLES: String = "resolve_toggles"
const _MIN_HEIGHT_WARN: String = "\"%s\" is now having its height artificially held to min height of \"%f\""
const _MISSING_FOCUSED_GUID: String = "\"%s\" is in a tracking state but has no focused GUID"
const _MISSING_FOCUSED_DATA: String = "\"%s\" is focused on guid \"%s\" but is missing its AssetState data"

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

static func resolve_for_frame(incoming_rig: CameraRig, delta: float) -> void:
	# Handle min height logic
	var current_min_height: float = incoming_rig.get_min_height()
	if current_min_height != -NUMBERS.FLOAT16_MAX:
		var camera_controller_height: float = incoming_rig.get_camera_controller_height()
		var is_height_held: bool = current_min_height > camera_controller_height
		incoming_rig.set_camera_controller_height(max(current_min_height, camera_controller_height))
		if is_height_held:
			var height_warning: String = _MIN_HEIGHT_WARN % [incoming_rig.name, current_min_height]
			incoming_rig.output_warning(height_warning)
	var incoming_state: STATE.ASSET = incoming_rig.get_current_state()
	if StateUtil.is_tracking(incoming_state):
		var focused_guid: String = incoming_rig.get_focused_guid()
		if focused_guid != null && !focused_guid.strip_edges().is_empty():
			var focused_data: AssetState = incoming_rig.get_tracked_data_for(focused_guid)
			if focused_data != null:
				var focused_position: Vector3 = focused_data.get_current_position()
				incoming_rig.track_position(focused_position)
			else:
				var data_warn: String = _MISSING_FOCUSED_DATA % [incoming_rig.name, focused_guid]
				incoming_rig.output_warning(data_warn)
		else:
			var guid_warn: String = _MISSING_FOCUSED_GUID % [incoming_rig.name]
			incoming_rig.output_warning(guid_warn)
