# Master container holding player/item dictionaries and current application mode (menu, running, paused)
class_name GameState

enum STATUS {
	MAIN_MENU,
	PAUSE_MENU,
	RUNNING_SCENE,
	UNKNOWN
}

enum DATA_TYPE {
	PLAYER,
	ITEM,
	CAMERA
}

const _PLAYER: String = "Player"
const _ITEM: String = "Item"
const _CAMERA: String = "Camera"

static func get_data_type_string(incoming_type: DATA_TYPE) -> String:
	match incoming_type:
		DATA_TYPE.PLAYER:
			return _PLAYER
		DATA_TYPE.ITEM:
			return _ITEM
		DATA_TYPE.CAMERA:
			return _CAMERA
		_:
			return GroupData.UNKNOWN

const _MISSING_GUID: String = "Couldn't create %s; Incoming object \"%s\" is missing GUID metadata; Ensure it was created through AssetDelivery"
const _GUID_MISSING_STATE: String = "GUID \"%s\" did not have any data stored in game state; Ensure it was created through Asset Factory/Delivery"
const _MISSING_STATE_NODE: String = "State dictionary is missing associated state node; %s"
const _DUPLICATE_GUID: String = "GUID \"%s\" has been found in too many dictionaries; Location array \"%s\""
const _BAD_ACTION_FORMAT: String = "Incoming action \"%s\" was missing property %s and could not be processed"
const _MISSING_GUID_STATE: String = "GUID \"%s\" state dictionary is missing %s"

const _MISSING_DATA: String = "%s dictionary is missing %s for guid \"%s\""
const _UNSUPPORTED_TYPE: String = "Incoming action type \"%s\" is not supported"
const _EMPTY_DICTIONARY: String = "Cannot retrieve %s because %s is empty"

const _PRIMARY_GUID: String = "Primary GUID"
const _PLAYER_DICTIONARY: String = "Player Dictionary"
const _CAMERA_DICTIONARY: String = "Camera Dictionary"

signal state_updated(update_details: Dictionary)

var _successful_actions: Dictionary
var _flush_scheduled: bool
var _current_game_status: STATUS
var _player_state: StateDataStorage
var _item_state: StateDataStorage
var _input_state: InputState
var _configuration_state: ConfigurationState
var _camera_state: CameraDataStorage

func _init(incoming_status: STATUS = STATUS.UNKNOWN) -> void:
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
func retrieve_state_data(incoming_guid: String) -> StateData:
	var data_location: Array[DATA_TYPE] = self._find_in_data(incoming_guid)
	if data_location.is_empty():
		Logger.error(self._GUID_MISSING_STATE, [incoming_guid], self)
		return null
	if data_location.size() > 1:
		Logger.warn(self._DUPLICATE_GUID, [data_location], self)
	return self._retrieve_from_location(data_location[0], StateHeaders.TYPE.DATA, incoming_guid)

# TODO Add null handling to callers
func retrieve_node(incoming_guid: String) -> Node3D:
	var data_location: Array[DATA_TYPE] = self._find_in_data(incoming_guid)
	if data_location.is_empty():
		Logger.error(self._GUID_MISSING_STATE, [incoming_guid], self)
		return null
	if data_location.size() > 1:
		Logger.warn(self._DUPLICATE_GUID, [data_location], self)
	return self._retrieve_from_location(data_location[0], StateHeaders.TYPE.NODE, incoming_guid)

func has_guid(incoming_guid: String) -> bool:
	return !self._find_in_data(incoming_guid).is_empty()

func get_current_status() -> STATUS:
	return self._current_game_status

func get_player_state() -> StateDataStorage:
	return self._player_state

func get_item_state() -> StateDataStorage:
	return self._item_state

func get_primary_guid(incoming_type: GameState.DATA_TYPE) -> String:
	match incoming_type:
		GameState.DATA_TYPE.PLAYER:
			if self._player_state.is_empty:
				Logger.error(self._EMPTY_DICTIONARY, [self._PRIMARY_GUID, self._PLAYER_DICTIONARY], self)
				return GroupData.EMPTY
			else:
				var player_keys: Array[String] = self._player_state.keys()
				var primary_player_data: StateData = self._player_state[player_keys[0]]
				return primary_player_data.get_owner_guid()
		GameState.DATA_TYPE.CAMERA:
			if self._camera_state.is_empty():
				Logger.error(self._EMPTY_DICTIONARY, [self._PRIMARY_GUID, self._CAMERA_DICTIONARY], self)
				return GroupData.EMPTY
			else:
				var camera_keys: Array = self._camera_state.keys()
				var primary_camera_data: StateData = self._camera_state.get_header_data(camera_keys[0], StateHeaders.TYPE.DATA)
				return primary_camera_data.get_owner_guid()
		GameState.DATA_TYPE.ITEM:
			Logger.error(self._NO_PRIMARY, [], self)
			return GroupData.EMPTY
		_:
			var type_string: String = GameState.get_data_type_string(incoming_type)
			Logger.error(self._UNSUPPORTED_TYPE, [type_string, incoming_type], self)
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
	Logger.debug("GameState Status: \"%s\" Players: \"%d\" Items: \"%d\" Camera States: \"%d\"", [self._get_status_string(), self._player_state.size(), self._item_states.size(), _camera_state.storage_size()], self)
	# Print camera state details
	self._camera_state.print_details()
	self._player_state.print_details()
	self._item_states.print_details()

func _get_status_string() -> String:
	match _current_game_status:
		STATUS.MAIN_MENU:
			return "MAIN_MENU"
		STATUS.PAUSE_MENU:
			return "PAUSE_MENU"
		STATUS.RUNNING_SCENE:
			return "RUNNING_SCENE"
		STATUS.UNKNOWN:
			return "UNKNOWN"
		_:
			return "INVALID"

func _find_in_data(incoming_guid) -> Array[DATA_TYPE]:
	var return_array: Array[DATA_TYPE] = []
	var in_player: bool = self._player_state.has_guid(incoming_guid)
	if in_player:
		return_array.append(DATA_TYPE.PLAYER)
	var in_item: bool = self._item_state.has_guid(incoming_guid)
	if in_item:
		return_array.append(DATA_TYPE.ITEM)
	var in_camera: bool = self._camera_state.has_guid(incoming_guid)
	if in_camera:
		return_array.append(DATA_TYPE.CAMERA)
	return return_array

func _retrieve_from_location(incoming_type: DATA_TYPE, incoming_header: StateHeaders.TYPE, incoming_guid: String):
	var header_string: String = StateHeaders.get_type_string(incoming_header)
	# TODO Shoud do a check on the incoming header type to ensure it is something we store in a state dictionary
	match incoming_type:
		DATA_TYPE.PLAYER:
			# TODO Make sure this is refined down in state_data_storage for camera and these eventually
			if !self._player_state.has_guid(incoming_guid):
				Logger.error(self._MISSING_DATA, [DATA_TYPE.PLAYER, StateHeaders.STATE_DICTIONARY, incoming_guid], self)
				return null
			return self._player_state.get_header_data(incoming_guid, incoming_header)			
		DATA_TYPE.ITEM:
			# TODO Make sure this is refined down in state_data_storage for camera and these eventually
			if !self._item_state.has_guid(incoming_guid):
				Logger.error(self._MISSING_DATA, [DATA_TYPE.PLAYER, StateHeaders.STATE_DICTIONARY, incoming_guid], self)
				return null
			return self._item_state.get_header_data(incoming_guid, incoming_header)
		DATA_TYPE.CAMERA:
			if !self._camera_state.has_guid(incoming_guid):
				Logger.error(self._MISSING_DATA, [DATA_TYPE.CAMERA, header_string, incoming_guid], self)
				return null
			return self._camera_state.get_header_data(incoming_guid, incoming_header)
		_:
			var type_string: String = self.get_data_type_string(incoming_type)
			Logger.error("Incoming type \"%s\" is not supported", [type_string], self)
			return null

func _create_state_data(incoming_node: Node3D, incoming_type: String) -> StateData:
	var new_state: StateData = null
	if incoming_node.has_meta(GroupData.GUID):
		new_state = StateData.new(incoming_node.get_meta(GroupData.GUID), incoming_node.name)
	else:
		Logger.error(self._MISSING_GUID, [incoming_type, incoming_node.name], self)
	return new_state

func _get_node_from_dictionary(state_dictionary: Dictionary) -> Node3D:
	if state_dictionary.has(StateHeaders.STATE_NODE):
		return state_dictionary.get(StateHeaders.STATE_NODE)
	else:
		Logger.error(self._MISSING_STATE_NODE, [state_dictionary], self)
		return null

func _handle_action(incoming_action: GameAction) -> void:
	match incoming_action.action_type:
		GameAction.TYPE.SET_RIG_FOCUS:
			self._handle_rig_focus_action(incoming_action)
		GameAction.TYPE.FOCUS_RIG:
			self._handle_focus_action(incoming_action)
		GameAction.TYPE.WARN:
			self._handle_warn_action(incoming_action)
		_:
			var type_string: String = GameAction.get_type_string(incoming_action.action_type)
			Logger.error(self._UNSUPPORTED_TYPE, [type_string], self)
	self._schedule_state_update(incoming_action)

func _handle_focus_action(incoming_action: GameAction) -> void:
	if incoming_action.payload.has(GameAction.OWNER_GUID):
		if incoming_action.payload.has(GameAction.FOCUS_RIG):
			var camera_guid: String = incoming_action.payload.get(GameAction.OWNER_GUID)
			var focus_value: bool = incoming_action.payload.get(GameAction.FOCUS_RIG)
			var rig_state_data: CameraStateData = self._camera_state.get_header_data(camera_guid, StateHeaders.TYPE.DATA)
			rig_state_data.set_is_focused(focus_value)
		else:
			Logger.error(self._BAD_ACTION_FORMAT, [incoming_action, GameAction.FOCUS_RIG], self)
	else:
		Logger.error(self._BAD_ACTION_FORMAT, [incoming_action, GameAction.OWNER_GUID], self)

func _handle_rig_focus_action(incoming_action: GameAction) -> void:
	var missing_keys := self._get_missing_keys(incoming_action.payload, [GameAction.OWNER_GUID, GameAction.TARGET_GUID])
	if missing_keys.is_empty():
		_camera_state.set_camera_focus(
			incoming_action.payload[GameAction.OWNER_GUID],
			incoming_action.payload[GameAction.TARGET_GUID]
			)
	else:
		Logger.error(_BAD_ACTION_FORMAT, [incoming_action, missing_keys], self)

func _handle_warn_action(incoming_action: GameAction) -> void:
	var missing_keys := self._get_missing_keys(incoming_action.payload, [GameAction.OWNER_GUID, GameAction.MESSAGE])
	if missing_keys.is_empty():
		var incoming_guid: String = incoming_action.payload[GameAction.OWNER_GUID]
		var incoming_message: String = incoming_action.payload[GameAction.MESSAGE]
		var guid_state_data: StateData = self.retrieve_state_data(incoming_guid)
		guid_state_data.log(incoming_message, Logger.LEVEL.WARN)
	else:
		Logger.error(_BAD_ACTION_FORMAT, [incoming_action, missing_keys], self)

# Shared helper
func _get_missing_keys(payload: Dictionary, required_keys: Array[String]) -> String:
	var missing: Array[String] = []
	for key in required_keys:
		if not payload.has(key):
			missing.append(key)
	return "; ".join(missing)

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
