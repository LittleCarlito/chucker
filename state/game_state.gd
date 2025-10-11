class_name GameState

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
	_current_game_status = incoming_status
	_player_state = StateDataStorage.new()
	_item_state = StateDataStorage.new()
	_input_state = InputState.new()
	_configuration_state = ConfigurationState.new()
	_camera_state = CameraDataStorage.new()

func register_rig(incoming_rig: Node3D) -> StateData:
	return _camera_state.register_new_node(incoming_rig)

func register_player(incoming_player: Node3D) -> StateData:
	return _player_state.register_new_node(incoming_player)

func register_asset(incoming_item: Node3D) -> StateData:
	return _item_state.register_new_node(incoming_item)

# TODO Add null handling to callers
## Retrieves the state data for the given guid; Error logs if not found and returns null
func retrieve_state_data(incoming_guid: String) -> StateData:
	var data_location: Array[STATE.DATA_TYPE] = _find_in_data(incoming_guid)
	if data_location.is_empty():
		Log.error(_GUID_MISSING_STATE, [incoming_guid], self)
		return null
	if data_location.size() > 1:
		Log.warn(_DUPLICATE_GUID, [data_location], self)
	return _get_from_storage_location(data_location[0], StateHeaders.TYPE.DATA, incoming_guid)

# TODO Add null handling to callers
func retrieve_node(incoming_guid: String) -> Node3D:
	var data_location: Array[STATE.DATA_TYPE] = _find_in_data(incoming_guid)
	if data_location.is_empty():
		Log.error(_GUID_MISSING_STATE, [incoming_guid], self)
		return null
	if data_location.size() > 1:
		Log.warn(_DUPLICATE_GUID, [data_location], self)
	return _get_from_storage_location(data_location[0], StateHeaders.TYPE.NODE, incoming_guid)

func has_guid(incoming_guid: String) -> bool:
	return !_find_in_data(incoming_guid).is_empty()

func get_current_status() -> STATE.GAME:
	return _current_game_status

func get_player_state() -> StateDataStorage:
	return _player_state

func get_item_state() -> StateDataStorage:
	return _item_state

func get_primary_guid(incoming_type: STATE.DATA_TYPE) -> String:
	match incoming_type:
		STATE.DATA_TYPE.PLAYER:
			if _player_state.is_empty:
				Log.error(_EMPTY_DICTIONARY, [_PRIMARY_GUID, _PLAYER_DICTIONARY], self)
				return GroupData.EMPTY
			else:
				var player_keys: Array[String] = _player_state.keys()
				var primary_player_data: StateData = _player_state[player_keys[0]]
				return primary_player_data.get_owner_guid()
		STATE.DATA_TYPE.CAMERA:
			if _camera_state.is_empty():
				Log.error(_EMPTY_DICTIONARY, [_PRIMARY_GUID, _CAMERA_DICTIONARY], self)
				return GroupData.EMPTY
			else:
				var camera_keys: Array = _camera_state.keys()
				var primary_camera_data: AssetState = _camera_state.get_header_data(camera_keys[0], StateHeaders.TYPE.DATA)
				return primary_camera_data.get_owner_guid()
		STATE.DATA_TYPE.ITEM:
			return GroupData.EMPTY
		_:
			var incoming_type_string: String = STATE.get_data_type_string(incoming_type)
			Log.error(_UNSUPPORTED_TYPE, [type_string, incoming_type_string], self)
	return GroupData.EMPTY

func duplicate(deep_clone: bool = false) -> GameState:
	var new_state := GameState.new()
	new_state._current_game_status = _current_game_status
	if deep_clone:
		# Use storage-level duplication (assumes StateDataStorage and CameraDataStorage implement duplicate())
		new_state._player_state = _player_state.duplicate(true)
		new_state._item_state = _item_state.duplicate(true)
		new_state._camera_state = _camera_state.duplicate(true)
		if _input_state != null:
			new_state._input_state = _input_state.duplicate(true)
		if _configuration_state != null:
			new_state._configuration_state = _configuration_state.duplicate(true)
	else:
		# Shallow reference copy
		new_state._player_state = _player_state
		new_state._item_state = _item_state
		new_state._camera_state = _camera_state
		new_state._input_state = _input_state
		new_state._configuration_state = _configuration_state
	return new_state

func _get_status_string() -> String:
	return STATE.get_game_string(_current_game_status)

func _find_in_data(incoming_guid) -> Array[STATE.DATA_TYPE]:
	var return_array: Array[STATE.DATA_TYPE] = []
	var in_player: bool = _player_state.has_guid(incoming_guid)
	if in_player:
		return_array.append(STATE.DATA_TYPE.PLAYER)
	var in_item: bool = _item_state.has_guid(incoming_guid)
	if in_item:
		return_array.append(STATE.DATA_TYPE.ITEM)
	var in_camera: bool = _camera_state.has_guid(incoming_guid)
	if in_camera:
		return_array.append(STATE.DATA_TYPE.CAMERA)
	return return_array

func _get_from_storage_location(incoming_type: STATE.DATA_TYPE, incoming_header: StateHeaders.TYPE, incoming_guid: String):
	var header_string: String = StateHeaders.get_type_string(incoming_header)
	# TODO Shoud do a check on the incoming header type to ensure it is something we store in a state dictionary
	match incoming_type:
		STATE.DATA_TYPE.PLAYER:
			# TODO Make sure this is refined down in state_data_storage for camera and these eventually
			if !_player_state.has_guid(incoming_guid):
				Log.error(_MISSING_DATA, [STATE.DATA_TYPE.PLAYER, StateHeaders.STATE_DICTIONARY, incoming_guid], self)
				return null
			return _player_state.get_header_data(incoming_guid, incoming_header)			
		STATE.DATA_TYPE.ITEM:
			# TODO Make sure this is refined down in state_data_storage for camera and these eventually
			if !_item_state.has_guid(incoming_guid):
				Log.error(_MISSING_DATA, [STATE.DATA_TYPE.PLAYER, StateHeaders.STATE_DICTIONARY, incoming_guid], self)
				return null
			return _item_state.get_header_data(incoming_guid, incoming_header)
		STATE.DATA_TYPE.CAMERA:
			if !_camera_state.has_guid(incoming_guid):
				Log.error(_MISSING_DATA, [STATE.DATA_TYPE.CAMERA, header_string, incoming_guid], self)
				return null
			return _camera_state.get_header_data(incoming_guid, incoming_header)
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
		Log.error(_MISSING_GUID, [incoming_type, incoming_node.name], self)
	return new_state

func _get_node_from_dictionary(state_dictionary: Dictionary) -> Node3D:
	if state_dictionary.has(StateHeaders.STATE_NODE):
		return state_dictionary.get(StateHeaders.STATE_NODE)
	else:
		Log.error(_MISSING_STATE_NODE, [state_dictionary], self)
		return null

func _log_bad_action(incoming_action: GameAction, missing_keys: Array[String]) -> void:
	var missing_string: String = "; ".join(missing_keys)
	Log.error(Log._BAD_ACTION_FORMAT, [incoming_action, missing_string], self)
