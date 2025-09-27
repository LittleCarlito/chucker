extends StatefulAsset
class_name CameraRig

const _SELF: String = "Self"
const _FOCUS_NODE: String = "Focus node"
const _RIG_ACTION: String = "Rig focus action"
const _MISSING_GUID: String = "%s does not have a guid set in its data"
const _INTEGRATIN_DEBUG: String = "Now integrated with guid \"%s\" with focus set to \"%s\""
const _NO_INTEGRATION: String = "No integration point for rig to focus on"

const _MISSING_DATA: String = "Missing \"%s\" data"
const _UNSUPPORTED_TYPE: String  = "Incoming update type \"%s\" is not supported"
const _MIN_HEIGHT_WARN: String = "Is now having its height artificially held to min height of \"%f\""
const _SUCCESSFUL_TRANSITION: String = "Successfully transitioned from \"%s\" state to \"%s\""
const _FREELOOK_REASONING: String = "Camera rig is in freelook or tracking state"
const _INVALID_STATE: String = "Invalid state configuration; %s"
const _FOCUSED_NO_GUID: String = "State is TRACKING but there is no guid to focus on"
const _NO_STATE_DATA: String = "State Data in Global Controller"
const _OWN_GUID: String = "Self GUID"
const _TRACKING_GUID: String = "Tracking GUID"
const _ILLEGAL_STATE: String = "%s is missing from camera rig asset; Application is in IllegalState"
const _UPDATE_FAILED: String = "Failed to update state to new status \"%s\""
const _OWN_STATE: String = "Self state"
const _FOLLOW_TARGET: String = "Follow target"
const _PAN_HORIZONTAL: String = "Pan horizontal"
const _IDLE_ROTATE: String = "Idle rotate"
const _PITCH_VERTICAL: String = "Pitch vertical"
const _SET_INTEGRATION_POINT: String = "Set integration point"
const _TRANSITION_STATE: String = "Transition state"
const _HANDLE_INPUT: String = "Handle input"
const _HANDLE_FREELOOK: String = "Handle freelook"
const _HANDLE_UP_INPUT: String = "Handle up input"
const _HANDLE_DOWN_INPUT: String = "Handle down input"
const _HANDLE_INPUT_DIRECTION: String = "Handle input direction"
const _HANDLE_SPRINT_START: String = "Handle sprint start"
const _HANDLE_SPRING_STOP: String = "Handle sprint stop"
const _HANDLE_STATE_SIGNAL: String = "Handle new state signal"
const _HANDLE_TRANSFORM: String = "Handle transform"

# TODO Break camera down into multiple extension classes and have these up the path with the functions that make sense
# TODO Move majority of this to state
# Below stays
@export var camera_controller: Node3D
@export var internal_camera: Camera3D
@export var freelook_sensitivity: float = 2.0
@export var freelook_pitch_limit: float = 85.0 # degrees
@export var distance_threshold: float = 0.001  # Adjust this threshold as needed
@export var min_height: float = -NUMBERS.FLOAT16_MAX
@export var primary_freelook_enabled: bool
@export var secondary_freelook_enabled: bool
@export var zoom_enabled: bool
# TODO Really this (and probably above ones too) should just be based off what state it is in
@export var movement_enabled: bool
# TODO Get rid of this; Should be able to use GlobalStateController to get anything via guid
var _focus_node: Node3D

func _ready() -> void:
	# Camera signal connections
	GlobalCameraController.connect(SIGNAL_NAME.REQUEST_CAMERA, _handle_camera_request)
	GlobalCameraController.connect(SIGNAL_NAME.HOLD_HEIGHT, set_min_height)
	GlobalCameraController.connect(SIGNAL_NAME.IS_IDLING, set_idle_rotate)
	# Input signal connections
	GlobalInputController.connect(SIGNAL_NAME.FREELOOK_MOTION, _handle_freelook)
	GlobalInputController.connect(SIGNAL_NAME.PRIMARY_ACTION, _handle_input)
	GlobalInputController.connect(SIGNAL_NAME.SECONDARY_ACTION, _handle_input)
	GlobalInputController.connect(SIGNAL_NAME.JUMP_HOLD, _handle_up_input)
	GlobalInputController.connect(SIGNAL_NAME.CROUCH_HOLD, _handle_down_input)
	GlobalInputController.connect(SIGNAL_NAME.WASD_INPUT_DIRECTION, _handle_input_direction)
	GlobalInputController.connect(SIGNAL_NAME.SPRINT_ACTION, _handle_sprint_start)
	GlobalInputController.connect(SIGNAL_NAME.SPRINT_RELEASE, _handle_sprint_stop)
	# Set mouse mode
	# TODO Have this done in scene setup calls for state setting
	#			This shoudl be done as a result of the final state of the camera rig befroe starting the scene is unfocused or tracking (just like with the gating on _handle_input)
	GlobalCursorController.request_state(self, GlobalCursorController.CursorState.CAPTURED, "Should be done in camera or scene state stuff")
	# State connections
	GlobalStateController.connect(SIGNAL_NAME.STATE_UPDATED, _handle_new_state_signal)

# TODO Figure out how to have this pushed down from state instead
#			Will probably require EVERYTHING functioning off state first to work though
func _physics_process(_delta: float) -> void:
	if self.min_height != -NUMBERS.FLOAT16_MAX:
		var is_height_held: bool = self.min_height > self.camera_controller.global_position.y
		self.camera_controller.global_position.y = max(self.min_height, self.camera_controller.global_position.y)
		if is_height_held:
			var self_guid: String = self._get_guid_ref()
			if self_guid != null:
				var height_warning: String = self._MIN_HEIGHT_WARN % self.min_height
				var warn_payload: Dictionary = {
					GameAction.OWNER_GUID: self_guid,
					GameAction.MESSAGE: height_warning
				}
				var warn_action: GameAction = GameAction.new(GameAction.TYPE.WARN, warn_payload)
				GlobalStateController.dispatch(warn_action)
			else:
				var error_string = self._ILLEGAL_STATE % self.OWNER_GUID
				push_error(error_string)

## Sets state to idle rotate
func idle_rotate(delta: float, rotation_speed: float = CameraConfig.get_idle_rotate_speed()) -> void:
	var self_guid: String = self._get_guid_ref()
	if self_guid == null:
		Logger.error(Logger._CANT_PERFORM, [self._OWN_GUID, self._IDLE_ROTATE], self)
		return
	var rotation_amount: float = delta * rotation_speed
	var idle_string: String = StateConfiguration.get_state_string(StateConfiguration.STATE.IDLE_ROTATE)
	var idle_action_dictionary: Dictionary = {
		GameAction.OWNER_GUID: self_guid,
		GameAction.STATE: idle_string
	}
	var idle_action: GameAction = GameAction.new(GameAction.TYPE.SET_STATE, idle_action_dictionary)
	GlobalStateController.dispatch(idle_action)

func pan_horizontal(rotation_amount: float) -> void:
	var self_guid: String = self._get_guid_ref()
	if self_guid == null:
		Logger.error(Logger._CANT_PERFORM, [self._OWN_GUID, self._PAN_HORIZONTAL], self)
		return
	var rotation_dictionary: Dictionary = {
		GameAction.Y: rotation_amount
	}
	var rotation_action_dictionary: Dictionary = {
		GameAction.OWNER_GUID: self_guid,
		GameAction.ROTATION: rotation_dictionary
	}
	var rotation_action: GameAction = GameAction.new(GameAction.TYPE.TRANSFORM, rotation_action_dictionary)
	GlobalStateController.dispatch(rotation_action)

func pitch_vertical(rotation_amount: float) -> void:
	var self_guid: String = self._get_guid_ref()
	if self_guid == null:
		Logger.error(Logger._CANT_PERFORM, [self._OWN_GUID, self._PITCH_VERTICAL], self)
		return
	var camera_state_data: StateData = GlobalStateController.get_header_data(self_guid, StateHeaders.TYPE.DATA)
	var current_pitch: float = camera_state_data.get_current_rotation().x
	var new_pitch: float = clamp(
	current_pitch + rotation_amount,
	-deg_to_rad(self.freelook_pitch_limit),
	deg_to_rad(self.freelook_pitch_limit)
	)
	var pitch_dictionary: Dictionary = {
		GameAction.X: new_pitch
	}
	var pitch_action_dictionary: Dictionary = {
		GameAction.OWNER_GUID: self_guid,
		GameAction.ROTATION: pitch_dictionary
	}
	var pitch_action: GameAction = GameAction.new(GameAction.TYPE.TRANSFORM, pitch_action_dictionary)
	GlobalStateController.dispatch(pitch_action)

func focus_guid(incoming_guid: String) -> void:
	self._focus_node = GlobalStateController.get_header_data(incoming_guid, StateHeaders.TYPE.NODE)

# TODO Really should be refactored to just be state based and not rely on Node3D
#			Should be taking in guid only and not node + state
func set_integration_point(
		incoming_node: Node3D, 
		incoming_state: StateConfiguration.STATE = StateConfiguration.STATE.TRACKING_FULL
		) -> void:
	# Focus node in state
	var self_guid: String = self._get_guid_ref()
	if self_guid == null:
		Logger.error(Logger._CANT_PERFORM, [self._OWN_GUID, self._SET_INTEGRATION_POINT], self)
		return
	if incoming_node.has_meta(GroupData.GUID):
		# TODO Change this to a state update action instead
		# TODO Then follow the dispatch logic through to ensure the state action handling logic will pull all the info you put
		var state_string: String = StateConfiguration.get_state_string(incoming_state)
		var target_guid: String = incoming_node.get_meta(GroupData.GUID)
		var integrate_state_dictionary: Dictionary = {
			GameAction.OWNER_GUID: self_guid,
			GameAction.STATE: state_string,
			GameAction.TARGET_GUID: target_guid
		}
		var integrate_action: GameAction = GameAction.new(GameAction.TYPE.SET_STATE, integrate_state_dictionary)
		GlobalStateController.dispatch(integrate_action)
	else:
		var focus_identifier: String = self._FOCUS + " " + "\"" + incoming_node.name + "\""
		Logger.error(self._MISSING_GUID, [focus_identifier], self)


func get_integration_point() -> Node3D:
	return self._focus_node

# TODO NEEDS TO BE REFACTORED
#			Moving to new state based everything combining the focus and focus guid actions to state action
## Clears the integrated point and loses focus
func deintegrate() -> void:
	pass

# TODO Test trying to set wrong state; ensure it doesn't work and logs
func transition_state(incoming_state: StateConfiguration.STATE) -> void:
	var camera_state_data: CameraStateData = self._get_state_ref()
	if camera_state_data == null:
		Logger.error(Logger._CANT_PERFORM, [self._OWN_STATE, self._TRANSITION_STATE], self)
		return
	var old_state: StateConfiguration.STATE = camera_state_data.get_current_state()
	if camera_state_data.try_set_state(incoming_state):
		var from_state_string: String = StateConfiguration.get_state_string(old_state)
		var to_state_string: String = StateConfiguration.get_state_string(incoming_state)
		Logger.debug(self._SUCCESSFUL_TRANSITION, [from_state_string, to_state_string], self)

func is_current() -> bool:
	return self.internal_camera.is_current()

func make_current() -> void:
	self.internal_camera.make_current()

func clear_current() -> void:
	self.internal_camera.clear_current()

func set_tracking_mode(mode: GlobalCameraController.TrackingMode) -> void:
	self.tracking_mode = mode

func get_tracking_mode() -> GlobalCameraController.TrackingMode:
	return self.tracking_mode

func is_idling() -> bool:
	return self.is_idle_rotate

func set_idle_rotate(incoming_value: bool) -> void:
	self.is_idle_rotate = incoming_value

func is_primary_freelook_enabled() -> bool:
	return self.primary_freelook_enabled

func enable_primary_freelook() -> void:
	self.primary_freelook_enabled = true

func disable_primary_freelook() -> void:
	self.primary_freelook_enabled = false

func is_secondary_freelook_enabled() -> bool:
	return self.secondary_freelook_enabled

func enable_secondary_freelook() -> void:
	self.secondary_freelook_enabled = true

func disable_secondary_freelook() -> void:
	self.secondary_freelook_enabled = false

func is_zoom_eanbled() -> bool:
	return self.is_zoom

func enable_zoom() -> void:
	self.is_zoom_enabled = true

func disable_zoom() -> void:
	self.is_zoom = false

func get_min_height() -> float:
	return self.min_height

func set_min_height(incoming_min: float) -> void:
	Logger.debug("Incoming new min height is %f", [incoming_min], self)
	self.min_height = incoming_min

## Tracking handling
func _perform_tracking(_delta: float) -> void:
	self._follow_target()
	self._focus_on_target()

# TODO OUTLINE
# Then improve camera rigs handling of state changes to properly do shit
# Everything that happens is based off a state change or a transform action (or a warn i guess)
# 	So something like integrate target just creates a set state action with the guid and state to set
# 		Handling of state change deals with the rest after it gets to that point
# 			Initial state change sets position with offset if tracking
# 				Only if going from non tracking to tracking state
# 					Tracking to anything else (tracking or non) does nothing
# 			After that state tracking is done via state signal watching for integrated guid
# 				Moves to the same position as the tracked guid but with the offset applied
# 	Then with the integration logic it should be wathcing for state data changes for the guid it is integrated with
# 		So on transform/state changes it too can react properly
#		TLDR: SET_RIG_FOCUS -> SET_STATE; State transition reactions -> addition guid tracking + reactions

# TODO WORK ITEMS

# TODO Refactor characters to use and navigate the world based off state shit instead of direct manipulation
# 	Once they work off their state data
# 		Camera logic can be updated to react/move to its state update signals as well and keep up/focus on the correct thing

# TODO We need to get actions that take place in the game as a result of the character/objects to change state properly
#			i.e. 
				# tracking on throw, 
				# tracking spawned disk from path disk, 
				# idle rotating on disk rest, 
				# return to character after throw idle,
				# idle rotate character on idle sit,
				# snap back to tracking on control usage,
				# etc

# TODO Freelook working but needs tweaking
# TODO Then get tracking working
# TODO Then do rest of todos in file
# TODO Break down file into extending/inheriting classes
# TODO Tracking offset needs to be entirely based off state transitions
#				Non tracking to tracking; offset added
#				tracking to tracking; no action
#				tracking to non tracking; offset removed
# TODO change deintegrate to instead be a state update
# TODO In handle state update function
#				leave stuff looking for own guid
#				add a check to see if there is a focused guid
#					if there is a focused guid also track those updates
# TODO Make a function to handle state updates to focused object
#			When the focused object position change is detected
#				Get the global position of the object
#				set the cameras position to that position with the offset
# TODO Get rid of the focus boolean

# TODO Refactor/implement
func _focus_on_target() -> void:
	pass

func _follow_target() -> void:
	var self_guid: String = self._get_guid_ref()
	var camera_state_data: CameraStateData = self._get_state_ref()
	if self_guid == null or camera_state_data == null:
		var missing_string: String = self._OWN_STATE if self_guid == null else self._OWN_STATE
		Logger.warn(Logger._CANT_PERFORM, [missing_string, self._FOLLOW_TARGET], self)
		return
	var tracking_guid: String = camera_state_data.get_focus_guid()
	# TODO Once characters are fully on state we should be able to use its state and ditch Node3D references
	var tracking_node: Node3D = GlobalStateController.get_header_data(tracking_guid, StateHeaders.TYPE.NODE)
	
	# TODO Will probably need to create player offset vector3 from game config and add it to this position for proper view
	var offset = Vector3(0, GameConfig.DEFAULTS.controller_height, GameConfig.DEFAULTS.controller_distance)
	var world_offset = tracking_node.global_transform.basis * offset
	# Set position and rotation to follow integration point with offset		
	var expected_position: Vector3 = tracking_node.global_position + world_offset
	
	# Use the state data position instead of the node position to avoid feedback loop
	var current_position: Vector3 = camera_state_data.get_current_position()
	var position_difference: Vector3 = expected_position - current_position

	if position_difference.length() > self.distance_threshold:
		# Create and dispatch transform action
		var transform_dictionary: Dictionary = {
			GameAction.X: expected_position.x,
			GameAction.Y: expected_position.y,
			GameAction.Z: expected_position.z
		}
		var transform_action_dictionary: Dictionary = {
			GameAction.OWNER_GUID: self_guid,
			GameAction.POSITION: transform_dictionary
		}
		var transform_action: GameAction = GameAction.new(GameAction.TYPE.TRANSFORM, transform_action_dictionary)
		GlobalStateController.dispatch(transform_action)

# TODO Should be a lower class function after camera refactor
#		Lowest class
func _apply_min_height_constraint(position: Vector3) -> Vector3:
	if self.min_height != -NUMBERS.FLOAT16_MAX:
		position.y = max(self.min_height, position.y)
	return position

# TODO Specify if mouse or keyboard (pretty sure its mouse)
# TODO Should be a lower class function after camera refactor
#		Higher class
func _handle_input() -> void:
	var camera_state_data: CameraStateData = self._get_state_ref()
	if camera_state_data == null:
		Logger.error(Logger._CANT_PERFORM, [self._OWN_STATE, self._HANDLE_INPUT], self)
		return
	var current_state: StateConfiguration.STATE = camera_state_data.get_current_state()
	if current_state >= StateConfiguration.STATE.IS_TRACKING and current_state < StateConfiguration.STATE.FREELOOK_STUCK:
		if GlobalCursorController.get_current_state() == GlobalCursorController.CursorState.CAPTURED:
			GlobalCursorController.request_state(self, GlobalCursorController.CursorState.VISIBLE, self._FREELOOK_REASONING)
		elif GlobalCursorController.get_current_state() == GlobalCursorController.CursorState.VISIBLE:
			GlobalCursorController.request_state(self, GlobalCursorController.CursorState.CAPTURED, self._FREELOOK_REASONING)

# TODO Should be a lower class function after camera refactor
#		Higher class
func _handle_freelook(v_motion: float, h_motion: float) -> void:
	var camera_state_data: StateData = self._get_state_ref()
	if camera_state_data == null:
		Logger.error(Logger._CANT_PERFORM, [self._OWN_STATE, self._HANDLE_FREELOOK], self)
		return
	var current_state: StateConfiguration.STATE = camera_state_data.get_current_state()
	if current_state >= 550 and current_state <= 552:
		self.pan_horizontal(h_motion * freelook_sensitivity)
		self.pitch_vertical(v_motion * freelook_sensitivity)

# TODO Should be a lower class function after camera refactor
#		Lowest class
func _handle_camera_request(new_foucs: Node3D) -> void:
	self.set_integration_point(new_foucs)

# TODO Should be a lower class function after camera refactor
#		Higher class
func _handle_up_input(_delta: float) -> void:
	if self.movement_enabled:
		var self_guid: String = self._get_guid_ref()
		var camera_state_data: StateData = self._get_state_ref()
		if self_guid == null or camera_state_data == null:
			var missing_string: String = self._OWN_GUID if self_guid == null else self._OWN_STATE
			Logger.error(Logger._CANT_PERFORM, [missing_string, self._HANDLE_UP_INPUT], self)
			return
		var sprint_multiplier: float = self._get_sprint_value(camera_state_data)
		var movement_amount: float = GameConfig.DEFAULTS.controller_speed * sprint_multiplier
		var transform_dictionary: Dictionary = {
			GameAction.Y: movement_amount
		}
		var transform_action_dictionary: Dictionary = {
			GameAction.OWNER_GUID: self_guid,
			GameAction.POSITION: transform_dictionary
		}
		var transform_action: GameAction = GameAction.new(GameAction.TYPE.TRANSFORM, transform_action_dictionary)
		GlobalStateController.dispatch(transform_action)

# TODO Should be a lower class function after camera refactor
#		Higher class
func _handle_down_input(_delta: float) -> void:
	if self.movement_enabled:
		var self_guid: String = self._get_guid_ref()
		var camera_state_data: StateData = self._get_state_ref()
		if self_guid == null or camera_state_data == null:
			var missing_string: String = self._OWN_GUID if self_guid == null else self._OWN_STATE
			Logger.error(Logger._CANT_PERFORM, [missing_string, self._HANDLE_UP_INPUT], self)
			return
		var sprint_multiplier: float = self._get_sprint_value(camera_state_data)
		var movement_amount: float = -(GameConfig.DEFAULTS.controller_speed * sprint_multiplier)
		var transform_dictionary: Dictionary = {
			GameAction.Y: movement_amount
		}
		var transform_action_dictionary: Dictionary = {
			GameAction.OWNER_GUID: self_guid,
			GameAction.POSITION: transform_dictionary
		}
		var transform_action: GameAction = GameAction.new(GameAction.TYPE.TRANSFORM, transform_action_dictionary)
		GlobalStateController.dispatch(transform_action)

# TODO Should be a lower class function after camera refactor
#		Higher class
func _handle_input_direction(incoming_direction: Vector2) -> void:
	if self.movement_enabled:
		var self_guid: String = self._get_guid_ref()
		var camera_state_data: StateData = self._get_state_ref()
		if self_guid == null or camera_state_data == null:
			var missing_string: String = self._OWN_GUID if self_guid == null else self._OWN_STATE
			Logger.error(Logger._CANT_PERFORM, [missing_string, self._HANDLE_INPUT_DIRECTION], self)
			return
		var sprint_multiplier: float = self._get_sprint_value(camera_state_data)
		var x_amount = incoming_direction.x * sprint_multiplier
		var y_amount = incoming_direction.y * sprint_multiplier
		var transform_dictionary: Dictionary = {
			GameAction.X: x_amount,
			GameAction.Z: y_amount
		}
		var transform_action_dictionary: Dictionary = {
			GameAction.OWNER_GUID: self_guid,
			GameAction.POSITION: transform_dictionary
		}
		var transform_action: GameAction = GameAction.new(GameAction.TYPE.TRANSFORM, transform_action_dictionary)
		GlobalStateController.dispatch(transform_action)

# BUG right now only up and down inputs are workign
func _get_sprint_value(incoming_state: StateData) -> float:
	var sprint_value: float = 1.0
	if incoming_state.is_sprinting():
		sprint_value = GameConfig.DEFAULTS.sprint_multiplier
	return sprint_value

# TODO Should be a lower class function after camera refactor
#		Lowest class
func _handle_sprint_start() -> void:
	var self_guid: String = self._get_guid_ref()
	if self_guid == null:
		Logger.error(Logger._CANT_PERFORM, [self._OWN_GUID, self._HANDLE_SPRINT_START], self)
		return
	var transform_action_dictionary: Dictionary = {
		GameAction.OWNER_GUID: self_guid,
		GameAction.IS_SPRINTING: GroupData.TRUE
	}
	var transform_action: GameAction = GameAction.new(GameAction.TYPE.TRANSFORM, transform_action_dictionary)
	GlobalStateController.dispatch(transform_action)

# TODO Should be a lower class function after camera refactor
#		Lowest class
func _handle_sprint_stop() -> void:
	var self_guid: String = self._get_guid_ref()
	if self_guid == null:
		Logger.error(Logger._CANT_PERFORM, [self._OWN_GUID, self._HANDLE_SPRING_STOP], self)
		return
	var transform_action_dictionary: Dictionary = {
		GameAction.OWNER_GUID: self_guid,
		GameAction.IS_SPRINTING: GroupData.FALSE
	}
	var transform_action: GameAction = GameAction.new(GameAction.TYPE.TRANSFORM, transform_action_dictionary)
	GlobalStateController.dispatch(transform_action)

func _handle_new_state_signal(update_details: Dictionary) -> bool:
	if super(update_details):
		var self_guid: String = self._get_guid_ref()
		var update_action: GameAction = update_details[self_guid]
		match update_action.action_type:
			GameAction.TYPE.SET_STATE:
				self._handle_state_update(update_action)
			GameAction.TYPE.TRANSFORM:
				self._handle_transform(update_action)
			_:
				var update_type_string: String = GameAction.get_type_string(update_action.action_type)
				Logger.warn(self._UNSUPPORTED_TYPE, [update_type_string], self)
				return false
	return true

func _handle_state_update(incoming_action: GameAction) -> void:
	var current_state_data: StateData = self._get_state_ref()
	var current_state: StateConfiguration.STATE = current_state_data.get_current_state()
	var missing_keys: Array[String] = StateUtil.get_missing_keys(incoming_action.payload, [GameAction.STATE])
	if current_state == StateConfiguration.STATE.UNKNOWN or missing_keys.size() > 0:
		return
	var new_state_string: String = incoming_action.payload[GameAction.STATE]
	var new_state: StateConfiguration.STATE = StateConfiguration.get_state_from_string(new_state_string)
	if !current_state_data.can_transition(new_state):
		# can transition already has logged a warning about the failure
		return
	var new_state_tracking: bool = StateUtil.is_tracking(new_state)
	var current_state_tracking: bool = StateUtil.is_tracking(current_state)
	if new_state_tracking != current_state_tracking:
		if new_state_tracking:
			self._handle_transition_to_track()
	if !current_state_data.try_and_set(new_state):
		Logger.error(self._UPDATE_FAILED, [new_state_string], self)
		return
	self.set_state_dirty()

func _handle_transition_to_track() -> void:
	var camera_state_data: StateData = self._get_state_ref()
	var focused_guid: String = camera_state_data.get_focus_guid()
	if focused_guid.strip_edges().is_empty():
		Logger.error(self._ILLEGAL_STATE, [self._TRACKING_GUID], self)
		return
	var focused_state_data: StateData = GlobalStateController.get_header_data(focused_guid, StateHeaders.TYPE.DATA)
	var focus_position: Vector3 = focused_state_data.get_current_position()
	var offset_vector: Vector3 = Vector3(0, GameConfig.DEFAULTS.controller_height, GameConfig.DEFAULTS.controller_distance)
	self.camera_controller.position = focus_position + offset_vector
	self.camera_controller.look_at(focus_position)

# TODO Should be a lower class function after camera refactor
#		Lowest class
func _handle_transform(incoming_action: GameAction) -> void:
	var missing_transform_keys: Array[String] = StateUtil.get_missing_keys(incoming_action.payload, GameAction.TRANSFORM_KEYS)
	if missing_transform_keys.size() < GameAction.TRANSFORM_KEYS.size():
		var camera_state_data: StateData = self._get_state_ref()
		if camera_state_data == null:
			Logger.error(Logger._CANT_PERFORM, [self._OWN_GUID, self._HANDLE_TRANSFORM], self)
			return
		if incoming_action.payload.has(GameAction.ROTATION):
			var new_rotation: Quaternion = camera_state_data.get_current_rotation()
			self.transform.basis = Basis(new_rotation.normalized())
		if incoming_action.payload.has(GameAction.POSITION):
			var new_position: Vector3 = camera_state_data.get_current_position()
			self.position = new_position
		if incoming_action.payload.has(GameAction.SCALE):
			var new_scale: Vector3 = camera_state_data.get_current_scale()
			self.scale = new_scale
		self.set_state_dirty()
	else:
		var missing_transform_string: String = "; ".join(missing_transform_keys)
		Logger.error(Logger.BAD_ACTION_FORMAT, [incoming_action, missing_transform_string], self)
