extends Resource
class_name AssetState

signal state_data_change(state_update: StateUpdate)

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

func sync_asset() -> void:
	if self._state_data == null:
		Log.error(Log._CANT_PERFORM, [self._STATE_DATA, "Sync Asset"], self)
		return
	if self.owner == null:
		Log.error("Cannot sync asset: owner is null", [], self)
		return
	var current_position: Vector3 = self.owner.global_position
	var current_rotation: Quaternion = Quaternion(self.owner.global_transform.basis)
	var current_scale: Vector3 = self.owner.scale
	self._state_data.update_position(current_position - self._state_data.get_current_position())
	self._state_data.update_rotation(current_rotation * self._state_data.get_current_rotation().inverse())
	self._state_data.update_scale(current_scale / self._state_data.get_current_scale())

func get_min_height() -> float:
	return self._state_data.get_min_height()

func set_min_height(incoming_height: float) -> void:
	self._state_data.set_min_height(incoming_height)

func get_current_rotation() -> Quaternion:
	return self._state_data.get_current_rotation()

func get_current_position() -> Vector3:
	return self._state_data.get_current_position()

func get_current_scale() -> Vector3:
	return self._state_data.get_current_scale()

func is_movement_enabled() -> bool:
	return self._state_data.is_movement_enabled()

func is_sprinting() -> bool:
	return self._state_data.is_sprinting()

func start_sprinting() -> void:
	self._state_data.update_is_sprinting(true)

func stop_sprinting() -> void:
	self._state_data.update_is_sprinting(false)

func get_focused_guid() -> String:
	return self._state_data.get_focused_guid()

## Returns first tracked GUID; Null if none are tracked
func get_first_tracked() -> AssetState:
	if self._tracked_assets == null:
		self._tracked_assets = {}
	return self._tracked_assets.values()[0]

func get_tracked_data_for(incoming_guid: String) -> AssetState:
	if self._tracked_assets == null:
		self._tracked_assets = {}
	return self._tracked_assets.get(incoming_guid)

func get_tracked_guids() -> Array:
	return self._tracked_assets.keys()

func get_owner_guid() -> String:
	if self._state_data == null:
		Log.error(Log._CANT_PERFORM, [self._STATE_DATA, self._GET_OWNER_GUID], self)
		return GroupData.EMPTY
	return self._state_data.get_owner_guid()

func get_current_state() -> STATE.ASSET:
	if self._state_data == null:
		return STATE.ASSET.UNKNOWN
	return self._state_data.get_current_state()

func get_guid_string() -> String:
	# Only cares about null; Dirty state doesn't affect immutable thing like a GUID
	if self._guid_string == null:
		self._guid_string = self.get_meta(GroupData.GUID)
	return self._guid_string

func get_state_data() -> StateData:
	if self._state_data == null:
		var owner_name: String = ""
		if self.owner != null:
			owner_name = self.owner.name
		self._state_data = StateData.new(_guid_string, owner_name)
	return self._state_data

func set_to_state(incoming_state: STATE.ASSET) -> bool:
	if self._state_data == null:
		return false
	return self._state_data.try_set_state(incoming_state)

func output_warning(incoming_warning: String) -> bool:
	if self._state_warnings.has(incoming_warning):
		self._state_warnings[incoming_warning] += 1
		return false
	self._state_warnings[incoming_warning] = 1
	Log.warn(incoming_warning, [], self)
	return true

func apply_movement(movement_vector: Vector3) -> void:
	if self._state_data == null:
		Log.error(Log._CANT_PERFORM, [self._STATE_DATA, "Apply Movement"], self)
		return
	self._state_data.update_position(movement_vector)

func apply_rotation(euler_rotations: Vector3) -> void:
	var x_rotation_radians: float = deg_to_rad(euler_rotations.x)
	var y_rotation_radians: float = deg_to_rad(euler_rotations.y)
	var z_rotation_radians: float = deg_to_rad(euler_rotations.z)
	var rotation_quaternion: Quaternion = Quaternion.from_euler(Vector3(x_rotation_radians, y_rotation_radians, z_rotation_radians))
	self._state_data.update_rotation(rotation_quaternion)

## Attempts to add the guid to the states tracking dictionary; Returns true if succesful false if fails
func track_target_guid(target_guid: String) -> bool:
	# TODO GlobalStateController needs to be refactored to stare and use AssetState
	var target_state: AssetState = GlobalStateController.get_header_data(target_guid, StateHeaders.TYPE.DATA)
	if target_state == null:
		var target_string: String = "State for target GUID \"%s\"" % target_guid
		Log.error(Log._CANT_PERFORM, [target_string, self._HANDLE_FOCUS], self)
		return false
	if self._tracked_assets.has(target_guid):
		var target_owner_guid: String = target_state.get_owner_guid()
		if target_owner_guid == GroupData.EMPTY:
			# Already should be logged; Can return false
			return false
		var target_guid_assets: Array = self._tracked_assets[target_guid]
		var matches: Array = target_guid_assets.filter(
			func(tracked_asset): return tracked_asset.get_owner_guid() == target_owner_guid
		)
		if matches.size() > 1:
			Log.error(self._DUPLICATE_TRACKED_STATES, [target_owner_guid], self)
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
		self._tracked_assets[target_guid] = updated_assets
		return true
	self._tracked_assets[target_guid] = [target_state]
	return true

## Attempts to remove the incoming guid from the tracked dictionary; Returns true if successful false if fails
## Will fail if state is actively tracking the GUID
func stop_tracking(incoming_guid: String) -> bool:
	if self._tracked_assets.is_empty() || not self._tracked_assets.has(incoming_guid):
		Log.error(self._MISSING_TRACK_DATA, [incoming_guid], self)
		return false
	var current_state: STATE.ASSET = self._state_data.get_current_state()
	var is_tracking: bool = StateUtil.is_tracking(current_state)
	if is_tracking:
		var tracked_guid: String = self._state_data.get_focused_guid()
		if incoming_guid == tracked_guid:
			Log.error(self._CURRENTLY_TRACKED, [incoming_guid], self)
			return false
	self._tracked_assets.erase(incoming_guid)
	return true

func can_transition(incoming_state: STATE.ASSET) -> bool:
	return self._state_data.can_transition(incoming_state)

func perform_action(action_type: GameAction.TYPE, options: Dictionary = {}) -> bool:
	match action_type:
		GameAction.TYPE.TRACK:
			if options.has(StateHeaders.TARGET_GUID):
				return self._handle_focus_action(options)
			else:
				var action_string: String = GameAction.get_type_string(action_type)
				Log.error(self._BAD_FORMAT, [action_string, 1], self)
		_:
			var action_string: String = GameAction.get_type_string(action_type)
			Log.error(GameAction.UNSUPPORTED, [action_string], self)
	return false

func _handle_focus_action(action_payload: Dictionary) -> bool:
	var target_guid: String = action_payload[StateHeaders.TARGET_GUID]
	var is_target_tracked: bool = self.track_target_guid(target_guid)
	if not is_target_tracked:
		# Should be logged in track_target_guid already
		return false
	if action_payload.has(STATE.HEADER):
		var new_state_string: String = action_payload[STATE.HEADER]
		var new_state: STATE.ASSET = STATE.get_state_from_string(new_state_string)
		# can_transition within try_set_state should log transition failures
		return self._state_data.try_set_state(new_state)
	return true

func _state_data_update(state_update: StateUpdate) -> void:
	if AssetStateInterceptor.convert_detail_values(self, state_update):
		self.state_data_change.emit(state_update)
