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

var _current_game_status: STATUS
var _player_states: Dictionary
var _item_states: Dictionary
var _current_input_state: InputState
var _current_configuration_state: ConfigurationState

func _init(incoming_status: STATUS = STATUS.UNKNOWN) -> void:
	self._current_game_status = incoming_status
	self._player_states = {}
	self._item_states = {}
	self._current_input_state = InputState.new()
	self._current_configuration_state = ConfigurationState.new()

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
