extends Resource
class_name AssetState

const _BAD_FORMAT: String = "Incoming request to \"%s\" cannot be performed; %d optional parameters must be provided"
const _DUPLICATE_TRACKED_STATES: String = "Duplicate tracked asset states belonging to owner \"%s\" have been found; ILLEGAL STATE"
const _HANDLE_FOCUS: String = "Handle Focus Action"
const _GET_OWNER_GUID: String = "Get Owner GUID"
const _STATE_DATA: String = "State Data"

var _guid_string: String
var _state_data: StateData
var _state_warnings: Dictionary
var _tracked_assets: Array[AssetState]

# TODO Refactor to not be a dispatch but just set _state_data directly
func sync_asset() -> void:
	pass
	# var self_guid: String = self._get_guid_ref()
	# var current_position: Vector3 = self.global_position
	# var position_dictionary: Dictionary = {
	# 	GameAction.X: current_position.x,
	# 	GameAction.Y: current_position.y,
	# 	GameAction.Z: current_position.z
	# }
	# var current_rotation: Vector3 = self.global_rotation
	# var rotation_dictionary: Dictionary = {
	# 	GameAction.X: current_rotation.x,
	# 	GameAction.Y: current_rotation.y,
	# 	GameAction.Z: current_rotation.z
	# }
	# var current_scale: Vector3 = self.scale
	# var scale_dictionary: Dictionary = {
	# 	GameAction.X: current_scale.x,
	# 	GameAction.Y: current_scale.y,
	# 	GameAction.Z: current_scale.z
	# }
	# var tag_list: Array[String] = [GameAction.SYNC]
	# var sync_action_dictionary: Dictionary = {
	# 	GameAction.OWNER_GUID: self_guid,
	# 	GameAction.POSITION: position_dictionary,
	# 	GameAction.ROTATION: rotation_dictionary,
	# 	GameAction.SCALE: scale_dictionary,
	# 	GameAction.TAGS: tag_list
	# }
	# var sync_action: GameAction = GameAction.new(GameAction.TYPE.TRANSFORM, sync_action_dictionary)
	# GlobalStateController.dispatch(sync_action)

func get_owner_guid() -> String:
	if self._state_data == null:
		Logger.error(Logger._CANT_PERFORM, [self._STATE_DATA, self._GET_OWNER_GUID], self)
		return GroupData.EMPTY
	return self._state_data.get_owner_guid()


func get_current_state() -> StateConfiguration.STATE:
	var found_state: StateData = self._get_state_data()
	if found_state == null:
		return StateConfiguration.STATE.UNKNOWN
	return found_state.get_current_state()

# TODO Refactor callers to use new name
# func _get_guid_ref() -> String:
func get_guid_string() -> String:
	# Only cares about null; Dirty state doesn't affect immutable thing like a GUID
	if self._guid_string == null:
		self._guid_string = self.get_meta(GroupData.GUID)
	return self._guid_string

# TODO Refactor callers to use new name
# func _get_state_ref() -> StateData:
func get_state_data() -> StateData:
	if self._state_data == null:
		self._state_data = StateData.new()
	return self._state_data

func set_to_state(incoming_state: StateConfiguration.STATE) -> bool:
	if self._state_data == null:
		return false
	return self._state_data.try_set_state(incoming_state)

func output_warning(incoming_warning: String) -> void:
	if self._state_warnings.has(incoming_warning):
		self._state_warnings[incoming_warning] += 1
		return
	self._state_warnings[incoming_warning] = 1
	Logger.warn(incoming_warning, [], self)

# TODO Do what GlobalStateController does and convert the incoming data to a Quaternion and apply it to the existing rotation amounts
func apply_rotation(euler_rotations: Vector3) -> void:
	pass

func perform_action(action_type: GameAction.TYPE: options: Dictionary = {}) -> bool:
	match action_type:
		GameAction.FOCUS:
			if options.has(GameAction.TARGET_GUID):
				return self._handle_focus_action(options)
			else:
				var action_string: String = GameAction.get_type_string(action_type)
				Logger.error(self._BAD_FORMAT, [action_string, 1], self)
		_:
			var action_string: String = GameAction.get_type_string(action_type)
			Logger.error(GameAction.UNSUPPORTED, [action_string], self)
	return false

# TODO OOOOO YOU WERE HERE AND WORKIGN ON CAMERA RIG
#			Getting state to RESOURCE and CameraRig to using that Resource
#				And there are no other notes on it really but this is also going to require a big refactor of GlobalStateController
func _handle_focus_action(action_payload: Dictionary) -> bool:
	# TODO GlobalStateController needs to be refactored to stare and use AssetState
	var target_guid: String = action_payload[GameAction.TARGET_GUID]
	var is_target_tracked: bool = self._focus_target_guid(target_guid)
	if is_target_tracked:
		# TODO Now handle updating the state to whatever was given in the payload
		#			Might not be provided; if not that is find just dont call the function
		#			Otherwise call the function to set the asset state to given state
		pass
	return true

func _focus_target_guid(target_guid: String) -> bool:
	var target_state: AssetState = GlobalStateController.get_header_data(target_guid, StateHeaders.TYPE.DATA)
	if target_state == null:
		var target_string: String = "State for target GUID \"%s\"" % target_guid
		Logger.error(Logger._CANT_PERFORM, [target_string, self._HANDLE_FOCUS], self)
		return false
	if self._tracked_assets.has(target_guid):
		var target_owner_guid: String = target_state.get_owner_guid()
		if target_owner_guid == GroupData.EMPTY:
			# Already should be logged; Can return false
			return false
		var target_guid_assets: Array = self._tracked_assets[target_guid]
		var matches: Array = target_guid_assets.filter(
			func(tracked_asset): return tracked_asset.get_owner_guid() == target_owner_guid
		)
		if matches.size() > 1:
			Logger.error(self._DUPLICATE_TRACKED_STATES, [target_owner_guid], self)
			return false
		var updated_assets: Array = []
		var found_match: bool = false
		for tracked_asset in target_guid_assets:
			if tracked_asset.get_owner_guid() == target_owner_guid:
				updated_assets.append(target_state)
				found_match = true
			else:
				updated_assets.append(tracked_asset)
		if not found_match:
			updated_assets.append(target_state)
		self._tracked_assets[target_guid] = updated_assets
		return true
