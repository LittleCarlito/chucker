class_name StateDataStorage

const _MISSING_GUID: String = "Incoming node \"%s\" is missing a GUID and cannot be registered"
const _GUID_NOT_FOUND: String = "Requested GUID \"%s\" does not exist in dictionary"
const _DICTIONARY_DATA_NOT_FOUND: String = "Requested GUID \"%s\" dictionary does not contain %s"
const _UNSUPPORTED_TYPE: String = "Incoming state header type \"%s\" for guid \"%s\" is not supported; Type numeric value \"%d\""

var _state_dictionary: Dictionary

func _init(incoming_dictionary: Dictionary = {}) -> void:
	self._state_dictionary = incoming_dictionary

func get_state_dictionary() -> Dictionary:
	return self._state_dictionary

func register_new_node(incoming_node: Node3D) -> StateData:
	var incoming_name: String = incoming_node.name
	if not incoming_node.has_meta(GroupData.GUID):
		Logger.error(self._MISSING_GUID, [incoming_name], self)
		return null
	var incoming_guid: String = incoming_node.get_meta(GroupData.GUID)
	if incoming_node is CameraRig:
		# TODO Create a test to ensure transitions are respected
		var camera_state_data: CameraStateData = CameraStateData.new(
													incoming_guid, 
													incoming_name,
													CameraStateConfiguration.VALID_TRANSITIONS,
													CameraStateConfiguration.SPIN_VALUES
													)
		self._state_dictionary[incoming_node.get_meta(GroupData.GUID)] = {
			StateHeaders.STATE_DATA: camera_state_data,
			StateHeaders.STATE_NODE: incoming_node
		}
		return camera_state_data.duplicate(true)
	elif incoming_node is ThrowableItem:
		var throwable_state_data: StateData =  StateData.new(
												incoming_guid,
												incoming_name,
												ThrowableStateConfiguration.VALID_TRANSITIONS,
												ThrowableStateConfiguration.SPIN_VALUES,
												ThrowableStateConfiguration.WINDOW_VALUES
												)
		self._state_dictionary[incoming_guid] = {
			StateHeaders.STATE_DATA: throwable_state_data,
			StateHeaders.STATE_NODE: incoming_node
		}
		return throwable_state_data.duplicate(true)
	elif incoming_node is BaseCharacter:
		var character_state_data: StateData = StateData.new(
												incoming_guid,
												incoming_name,
												PlayerStateConfiguration.VALID_TRANSITIONS
												)
		self._state_dictionary[incoming_guid] = {
			StateHeaders.STATE_DATA: character_state_data,
			StateHeaders.STATE_NODE: incoming_node
		}
		return character_state_data.duplicate(true)
	else:
		var state_data: StateData = StateData.new(incoming_guid, incoming_name)
		self._state_dictionary[incoming_guid] = {
			StateHeaders.STATE_DATA: state_data,
			StateHeaders.STATE_NODE: incoming_node
		}
		return state_data.duplicate(true)

func has_guid(incoming_guid: String) -> bool:
	return self._state_dictionary.has(incoming_guid)

func get_header_data(incoming_guid: String, incoming_type: StateHeaders.TYPE):
	var header_string: String = StateHeaders.get_type_string(incoming_type)
	match incoming_type:
		StateHeaders.TYPE.DATA, StateHeaders.TYPE.NODE:
			return self._get_guid_value(incoming_guid, header_string)
		_:
			Logger.error(self._UNSUPPORTED_TYPE, [header_string, incoming_guid, incoming_type], self)
			return null

func storage_size() -> int:
	return _state_dictionary.size()

func duplicate(deep_clone: bool = false) -> StateDataStorage:
	var copy: StateDataStorage = StateDataStorage.new()
	for guid in self._state_dictionary.keys():
		var state_data: StateData = self._state_dictionary[guid]
		copy._state_dictionary[guid] = state_data.duplicate(deep_clone)
	return copy

func print_details() -> void:
	Logger.debug("StateDataStorage states: \"%d\"", [self._state_dictionary.size()], self)
	for guid in self._state_dictionary.keys():
		var state_data: StateData = self._state_dictionary[guid]
		if state_data.has_method("print_details"):
			state_data.print_details()

func _get_guid_value(incoming_guid: String, key: String):
	if not self._state_dictionary.has(incoming_guid):
		Logger.error(self._GUID_NOT_FOUND, [incoming_guid], self)
		return null
	var guid_dictionary: Dictionary = self._state_dictionary.get(incoming_guid)
	if not guid_dictionary.has(key):
		Logger.error(self._DICTIONARY_DATA_NOT_FOUND, [incoming_guid, key], self)
		return null
	return guid_dictionary.get(key)

func is_empty() -> bool:
	return self._state_dictionary.is_empty()

func keys() -> Array:
	return self._state_dictionary.keys()
