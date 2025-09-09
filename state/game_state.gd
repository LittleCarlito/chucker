# Master container holding player/item dictionaries and current application mode (menu, running, paused)
class_name GameState

signal status_game_change(new_status: STATUS)
signal state_player_change(player_id: String, new_states: Array)
signal state_item_change(item_id: String, new_states: Array)
signal state_input_change(new_state: InputState)
signal state_configuration_change(new_state: ConfigurationState)

enum STATUS {
	MAIN_MENU,
	PAUSE_MENU,
	RUNNING_SCENE,
	UNKNOWN
}

const _MISSING_GUID: String = "Couldn't create %s; Incoming object \"%s\" is missing GUID metadata; Ensure it was created through AssetDelivery"

var _current_game_status: STATUS
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

func register_rig(incoming_rig: CameraRig) -> CameraStateData:
	return self._current_camera_state.register_new_rig(incoming_rig)

func register_player(incoming_player: Node3D) -> StateData:
	var new_state: StateData = self._create_state_data(incoming_player, StateTypes.PLAYER_STATE)
	if new_state:
		self._player_states[incoming_player.get_meta(GroupData.GUID)] = new_state
	# No need to log again that it was not able to create the state so just return (logged in create state already)
	return new_state

func register_asset(incoming_item: Node3D) -> StateData:
	var new_state: StateData = self._create_state_data(incoming_item, StateTypes.ITEM_STATE)
	if new_state:
		self._item_states[incoming_item.get_meta(GroupData.GUID)] = new_state
	return new_state

func _create_state_data(incoming_node: Node3D, incoming_type: String) -> StateData:
	var new_state: StateData = null
	if incoming_node.has_meta(GroupData.GUID):
		new_state = StateData.new(incoming_node.get_meta(GroupData.GUID), incoming_node.name)
	else:
		Logger.error(self._MISSING_GUID, [incoming_type, incoming_node.name], self)
	return new_state

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
	Logger.debug("GameState Status: \"%s\" Players: \"%d\" Items: \"%d\" Camera States: \"%d\"", [_get_status_string(), _player_states.size(), _item_states.size(), _current_camera_state._cameras.size()], self)
	# Print camera state details
	_current_camera_state.print_details()
	# Print player state details
	for player_id in _player_states.keys():
		var state = _player_states[player_id]
		if state.has_method("print_details"):
			state.print_details()
	# Print item state details
	for item_id in _item_states.keys():
		var state = _item_states[item_id]
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
