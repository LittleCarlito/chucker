# Master container holding player/item dictionaries and current application mode (menu, running, paused)
class_name GameState

signal state_updated(update_details: Dictionary)

const _MISSING_GUID: String = "Couldn't create %s; Incoming object \"%s\" is missing GUID metadata; Ensure it was created through AssetDelivery"
const _GUID_MISSING_STATE: String = "GUID \"%s\" did not have any data stored in game state; Ensure it was created through Asset Factory/Delivery"
const _MISSING_STATE_NODE: String = "State dictionary is missing associated state node; %s"
const _DUPLICATE_GUID: String = "GUID \"%s\" has been found in too many dictionaries; Location array \"%s\""
const _MISSING_GUID_STATE: String = "GUID \"%s\" state dictionary is missing %s"

const _MISSING_DATA: String = "%s dictionary is missing %s for guid \"%s\""
const _UNSUPPORTED_TYPE: String = "Incoming action type \"%s\" is not supported"
const _EMPTY_DICTIONARY: String = "Cannot retrieve %s because %s is empty"

const _PRIMARY_GUID: String = "Primary GUID"
const _PLAYER_DICTIONARY: String = "Player Dictionary"
const _CAMERA_DICTIONARY: String = "Camera Dictionary"

var _successful_actions: Dictionary
var _flush_scheduled: bool
var _current_game_status: STATE.GAME
var _player_state: StateDataStorage
var _item_state: StateDataStorage
var _input_state: InputState
var _configuration_state: ConfigurationState
var _camera_state: CameraDataStorage

func _init(incoming_status: STATE.GAME = STATE.GAME.UNKNOWN) -> void:
	self._current_game_status = incoming_status
	self._player_state = StateDataStorage.new()
	self._item_state = StateDataStorage.new()
	self._input_state = InputState.new()
	self._configuration_state = ConfigurationState.new()
	self._camera_state = CameraDataStorage.new()

func register_rig(incoming_rig: Node3D) -> StateData:
	return self._camera_state.register_new_node(incoming_rig)

func register_player(incoming_player: Node3D) -> StateData:
	return self._player_state.register_new_node(incoming_player)

func register_asset(incoming_item: Node3D) -> StateData:
	return self._item_state.register_new_node(incoming_item)

# TODO Add null handling to callers
## Retrieves the state data for the given guid; Error logs if not found and returns null
func retrieve_state_data(incoming_guid: String) -> StateData:
	var data_location: Array[STATE.DATA_TYPE] = self._find_in_data(incoming_guid)
	if data_location.is_empty():
		Log.error(self._GUID_MISSING_STATE, [incoming_guid], self)
		return null
	if data_location.size() > 1:
		Log.warn(self._DUPLICATE_GUID, [data_location], self)
	return self._get_from_storage_location(data_location[0], StateHeaders.TYPE.DATA, incoming_guid)

# TODO Add null handling to callers
func retrieve_node(incoming_guid: String) -> Node3D:
	var data_location: Array[STATE.DATA_TYPE] = self._find_in_data(incoming_guid)
	if data_location.is_empty():
		Log.error(self._GUID_MISSING_STATE, [incoming_guid], self)
		return null
	if data_location.size() > 1:
		Log.warn(self._DUPLICATE_GUID, [data_location], self)
	return self._get_from_storage_location(data_location[0], StateHeaders.TYPE.NODE, incoming_guid)

func has_guid(incoming_guid: String) -> bool:
	return !self._find_in_data(incoming_guid).is_empty()

func get_current_status() -> STATE.GAME:
	return self._current_game_status

func get_player_state() -> StateDataStorage:
	return self._player_state

func get_item_state() -> StateDataStorage:
	return self._item_state

func get_primary_guid(incoming_type: STATE.DATA_TYPE) -> String:
	match incoming_type:
		STATE.DATA_TYPE.PLAYER:
			if self._player_state.is_empty:
				Log.error(self._EMPTY_DICTIONARY, [self._PRIMARY_GUID, self._PLAYER_DICTIONARY], self)
				return GroupData.EMPTY
			else:
				var player_keys: Array[String] = self._player_state.keys()
				var primary_player_data: StateData = self._player_state[player_keys[0]]
				return primary_player_data.get_owner_guid()
		STATE.DATA_TYPE.CAMERA:
			if self._camera_state.is_empty():
				Log.error(self._EMPTY_DICTIONARY, [self._PRIMARY_GUID, self._CAMERA_DICTIONARY], self)
				return GroupData.EMPTY
			else:
				var camera_keys: Array = self._camera_state.keys()
				var primary_camera_data: StateData = self._camera_state.get_header_data(camera_keys[0], StateHeaders.TYPE.DATA)
				return primary_camera_data.get_owner_guid()
		STATE.DATA_TYPE.ITEM:
			Log.error(self._NO_PRIMARY, [], self)
			return GroupData.EMPTY
		_:
			var incoming_type_string: String = STATE.get_data_type_string(incoming_type)
			Log.error(self._UNSUPPORTED_TYPE, [type_string, incoming_type_string], self)
	return GroupData.EMPTY

func duplicate(deep_clone: bool = false) -> GameState:
	var new_state := GameState.new()
	new_state._current_game_status = self._current_game_status
	if deep_clone:
		# Use storage-level duplication (assumes StateDataStorage and CameraDataStorage implement duplicate())
		new_state._player_state = self._player_state.duplicate(true)
		new_state._item_state = self._item_state.duplicate(true)
		new_state._camera_state = self._camera_state.duplicate(true)
		if self._input_state != null:
			new_state._input_state = self._input_state.duplicate(true)
		if self._configuration_state != null:
			new_state._configuration_state = self._configuration_state.duplicate(true)
	else:
		# Shallow reference copy
		new_state._player_state = self._player_state
		new_state._item_state = self._item_state
		new_state._camera_state = self._camera_state
		new_state._input_state = self._input_state
		new_state._configuration_state = self._configuration_state
	return new_state

func print_details() -> void:
	Log.debug("GameState Status: \"%s\" Players: \"%d\" Items: \"%d\" Camera States: \"%d\"", [self._get_status_string(), self._player_state.size(), self._item_states.size(), _camera_state.storage_size()], self)
	# Print camera state details
	self._camera_state.print_details()
	self._player_state.print_details()
	self._item_states.print_details()

func _get_status_string() -> String:
	return STATE.get_game_string(self._current_game_status)

func _find_in_data(incoming_guid) -> Array[STATE.DATA_TYPE]:
	var return_array: Array[STATE.DATA_TYPE] = []
	var in_player: bool = self._player_state.has_guid(incoming_guid)
	if in_player:
		return_array.append(STATE.DATA_TYPE.PLAYER)
	var in_item: bool = self._item_state.has_guid(incoming_guid)
	if in_item:
		return_array.append(STATE.DATA_TYPE.ITEM)
	var in_camera: bool = self._camera_state.has_guid(incoming_guid)
	if in_camera:
		return_array.append(STATE.DATA_TYPE.CAMERA)
	return return_array

func _get_from_storage_location(incoming_type: STATE.DATA_TYPE, incoming_header: StateHeaders.TYPE, incoming_guid: String):
	var header_string: String = StateHeaders.get_type_string(incoming_header)
	# TODO Shoud do a check on the incoming header type to ensure it is something we store in a state dictionary
	match incoming_type:
		STATE.DATA_TYPE.PLAYER:
			# TODO Make sure this is refined down in state_data_storage for camera and these eventually
			if !self._player_state.has_guid(incoming_guid):
				Log.error(self._MISSING_DATA, [STATE.DATA_TYPE.PLAYER, StateHeaders.STATE_DICTIONARY, incoming_guid], self)
				return null
			return self._player_state.get_header_data(incoming_guid, incoming_header)			
		STATE.DATA_TYPE.ITEM:
			# TODO Make sure this is refined down in state_data_storage for camera and these eventually
			if !self._item_state.has_guid(incoming_guid):
				Log.error(self._MISSING_DATA, [STATE.DATA_TYPE.PLAYER, StateHeaders.STATE_DICTIONARY, incoming_guid], self)
				return null
			return self._item_state.get_header_data(incoming_guid, incoming_header)
		STATE.DATA_TYPE.CAMERA:
			if !self._camera_state.has_guid(incoming_guid):
				Log.error(self._MISSING_DATA, [STATE.DATA_TYPE.CAMERA, header_string, incoming_guid], self)
				return null
			return self._camera_state.get_header_data(incoming_guid, incoming_header)
		_:
			var incoming_type_string: String = STATE.get_data_type_string(incoming_type)
			# TODO Get to a string constant
			Log.error("Incoming type \"%s\" is not supported", [incoming_type_string], self)
			return null

func _create_state_data(incoming_node: Node3D, incoming_type: String) -> StateData:
	var new_state: StateData = null
	if incoming_node.has_meta(GroupData.GUID):
		new_state = StateData.new(incoming_node.get_meta(GroupData.GUID))
	else:
		Log.error(self._MISSING_GUID, [incoming_type, incoming_node.name], self)
	return new_state

func _get_node_from_dictionary(state_dictionary: Dictionary) -> Node3D:
	if state_dictionary.has(StateHeaders.STATE_NODE):
		return state_dictionary.get(StateHeaders.STATE_NODE)
	else:
		Log.error(self._MISSING_STATE_NODE, [state_dictionary], self)
		return null

func _log_bad_action(incoming_action: GameAction, missing_keys: Array[String]) -> void:
	var missing_string: String = "; ".join(missing_keys)
	Log.error(Log._BAD_ACTION_FORMAT, [incoming_action, missing_string], self)

# Shared helper
func _schedule_state_update(successful_action: GameAction) -> void:
	var action_owner_guid: String = successful_action.payload.get(GameAction.OWNER_GUID)
	self._successful_actions[action_owner_guid] = successful_action
	if !self._flush_scheduled:
		self._flush_scheduled = true
		call_deferred("_flush_state_updates")

func _flush_state_updates() -> void:
	if self._successful_actions.is_empty():
		self._flush_scheduled = false
		return
	self.state_updated.emit(self._successful_actions)
	self._successful_actions.clear()
	self._flush_scheduled = false
