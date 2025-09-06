extends StateData
class_name GameState

signal status_game_change(new_status: STATUS)
signal state_instance_change(new_state: InstanceState)
signal state_input_change(new_state: InputState)
signal state_configuration_change(new_state: ConfigurationState)

enum STATUS {
	MAIN_MENU,
	PAUSE_MENU,
	RUNNING_SCENE,
	UNKNOWN
}

var _current_game_status: STATUS
var _current_instance_state: InstanceState
var _current_input_state: InputState
var _current_configuration_state: ConfigurationState

func _init(incoming_status: STATUS = STATUS.UNKNOWN) -> void:
	self._current_game_status = incoming_status
	self._current_instance_state = InstanceState.new()
	self._current_input_state = InputState.new()
	self._current_configuration_state = ConfigurationState.new()

func get_current_status() -> STATUS:
	return self._current_game_status

func get_state_data() -> Dictionary:
	var state_data = {}
	state_data[StateTypes.GAME_STATUS] = self._current_game_status
	if self._current_instance_state != null:
		state_data[StateTypes.INSTANCE_STATE] = self._current_instance_state.get_state_data()
	if self._current_input_state != null:
		state_data[StateTypes.INPUT_STATE] = self._current_input_state.get_state_data()
	if self._current_configuration_state != null:
		state_data[StateTypes.CONFIGURATION_STATE] = self._current_configuration_state.get_state_data()
	return state_data

func duplicate(deep_clone: bool = false) -> GameState:
	var new_state = GameState.new()
	new_state._current_game_status = self._current_game_status
	if deep_clone:
		if self._current_instance_state != null:
			new_state._current_instance_state = self._current_instance_state.duplicate()
		if self._current_input_state != null:
			new_state._current_input_state = self._current_input_state.duplicate()
		if self._current_configuration_state != null:
			new_state._current_configuration_state = self._current_configuration_state.duplicate()
	else:
		new_state._current_instance_state = self._current_instance_state
		new_state._current_input_state = self._current_input_state
		new_state._current_configuration_state = self._current_configuration_state
	return new_state
