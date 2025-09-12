# Master container holding player/item dictionaries and current application mode (menu, running, paused)
class_name GameState

enum STATUS {
	MAIN_MENU,
	PAUSE_MENU,
	RUNNING_SCENE,
	UNKNOWN
}

const _MISSING_GUID: String = "Couldn't create %s; Incoming object \"%s\" is missing GUID metadata; Ensure it was created through AssetDelivery"
const _GUID_MISSING_STATE: String = "GUID \"%s\" did not have any data stored in game state; Ensure it was created through Asset Factory/Delivery"
const _MISSING_STATE_NODE: String = "State dictionary is missing associated state node; %s"
const _DUPLICATE_GUID: String = "GUID \"%s\" has been found in both player and item state Dictionaries"
const _BAD_ACTION_FORMAT: String = "Incoming action \"%s\" was missing property %s and could not be processed"
const _MISSING_GUID_STATE: String = "GUID \"%s\" state dictionary is missing %s"

# TODO OOOOOO YOU WERE HERE
#		Get all the Actions that went off succesfully into update details and just send that shit out
signal state_updated(update_details: Dictionary)

var _successful_actions: Dictionary
var _flush_scheduled: bool
var _current_game_status: STATUS
# TODO Make a generalized parent state type class that holds the dictionary
#			Is the CameraState class just changed into a generalized form
#			Then should be able to use that same object for player item and camera states
#			There should be a Player Item and Camera one that extend each with the functions to get/deal with the dictioanry by type
#				This will also be where headers/constants are stored for each type
var _player_states: Dictionary
var _item_states: Dictionary
var _current_input_state: InputState
var _current_configuration_state: ConfigurationState
var _current_camera_state: CameraState

func _init(incoming_status: STATUS = STATUS.UNKNOWN) -> void:
	self._current_game_status = incoming_status
	self._player_states = {}
	self._item_states = {}
	self._current_input_state = InputState.new()
	self._current_configuration_state = ConfigurationState.new()
	self._current_camera_state = CameraState.new()

func register_rig(incoming_rig: Node3D) -> StateData:
	return self._current_camera_state.register_new_node(incoming_rig)

func register_player(incoming_player: Node3D) -> StateData:
	var new_state: StateData = self._create_state_data(incoming_player, StateTypes.PLAYER_STATE)
	if new_state:
		self._player_states[incoming_player.get_meta(GroupData.GUID)] = {
			StateHeaders.STATE_DATA: new_state,
			StateHeaders.STATE_NODE: incoming_player
		}
	# No need to log again that it was not able to create the state so just return (logged in create state already)
	return new_state

func register_asset(incoming_item: Node3D) -> StateData:
	var new_state: StateData = self._create_state_data(incoming_item, StateTypes.ITEM_STATE)
	if new_state:
		self._item_states[incoming_item.get_meta(GroupData.GUID)] = {
			StateHeaders.STATE_DATA: new_state,
			StateHeaders.STATE_NODE: incoming_item
		}
	return new_state

func retrieve_node(incoming_guid: String) -> Node3D:
	var in_player: bool = self._player_states.has(incoming_guid)
	var in_item: bool = self._item_states.has(incoming_guid)
	if in_player or in_item:
		if in_player and in_item:
			Logger.error(self._DUPLICATE_GUID, [], self)
			return null
		else:
			if in_player:
				return self._get_node_from_dictionary(self._player_states.get(incoming_guid))
			return self._get_node_from_dictionary(self._item_states.get(incoming_guid))
	else:
		Logger.error(self._GUID_MISSING_STATE, [incoming_guid], self)
		return null

func has_guid(incoming_guid: String) -> bool:
	var in_player: bool = self._player_states.has(incoming_guid)
	var in_item: bool = self._item_states.has(incoming_guid)
	if in_player or in_item:
		if in_player and in_item:
			Logger.warn(self._DUPLICATE_GUID, [], self)
		return true
	else:
		return false

func get_current_status() -> STATUS:
	return self._current_game_status

func get_player_states() -> Dictionary:
	return self._player_states

func get_item_states() -> Dictionary:
	return self._item_states

func get_state_data() -> Dictionary:
	var state_data = {}
	state_data[StateTypes.GAME_STATUS] = self._current_game_status
	state_data[StateTypes.PLAYER_STATE] = self._player_states.duplicate(true)
	state_data[StateTypes.ITEM_STATE] = self._item_states.duplicate(true)
	if self._current_input_state != null:
		state_data[StateTypes.INPUT_STATE] = self._current_input_state.get_state_data()
	if self._current_configuration_state != null:
		state_data[StateTypes.CONFIGURATION_STATE] = self._current_configuration_state.get_state_data()
	return state_data

func duplicate(deep_clone: bool = false) -> GameState:
	var new_state = GameState.new()
	new_state._current_game_status = self._current_game_status
	if deep_clone:
		for player_id in self._player_states.keys():
			new_state._player_states[player_id] = []
			for state in self._player_states[player_id]:
				new_state._player_states[player_id].append(state.duplicate())
		for item_id in self._item_states.keys():
			new_state._item_states[item_id] = []
			for state in self._item_states[item_id]:
				new_state._item_states[item_id].append(state.duplicate())
		if self._current_input_state != null:
			new_state._current_input_state = self._current_input_state.duplicate()
		if self._current_configuration_state != null:
			new_state._current_configuration_state = self._current_configuration_state.duplicate()
	else:
		new_state._player_states = self._player_states
		new_state._item_states = self._item_states
		new_state._current_input_state = self._current_input_state
		new_state._current_configuration_state = self._current_configuration_state
	return new_state

func print_details() -> void:
	Logger.debug("GameState Status: \"%s\" Players: \"%d\" Items: \"%d\" Camera States: \"%d\"", [self._get_status_string(), self._player_states.size(), self._item_states.size(), _current_camera_state.storage_size()], self)
	# Print camera state details
	self._current_camera_state.print_details()
	# Print player state details
	for player_id in _player_states.keys():
		var state: StateData = _player_states[player_id]
		if state.has_method("print_details"):
			state.print_details()
	# Print item state details
	for item_id in self._item_states.keys():
		var state: StateData = self._item_states[item_id]
		if state.has_method("print_details"):
			state.print_details()

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
		_:
			pass
	self._schedule_state_update(incoming_action)

func _handle_focus_action(incoming_action: GameAction) -> void:
	if incoming_action.payload.has(GameAction.OWNER_GUID):
		if incoming_action.payload.has(GameAction.FOCUS_RIG):
			var camera_guid: String = incoming_action.payload.get(GameAction.OWNER_GUID)
			var focus_value: bool = incoming_action.payload.get(GameAction.FOCUS_RIG)
			# TODO Get the camera by guid and set its focus state value to the given variable value

		else:
			Logger.error(self._BAD_ACTION_FORMAT, [incoming_action, GameAction.FOCUS_RIG], self)
	else:
		Logger.error(self._BAD_ACTION_FORMAT, [incoming_action, GameAction.OWNER_GUID], self)

func _handle_rig_focus_action(incoming_action: GameAction) -> void:
	var has_camera_guid: bool = incoming_action.payload.has(GameAction.OWNER_GUID)
	var has_focus_guid: bool = incoming_action.payload.has(GameAction.TARGET_GUID)
	if has_camera_guid and has_focus_guid:
		self._current_camera_state.set_camera_focus(incoming_action.payload.get(GameAction.OWNER_GUID), incoming_action.payload.get(GameAction.TARGET_GUID))
	else:
		var missing_variable: String = GameAction.OWNER_GUID if !has_camera_guid else ""
		if missing_variable != "":
			missing_variable += "; "
		missing_variable += GameAction.TARGET_GUID if !has_focus_guid else ""
		Logger.error(self._BAD_ACTION_FORMAT, [incoming_action, missing_variable], self)

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
