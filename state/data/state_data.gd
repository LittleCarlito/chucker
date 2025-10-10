# Base state structure shared between players, cameras, and items containing position, velocity, and core properties
extends Node
class_name StateData

signal state_data_change(state_update: StateUpdate)

var _NO_VALID_TRANSITION: String = "Current item \"%s\" with state \"%s\" does not have valid transition states"
var _INVALID_TRANSITION: String = "Item \"%s\" does not have a valid transition from state \"%s\" to state \"%s\""
var _MAX_VALID_STATE: String = "Item \"%s\" has reached its maximum configured state \"%s\""
var _MIN_VALID_STATE: String = "Item \"%s\" has reached its minimum configured state \"%s\""
var _NO_VALUE: String = "Item \"%s\" does not have a value assoicated to incoming state \"%s\""
var _DECREASING_WINDOW: String = "Item \"%s\" has decreasing window values at state \"%s\": previous value \"%f\" > current value \"%f\""
var _CLOSEST_STATE_NOT_FOUND: String = "Item \"%s\" could not find closest state to value \"%f\" - no state values configured"
const _UNSUPPORTED_TYPE: String = "Incoming %s type \"%s\" is not supported; %s"

const _NAME: String = "[StateData]"
const _GET_STATE_DATA: String = "get_state_data"
const _STATE_IDENTIFIER: String = "_state"
const _MOVEMENT_ENABLED: String = "movement_enabled"

var _owner_guid: String
var _current_state: STATE.ASSET
var _current_state_duration: float
# Scene based details
var _min_height: float = -NUMBERS.FLOAT16_MAX
var _owner_rotation: Quaternion
var _owner_position: Vector3
var _owner_scale: Vector3
var _focused_guid: String
var _movement_enabled: bool
var _is_sprinting: bool
var _is_crouching: bool
# State data dictionaries
var _valid_transitions: Dictionary
var _state_values: Dictionary # String key, Float value; Whatever data you need to store (as long as its a (String, float))
var _state_windows: Dictionary

func _init(
			incoming_guid: String, 
			incoming_transitions: Dictionary = {}, 
			incoming_values: Dictionary = {},
			incoming_windows: Dictionary = {}
			) -> void:
	_owner_guid = incoming_guid
	name = _owner_guid + _STATE_IDENTIFIER
	_valid_transitions = incoming_transitions
	_state_values = incoming_values
	if _validate_window_configuration(incoming_windows):
		_state_windows = incoming_windows

# TODO Refactor this
#		Should ahve a "deafult" state configured for the state data
#			That is what we should snap to
func reset_state() -> STATE.ASSET:
	var previous_state: STATE.ASSET = get_current_state()
	var lowest_state: STATE.ASSET = STATE.ASSET.READY
	var found_state: bool = false
	for state in _valid_transitions.keys():
		if not found_state or state < lowest_state:
			lowest_state = state
			found_state = true
	if found_state:
		_current_state = lowest_state
	else:
		_current_state = STATE.ASSET.READY
	var set_state: STATE.ASSET = _current_state
	var update_details: Dictionary = {
		StateHeaders.PREVIOUS_STATE: previous_state,
		StateHeaders.CURRENT_STATE: set_state
	}
	state_data_change.emit(StateUpdate.new(STATE.UPDATE_TYPE.STATE, update_details))
	return _current_state

func get_state_data() -> Dictionary:
	return {
		StateHeaders.OWNER_GUID: _owner_guid,
		StateHeaders.CURRENT_STATE: _current_state,
		StateHeaders.CURRENT_STATE_DURATION: _current_state_duration,
		StateHeaders.STATE_WINDOWS: _state_windows.duplicate(true),
		StateHeaders.VALID_TRANSITIONS: _valid_transitions.duplicate(true),
		StateHeaders.STATE_VALUES: _state_values.duplicate(true),
	}

func get_current_state() -> STATE.ASSET:
	return _current_state

func get_nearest_state(incoming_value: float) -> STATE.ASSET:
	if _state_values.is_empty():
		Log.warn(_CLOSEST_STATE_NOT_FOUND, [_owner_guid, incoming_value], self)
		return STATE.ASSET.READY
	var closest_state: STATE.ASSET = STATE.ASSET.READY
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

func can_transition(to_state: STATE.ASSET) -> bool:
	if _valid_transitions.has(_current_state):
		var current_valid_transitions: Array = _get_sorted_transitions(_current_state)
		if current_valid_transitions.has(to_state):
			return true
		else:
			var to_state_string: String = STATE.get_state_string(to_state)
			var current_state_string: String = STATE.get_state_string(_current_state)
			Log.warn(_INVALID_TRANSITION, [_owner_guid, to_state_string, current_state_string], self)
	else:
		Log.error(_NO_VALID_TRANSITION, [_owner_guid, _current_state], self)
	return false

func try_set_state(to_state: STATE.ASSET) -> bool:
	if can_transition(to_state):
		var previous_state: STATE.ASSET = _current_state
		_current_state = to_state
		var new_state: STATE.ASSET = _current_state
		var update_details: Dictionary = {
			StateHeaders.PREVIOUS_STATE: previous_state,
			StateHeaders.CURRENT_STATE: new_state
		}
		state_data_change.emit(StateUpdate.new(STATE.UPDATE_TYPE.STATE, update_details))
		return true
	else:
		return false

func get_all_states() -> Array[STATE.ASSET]:
	var all_states: Array[STATE.ASSET] = []
	for state in _valid_transitions.keys():
		if not all_states.has(state):
			all_states.append(state)
		for transition_state in _valid_transitions[state]:
			if not all_states.has(transition_state):
				all_states.append(transition_state)
	all_states.sort()
	return all_states

func peak_next_state() -> STATE.ASSET:
	var next_state := _find_next_valid_state()
	if next_state == _current_state:
		Log.debug(_MAX_VALID_STATE, [_owner_guid, _current_state], self)
	return next_state

func peak_next_state_value() -> float:
	var next_state := _find_next_valid_state()
	if next_state == _current_state:
		Log.debug(_MAX_VALID_STATE, [_owner_guid, _current_state], self)
		return get_state_value(_current_state)
	if _state_values.has(next_state):
		return _state_values[next_state]
	else:
		var next_state_string: String = STATE.get_state_string(next_state)
		Log.warn(_NO_VALUE, [_owner_guid, next_state_string], self)
		return 0

func next_states() -> Array[STATE.ASSET]:
	return _collect_states(true)

func transition_next_state() -> STATE.ASSET:
	var next_state := _find_next_valid_state()
	if next_state != _current_state:
		var previous_state: STATE.ASSET = _current_state
		_current_state = next_state
		var new_state: STATE.ASSET = _current_state
		var update_details: Dictionary = {
			StateHeaders.PREVIOUS_STATE: previous_state,
			StateHeaders. CURRENT_STATE: new_state
		}
		state_data_change.emit(StateUpdate.new(STATE.UPDATE_TYPE.STATE, update_details))
	else:
		Log.debug(_MAX_VALID_STATE, [_owner_guid, _current_state], self)
	return _current_state

func peak_previous_state() -> STATE.ASSET:
	var prev_state := _find_previous_valid_state()
	if prev_state == _current_state:
		Log.debug(_MIN_VALID_STATE, [_owner_guid, _current_state], self)
	return prev_state

func previous_states() -> Array[STATE.ASSET]:
	return _collect_states(false)

func transition_previous_state() -> STATE.ASSET:
	var prev_state := _find_previous_valid_state()
	if prev_state != _current_state:
		var previous_state: STATE.ASSET = _current_state
		_current_state = prev_state
		var new_state: STATE.ASSET = _current_state
		var update_details: Dictionary = {
			StateHeaders.PREVIOUS_STATE: previous_state,
			StateHeaders.CURRENT_STATE: new_state
		}
		state_data_change.emit(StateUpdate.new(STATE.UPDATE_TYPE.STATE, update_details))
	else:
		Log.debug(_MIN_VALID_STATE, [_owner_guid, _current_state], self)
	return _current_state

func get_state_value(incoming_value: STATE.ASSET) -> float:
	if _state_values.has(incoming_value):
		return _state_values[incoming_value]
	else:
		var incoming_state_string: String = STATE.get_state_string(incoming_value)
		Log.warn(_NO_VALUE, [_owner_guid, incoming_state_string], self)
		return 0

func set_focused_guid(incoming_guid: String) -> void:
	_focused_guid = incoming_guid
	var update_details: Dictionary = {
		StateHeaders.TARGET_GUID: _focused_guid
	}
	state_data_change.emit(StateUpdate.new(STATE.UPDATE_TYPE.FOCUS, update_details))

func get_focused_guid() -> String:
	return _focused_guid

func is_focused() -> bool:
	return _focused_guid != null and !_focused_guid.strip_edges().is_empty()

func get_min_height() -> float:
	return _min_height

func set_min_height(incoming_height: float) -> void:
	_min_height = incoming_height

func update_rotation(incoming_quaternion: Quaternion) -> void:
	_owner_rotation *= incoming_quaternion
	var update_details: Dictionary = {
		StateHeaders.ROTATION: incoming_quaternion
	}
	state_data_change.emit(StateUpdate.new(STATE.UPDATE_TYPE.ROTATION, update_details))

func update_position(incoming_vector: Vector3) -> void:
	_owner_position += incoming_vector
	var update_details: Dictionary = {
		StateHeaders.POSITION: incoming_vector
	}
	state_data_change.emit(StateUpdate.new(STATE.UPDATE_TYPE.POSITION, update_details))

func update_scale(incoming_vector: Vector3) -> void:
	_owner_scale *= incoming_vector
	var update_details: Dictionary = {
		StateHeaders.SCALE: incoming_vector
	}
	state_data_change.emit(StateUpdate.new(STATE.UPDATE_TYPE.SCALE, update_details))

func update_is_crouching(incoming_value: bool) -> void:
	_is_crouching = incoming_value
	var update_details: Dictionary = {
		StateHeaders.IS_CROUCHING: incoming_value
	}
	state_data_change.emit(StateUpdate.new(STATE.UPDATE_TYPE.TOGGLE, update_details))

func is_crouching() -> bool:
	return _is_crouching

func update_is_sprinting(incoming_value: bool) -> void:
	_is_sprinting = incoming_value
	var update_details: Dictionary = {
		StateHeaders.IS_SPRINTING: incoming_value
	}
	state_data_change.emit(StateUpdate.new(STATE.UPDATE_TYPE.TOGGLE, update_details))

func is_sprinting() -> bool:
	return _is_sprinting

func update_movement_enabled(incoming_value: bool) -> void:
	_movement_enabled = incoming_value
	var update_details: Dictionary = {
		StateHeaders.TOGGLE: _MOVEMENT_ENABLED
	}
	state_data_change.emit(StateUpdate.new(STATE.UPDATE_TYPE.TOGGLE, update_details))

func is_movement_enabled() -> bool:
	return _movement_enabled

func get_transitions() -> Dictionary:
	return self._valid_transitions

func get_values() -> Dictionary:
	return self._state_values

func get_windows() -> Dictionary:
	return self._state_windows

func get_owner_guid() -> String:
	return _owner_guid

func get_current_rotation() -> Quaternion:
	return _owner_rotation

func get_current_position() -> Vector3:
	return _owner_position

func get_current_scale() -> Vector3:
	return _owner_scale

func is_valid_state(incoming_state: STATE.ASSET) -> bool:
	if _valid_transitions.has(incoming_state):
		return true
	for state_transitions in _valid_transitions.values():
		if state_transitions.has(incoming_state):
			return true
	return false

func log(incoming_message: String, incoming_level: Log.LEVEL) -> void:
	match incoming_level:
		Log.LEVEL.INFO:
			Log.info(incoming_message, [], self)
		Log.LEVEL.DEBUG:
			Log.debug(incoming_message, [], self)
		Log.LEVEL.WARN:
			Log.warn(incoming_message, [], self)
		Log.LEVEL.ERROR:
			Log.error(incoming_message, [], self)
		_:
			Log.error(_UNSUPPORTED_TYPE, [Log.LOG_LEVEL_TYPE, incoming_level, ], self)

func print_details() -> void:
	var current_state_name: String = STATE.get_state_string(_current_state)
	Log.debug("StateData \"%s\" CurrentState: \"%s\" StateID: \"%d\" Duration: \"%.2f\" Windows: \"%d\" Transitions: \"%d\" Values: \"%d\"", [_owner_guid, current_state_name, _current_state, _current_state_duration, _state_windows.size(), _valid_transitions.size(), _state_values.size()], self)

func as_string() -> String:
	var current_state_name: String = STATE.get_state_string(_current_state)
	var details: String = "StateData[%s]: current_state=%s(%d), duration=%.2f" % [_owner_guid, current_state_name, _current_state, _current_state_duration]
	details += ", windows=%d, transitions=%d, values=%d" % [_state_windows.size(), _valid_transitions.size(), _state_values.size()]
	return details

func _get_sorted_transitions(state: STATE.ASSET) -> Array:
	if _valid_transitions.has(state):
		var transitions: Array = _valid_transitions[state]
		transitions.sort()
		return transitions
	else:
		Log.warn(_NO_VALID_TRANSITION, [_owner_guid, state], self)
		return []

func _collect_states(forward: bool) -> Array[STATE.ASSET]:
	var transitions := _get_sorted_transitions(_current_state)
	var result: Array[STATE.ASSET] = []
	for s in transitions:
		if forward and s > _current_state:
			result.append(s)
		elif not forward and s < _current_state:
			result.append(s)
	return result

func _find_next_valid_state() -> STATE.ASSET:
	var transitions := _get_sorted_transitions(_current_state)
	for s in transitions:
		if s > _current_state:
			return s
	return _current_state

func _find_previous_valid_state() -> STATE.ASSET:
	var transitions := _get_sorted_transitions(_current_state)
	for s in transitions:
		if s < _current_state:
			return s
	return _current_state

func _validate_window_configuration(incoming_windows: Dictionary) -> bool:
	if incoming_windows.is_empty():
		return true
	var sorted_states: Array = incoming_windows.keys()
	sorted_states.sort()
	var previous_value: float = -INF
	for state in sorted_states:
		var current_value: float = incoming_windows[state]
		if current_value < previous_value:
			var state_string: String = STATE.get_state_string(state)
			Log.warn(_DECREASING_WINDOW, [_owner_guid, state_string, previous_value, current_value], self)
			return false
		previous_value = current_value
	return true
