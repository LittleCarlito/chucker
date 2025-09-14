# Base state structure shared between players, cameras, and items containing position, velocity, and core properties
class_name StateData

var _NO_VALID_TRANSITION: String = "Current item \"%s\" with state \"%s\" does not have valid transition states"
var _INVALID_TRANSITION: String = "Item \"%s\" does not have a valid transition from state \"%s\" to state \"%s\""
var _MAX_VALID_STATE: String = "Item \"%s\" has reached its maximum configured state \"%s\""
var _MIN_VALID_STATE: String = "Item \"%s\" has reached its minimum configured state \"%s\""
var _NO_VALUE: String = "Item \"%s\" does not have a value assoicated to incoming state \"%s\""
var _DECREASING_WINDOW: String = "Item \"%s\" has decreasing window values at state \"%s\": previous value \"%f\" > current value \"%f\""
var _CLOSEST_STATE_NOT_FOUND: String = "Item \"%s\" could not find closest state to value \"%f\" - no state values configured"

const _NAME: String = "[StateData]"
const _GET_STATE_DATA: String = "get_state_data"

signal state_change(new_state: StateData)

var _owner_guid: String
var _owner_name: String
var _owner_type: String
var _current_state: StateConfiguration.STATE
var _current_state_duration: float
var _state_windows: Dictionary
var _valid_transitions: Dictionary
var _state_values: Dictionary # String key, Float value; Whatever data you need to store (as long as its a (String, float))

func _init(incoming_guid: String, incoming_name: String, incoming_windows: Dictionary = {}) -> void:
	self._owner_guid = incoming_guid
	self._owner_name = incoming_name
	self._state_windows = incoming_windows
	_validate_window_configuration()

func reset_state() -> StateConfiguration.STATE:
	var lowest_state: StateConfiguration.STATE = StateConfiguration.STATE.READY
	var found_state: bool = false
	for state in _valid_transitions.keys():
		if not found_state or state < lowest_state:
			lowest_state = state
			found_state = true
	if found_state:
		self._current_state = lowest_state
	else:
		_current_state = StateConfiguration.STATE.READY
	return _current_state

func get_state_data() -> Dictionary:
	return {
		StateHeaders.OWNER_NAME: _owner_name,
		StateHeaders.CURRENT_STATE: _current_state,
		StateHeaders.CURRENT_STATE_DURATION: _current_state_duration,
		StateHeaders.STATE_WINDOWS: _state_windows.duplicate(true),
		StateHeaders.VALID_TRANSITIONS: _valid_transitions.duplicate(true),
		StateHeaders.STATE_VALUES: _state_values.duplicate(true),
	}

func duplicate(deep_clone: bool = false) -> StateData:
	var new_state: StateData = StateData.new(self._owner_guid, self._owner_name, self._state_windows.duplicate(deep_clone))
	new_state._current_state = _current_state
	new_state._current_state_duration = _current_state_duration
	new_state._valid_transitions = _valid_transitions.duplicate(deep_clone)
	new_state._state_values = _state_values.duplicate(deep_clone)
	return new_state

func get_current_state() -> StateConfiguration.STATE:
	return self._current_state

func get_nearest_state(incoming_value: float) -> StateConfiguration.STATE:
	if _state_values.is_empty():
		Logger.warn(_CLOSEST_STATE_NOT_FOUND, [_owner_name, incoming_value], self)
		return StateConfiguration.STATE.READY
	var closest_state: StateConfiguration.STATE = StateConfiguration.STATE.READY
	var closest_distance: float = INF
	var found_state: bool = false
	for state in _state_values.keys():
		var state_value: float = _state_values[state]
		var distance: float = abs(state_value - incoming_value)
		if not found_state or distance < closest_distance:
			closest_distance = distance
			closest_state = state
			found_state = true
	return closest_state

func can_transition(to_state: StateConfiguration.STATE) -> bool:
	if self._valid_transitions.has(self._current_state):
		var current_valid_transitions: Array[StateConfiguration.STATE] = _get_sorted_transitions(_current_state)
		if current_valid_transitions.has(to_state):
			return true
		else:
			Logger.debug(_INVALID_TRANSITION, [self._owner_name, to_state, self._current_state], self)
	else:
		Logger.warn(self._NO_VALID_TRANSITION, [self._owner_name, self._current_state], self)
	return false

func try_set_state(to_state: StateConfiguration.STATE) -> bool:
	if self.can_transition(to_state):
		self._current_state = to_state
		self.state_item_change.emit(self)
		return true
	else:
		return false

func get_all_states() -> Array[StateConfiguration.STATE]:
	var all_states: Array[StateConfiguration.STATE] = []
	for state in _valid_transitions.keys():
		if not all_states.has(state):
			all_states.append(state)
		for transition_state in _valid_transitions[state]:
			if not all_states.has(transition_state):
				all_states.append(transition_state)
	all_states.sort()
	return all_states

func peak_next_state() -> StateConfiguration.STATE:
	var next_state := _find_next_valid_state()
	if next_state == _current_state:
		Logger.debug(self._MAX_VALID_STATE, [_owner_name, _current_state], self)
	return next_state

func peak_next_state_value() -> float:
	var next_state := _find_next_valid_state()
	if next_state == _current_state:
		Logger.debug(self._MAX_VALID_STATE, [_owner_name, _current_state], self)
		return get_state_value(_current_state)
	if _state_values.has(next_state):
		return _state_values[next_state]
	else:
		var next_state_string: String = StateUtil.get_state_string(next_state)
		Logger.warn(self._NO_VALUE, [self._owner_name, next_state_string], self)
		return 0

func next_states() -> Array[StateConfiguration.STATE]:
	return _collect_states(true)

func transition_next_state() -> StateConfiguration.STATE:
	var next_state := _find_next_valid_state()
	if next_state != _current_state:
		_current_state = next_state
		self.state_change.emit(self)
	else:
		Logger.debug(self._MAX_VALID_STATE, [_owner_name, _current_state], self)
	return _current_state

func peak_previous_state() -> StateConfiguration.STATE:
	var prev_state := _find_previous_valid_state()
	if prev_state == _current_state:
		Logger.debug(self._MIN_VALID_STATE, [_owner_name, _current_state], self)
	return prev_state

func previous_states() -> Array[StateConfiguration.STATE]:
	return _collect_states(false)

func transition_previous_state() -> StateConfiguration.STATE:
	var prev_state := _find_previous_valid_state()
	if prev_state != _current_state:
		_current_state = prev_state
		self.state_change.emit(self)
	else:
		Logger.debug(self._MIN_VALID_STATE, [_owner_name, _current_state], self)
	return _current_state

func get_state_value(incoming_value: StateConfiguration.STATE) -> float:
	if self._state_values.has(incoming_value):
		return self._state_values[incoming_value]
	else:
		var incoming_state_string: String = StateUtil.get_state_string(incoming_value)
		Logger.warn(self._NO_VALUE, [self._owner_name, incoming_state_string], self)
		return 0

func is_valid_state(incoming_state: StateConfiguration.STATE) -> bool:
	if _valid_transitions.has(incoming_state):
		return true
	for state_transitions in _valid_transitions.values():
		if state_transitions.has(incoming_state):
			return true
	return false

func print_details() -> void:
	var current_state_name: String = StateUtil.get_state_string(_current_state)
	Logger.debug("StateData \"%s\" CurrentState: \"%s\" StateID: \"%d\" Duration: \"%.2f\" Windows: \"%d\" Transitions: \"%d\" Values: \"%d\"", [_owner_name, current_state_name, _current_state, _current_state_duration, _state_windows.size(), _valid_transitions.size(), _state_values.size()], self)

func as_string() -> String:
	var current_state_name: String = StateUtil.get_state_string(_current_state)
	var details: String = "StateData[%s]: current_state=%s(%d), duration=%.2f" % [_owner_name, current_state_name, _current_state, _current_state_duration]
	details += ", windows=%d, transitions=%d, values=%d" % [_state_windows.size(), _valid_transitions.size(), _state_values.size()]
	return details

func _get_sorted_transitions(state: StateConfiguration.STATE) -> Array[StateConfiguration.STATE]:
	if _valid_transitions.has(state):
		var transitions: Array[StateConfiguration.STATE] = _valid_transitions[state]
		transitions.sort()
		return transitions
	else:
		Logger.warn(_NO_VALID_TRANSITION, [_owner_name, state], self)
		return []

func _collect_states(forward: bool) -> Array[StateConfiguration.STATE]:
	var transitions := _get_sorted_transitions(_current_state)
	var result: Array[StateConfiguration.STATE] = []
	for s in transitions:
		if forward and s > _current_state:
			result.append(s)
		elif not forward and s < _current_state:
			result.append(s)
	return result

func _find_next_valid_state() -> StateConfiguration.STATE:
	var transitions := _get_sorted_transitions(_current_state)
	for s in transitions:
		if s > _current_state:
			return s
	return _current_state

func _find_previous_valid_state() -> StateConfiguration.STATE:
	var transitions := _get_sorted_transitions(_current_state)
	for s in transitions:
		if s < _current_state:
			return s
	return _current_state

func _validate_window_configuration() -> bool:
	if _state_windows.is_empty():
		return true
	var sorted_states: Array = _state_windows.keys()
	sorted_states.sort()
	var previous_value: float = -INF
	for state in sorted_states:
		var current_value: float = _state_windows[state]
		if current_value < previous_value:
			var state_string: String = StateUtil.get_state_string(state)
			Logger.warn(_DECREASING_WINDOW, [_owner_name, state_string, previous_value, current_value], self)
			return false
		previous_value = current_value
	return true
