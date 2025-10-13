extends Resource
class_name AssetState

signal state_data_change(state_update: StateUpdate)

const CLASS_NAME: String = "AssetState"
const _CURRENTLY_TRACKED: String = "Cannot stop tracking GUID \"%s\" as it is the currently tracked asset; Change asset state before untracking"
const _BAD_FORMAT: String = "Incoming request to \"%s\" cannot be performed; %d optional parameters must be provided"
const _DUPLICATE_TRACKED_STATES: String = "Duplicate tracked asset states belonging to owner \"%s\" have been found; ILLEGAL STATE"
const _MISSING_TRACK_DATA: String = "No state data could be found in tracked assets for GUID \"%s\""
const _HANDLE_FOCUS: String = "Handle Focus Action"
const _GET_OWNER_GUID: String = "Get Owner GUID"
const _STATE_DATA: String = "State Data"

var _guid_string: String
var _state_data: StateData
var _state_warnings: Dictionary
var _tracked_assets: Dictionary
# TODO Implement all needed logic for "holding" an asset
#			Getting it
#			Dropping it
#			Getting all held
#			Dropping all held
#			Get "Primary" held
#				Should just be first entry
#			Rotate to next "Primary"
#				Should send current primary last
#				2nd index becomes first everyone bumps
var _held_assets: Dictionary

func _init(
			owner_guid: String,
			incoming_transitions: Dictionary = {}, 
			incoming_values: Dictionary = {}, 
			incoming_windows: Dictionary = {}
		) -> void:
	_guid_string = owner_guid
	_state_data = StateData.new(_guid_string, incoming_transitions, incoming_values, incoming_windows)

func sync_asset(owner_position: Vector3, owner_rotation: Quaternion, owner_scale: Vector3) -> void:
	_state_data.update_position(owner_position)
	_state_data.update_rotation(owner_rotation)
	_state_data.update_scale(owner_scale)

func get_min_height() -> float:
	return _state_data.get_min_height()

func set_min_height(incoming_height: float) -> void:
	_state_data.set_min_height(incoming_height)

func get_vertical_length() -> float:
	return _state_data.get_current_vertical_length()

func set_veritcal_length(incoming_length: float) -> void:
	_state_data.set_current_vertical_length(incoming_length)

func get_current_velocity() -> Vector3:
	return _state_data.get_current_velocity()

func get_current_x_velocity() -> float:
	return _state_data.get_current_x_velocity()

func get_current_y_velocity() -> float:
	return _state_data.get_current_y_velocity()

func get_current_z_velocity() -> float:
	return _state_data.get_current_z_velocity()

func set_current_velocity(incoming_velocity: Vector3) -> void:
	_state_data.set_current_velocity(incoming_velocity)

func set_current_x_velocity(incoming_velocity: float) -> void:
	_state_data.set_current_x_velocity(incoming_velocity)

func set_current_y_velocity(incoming_velocity: float) -> void:
	_state_data.set_current_y_velocity(incoming_velocity)

func set_current_z_velocity(incoming_velocity: float) -> void:
	_state_data.set_current_z_velocity(incoming_velocity)

func apply_velocity(incoming_velocity: Vector3) -> void:
	_state_data.apply_current_velocity(incoming_velocity)

func apply_x_velocity(incoming_velocity: float) -> void:
	_state_data.apply_current_x_velocity(incoming_velocity)

func apply_y_velocity(incoming_velocity: float) -> void:
	_state_data.apply_current_y_velocity(incoming_velocity)

func apply_z_velocity(incoming_velocity: float) -> void:
	_state_data.apply_current_z_velocity(incoming_velocity)

func get_current_position() -> Vector3:
	return _state_data.get_current_position()

func get_current_rotation() -> Quaternion:
	return _state_data.get_current_rotation()

func get_current_scale() -> Vector3:
	return _state_data.get_current_scale()

func update_movement_enabled(incoming_value: bool) -> void:
	return _state_data.update_movement_enabled(incoming_value)

func is_movement_enabled() -> bool:
	return _state_data.is_movement_enabled()

func is_sprinting() -> bool:
	return _state_data.is_sprinting()

func start_sprinting() -> void:
	_state_data.update_is_sprinting(true)

func stop_sprinting() -> void:
	_state_data.update_is_sprinting(false)

func get_focused_guid() -> String:
	return _state_data.get_focused_guid()

## Returns first tracked GUID; Null if none are tracked
func get_first_tracked() -> AssetState:
	if _tracked_assets == null:
		_tracked_assets = {}
	return _tracked_assets.values()[0]

func get_tracked_data_for(incoming_guid: String) -> AssetState:
	if _tracked_assets == null:
		_tracked_assets = {}
	return _tracked_assets.get(incoming_guid)

func get_tracked_guids() -> Array:
	return _tracked_assets.keys()

func hold_asset(incoming_asset: AssetState) -> void:
	var incoming_guid: String = incoming_asset.get_owner_guid()
	if _held_assets.has(incoming_guid):
		_held_assets[incoming_guid].append(incoming_asset)
	else:
		_held_assets[incoming_guid] = [incoming_asset]

func drop_asset(incoming_guid: String) -> bool:
	if not _held_assets.has(incoming_guid):
		return false
	_held_assets.erase(incoming_guid)
	return true

func drop_all_assets() -> void:
	_held_assets = {}

func get_primary_asset() -> AssetState:
	if _held_assets.is_empty():
		return null
	return _held_assets.values()[0][0]

## If possible moves next index to primary and current primary to end
func switch_primary_asset() -> AssetState:
	if _held_assets.is_empty():
		return null
	var keys: Array = _held_assets.keys()
	var first_key = keys[0]
	var first_value = _held_assets[first_key]
	var new_dict: Dictionary = {}
	for i in range(1, keys.size()):
		new_dict[keys[i]] = _held_assets[keys[i]]
	new_dict[first_key] = first_value
	_held_assets = new_dict
	return _held_assets.values()[0][0]

func get_held_data_for(incoming_guid: String) -> AssetState:
	if not _held_assets.has(incoming_guid):
		return null
	return _held_assets[incoming_guid][0]

func get_held_data() -> Dictionary:
	return _held_assets

func get_owner_guid() -> String:
	if _state_data == null:
		Log.error(Log._CANT_PERFORM, [_STATE_DATA, _GET_OWNER_GUID], self)
		return GroupData.EMPTY
	return _state_data.get_owner_guid()

func get_current_state() -> STATE.ASSET:
	if _state_data == null:
		return STATE.ASSET.UNKNOWN
	return _state_data.get_current_state()

func get_guid_string() -> String:
	# Only cares about null; Dirty state doesn't affect immutable thing like a GUID
	if _guid_string == null:
		_guid_string = get_meta(GroupData.GUID)
	return _guid_string

func get_state_data() -> StateData:
	if _state_data == null:
		_state_data = StateData.new(_guid_string)
	return _state_data

func set_to_state(incoming_state: STATE.ASSET) -> bool:
	if _state_data == null:
		return false
	return _state_data.try_set_state(incoming_state)

func output_warning(incoming_warning: String) -> bool:
	if _state_warnings.has(incoming_warning):
		_state_warnings[incoming_warning] += 1
		return false
	_state_warnings[incoming_warning] = 1
	Log.warn(incoming_warning, [], self)
	return true

func apply_movement(movement_vector: Vector3) -> void:
	if _state_data == null:
		Log.error(Log._CANT_PERFORM, [_STATE_DATA, "Apply Movement"], self)
		return
	_state_data.update_position(movement_vector)

func apply_rotation(euler_rotations: Vector3) -> void:
	var x_rotation_radians: float = deg_to_rad(euler_rotations.x)
	var y_rotation_radians: float = deg_to_rad(euler_rotations.y)
	var z_rotation_radians: float = deg_to_rad(euler_rotations.z)
	var rotation_quaternion: Quaternion = Quaternion.from_euler(Vector3(x_rotation_radians, y_rotation_radians, z_rotation_radians))
	_state_data.update_rotation(rotation_quaternion)

## Attempts to add the guid to the states tracking dictionary; Returns true if succesful false if fails
func track_target_guid(target_guid: String) -> bool:
	# TODO GlobalStateController needs to be refactored to stare and use AssetState
	var target_state: AssetState = GlobalStateController.get_header_data(target_guid, StateHeaders.TYPE.DATA)
	if target_state == null:
		var target_string: String = "State for target GUID \"%s\"" % target_guid
		Log.error(Log._CANT_PERFORM, [target_string, _HANDLE_FOCUS], self)
		return false
	if _tracked_assets.has(target_guid):
		var target_owner_guid: String = target_state.get_owner_guid()
		if target_owner_guid == GroupData.EMPTY:
			# Already should be logged; Can return false
			return false
		var target_guid_assets: Array = _tracked_assets[target_guid]
		var matches: Array = target_guid_assets.filter(
			func(tracked_asset): return tracked_asset.get_owner_guid() == target_owner_guid
		)
		if matches.size() > 1:
			Log.error(_DUPLICATE_TRACKED_STATES, [target_owner_guid], self)
			return false
		var updated_assets: Array = []
		var found_match: bool = false
		for tracked_asset in target_guid_assets:
			if tracked_asset.get_owner_guid() == target_owner_guid:
				updated_assets.append(target_state)
				found_match = true
			else:
				updated_assets.append(tracked_asset)
		if not found_match:
			updated_assets.append(target_state)
		_tracked_assets[target_guid] = updated_assets
		return true
	_tracked_assets[target_guid] = [target_state]
	return true

## Attempts to remove the incoming guid from the tracked dictionary; Returns true if successful false if fails
## Will fail if state is actively tracking the GUID
func stop_tracking(incoming_guid: String) -> bool:
	if _tracked_assets.is_empty() || not _tracked_assets.has(incoming_guid):
		Log.error(_MISSING_TRACK_DATA, [incoming_guid], self)
		return false
	var current_state: STATE.ASSET = _state_data.get_current_state()
	var is_tracking: bool = StateUtil.is_tracking(current_state)
	if is_tracking:
		var tracked_guid: String = _state_data.get_focused_guid()
		if incoming_guid == tracked_guid:
			Log.error(_CURRENTLY_TRACKED, [incoming_guid], self)
			return false
	_tracked_assets.erase(incoming_guid)
	return true

func can_transition(incoming_state: STATE.ASSET) -> bool:
	return _state_data.can_transition(incoming_state)

func perform_action(action_type: GameAction.TYPE, options: Dictionary = {}) -> bool:
	match action_type:
		GameAction.TYPE.TRACK:
			if options.has(StateHeaders.TARGET_GUID):
				return _handle_focus_action(options)
			else:
				var action_string: String = GameAction.get_type_string(action_type)
				Log.error(_BAD_FORMAT, [action_string, 1], self)
		_:
			var action_string: String = GameAction.get_type_string(action_type)
			Log.error(GameAction.UNSUPPORTED, [action_string], self)
	return false

func _handle_focus_action(action_payload: Dictionary) -> bool:
	var target_guid: String = action_payload[StateHeaders.TARGET_GUID]
	var is_target_tracked: bool = track_target_guid(target_guid)
	if not is_target_tracked:
		# Should be logged in track_target_guid already
		return false
	if action_payload.has(STATE.HEADER):
		var new_state_string: String = action_payload[STATE.HEADER]
		var new_state: STATE.ASSET = STATE.get_state_from_string(new_state_string)
		# can_transition within try_set_state should log transition failures
		return _state_data.try_set_state(new_state)
	return true

func _state_data_update(state_update: StateUpdate) -> void:
	if AssetStateInterceptor.convert_detail_values(self, state_update):
		state_data_change.emit(state_update)
