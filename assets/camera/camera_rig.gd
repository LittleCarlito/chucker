extends Node3D
class_name CameraRig

const _SELF: String = "Self"
const _FOCUS_NODE: String = "Focus node"
const _RIG_ACTION: String = "Rig focus action"
const _MISSING_GUID: String = "%s does not have a guid set in its data"
const _INTEGRATIN_DEBUG: String = "Now integrated with guid \"%s\" with focus set to \"%s\""
const _NO_INTEGRATION: String = "No integration point for rig to focus on"

const _MISSING_DATA: String = "Missing \"%s\" data"
# TODO Replace this usage with Logger usage
const _UNSUPPORTED_TYPE: String  = "Incoming update type \"%s\" is not supported"
const _MIN_HEIGHT_WARN: String = "Is now having its height artificially held to min height of \"%f\""
const _SUCCESSFUL_TRANSITION: String = "Successfully transitioned from \"%s\" state to \"%s\""
const _FREELOOK_REASONING: String = "Camera rig is in freelook or tracking state"
const _INVALID_STATE: String = "Invalid state configuration; %s"
const _FOCUSED_NO_GUID: String = "State is TRACKING but there is no guid to focus on"
const _NO_STATE_DATA: String = "State Data in Global Controller"
const _SET_INTEGRATION: String = "Set Integration Point"
const _OWN_GUID: String = "Self GUID"
const _TRACKING_GUID: String = "Tracking GUID"
const _ILLEGAL_STATE: String = "%s is missing from camera rig asset; Application is in IllegalState"
const _UPDATE_FAILED: String = "Failed to update state from \"%s\" to new state \"%s\""
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

const _HANDLE_STATE_UPDATE: String = "Handle State Update"

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
# TODO Now that this is a local resource again can probably move unique variables to it
#			Could enxtend the class to certain types to have them there to begin with
@export var asset_state: AssetState
# TODO Get rid of this; Should be able to use GlobalStateController to get anything via guid
var _focus_state: AssetState

func _ready() -> void:
	asset_state.connect(SIGNAL_NAME.STATE_DATA_CHANGE, _handle_state_update)
	# Camera signal connections
	# TODO Got rid of this for the moment; Might need to recreate once camera/state refactor is complete
	# GlobalCameraController.connect(SIGNAL_NAME.REQUEST_CAMERA, _handle_camera_request)
	GlobalCameraController.connect(SIGNAL_NAME.HOLD_HEIGHT, set_min_height)
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

	# TODO OOOOO - Continuation of GlobalStateController refactor
	# TODO Refactor to handle update signals from AssetState
	#			Probably have to make said signals as well
	# GlobalStateController.connect(SIGNAL_NAME.STATE_UPDATED, _handle_new_state_signal)

# TODO Figure out how to have this pushed down from state instead
#			Will probably require EVERYTHING functioning off state first to work though
func _physics_process(_delta: float) -> void:
	if self.min_height != -NUMBERS.FLOAT16_MAX:
		var is_height_held: bool = self.min_height > self.camera_controller.global_position.y
		self.camera_controller.global_position.y = max(self.min_height, self.camera_controller.global_position.y)
		if is_height_held:
			var height_warning: String = self._MIN_HEIGHT_WARN % self.min_height
			self.asset_state.output_warning(height_warning)

# TODO IMPLEMENT sets the 
func track_focus() -> void:
	# TODO Find the asset state in the tracked assets of AssetState
	# TODO If not found in tracked assets log a warning
	pass

## Sets state to idle rotate
func idle_rotate() -> void:
	var idle_state: STATE.ASSET = STATE.ASSET.IDLE_ROTATE
	if not self.asset_state.set_to_state(idle_state):
		var current_string: String = STATE.get_state_string(self.asset_state.get_current_state())
		var idle_string: String = STATE.get_state_string(idle_state)
		Logger.error(self._UPDATE_FAILED, [current_string, idle_string], self)

func pan_horizontal(rotation_amount: float) -> void:
	var pan_vector: Vector3 = Vector3(0, rotation_amount, 0)
	self.asset_state.apply_rotation(pan_vector)

func pitch_vertical(rotation_amount: float) -> void:
	var pitch_vector: Vector3 = Vector3(0, rotation_amount, 0)
	self.asset_state.apply_rotation(pitch_vector)

func focus_guid(incoming_guid: String) -> void:
	self._focus_state = GlobalStateController.get_header_data(incoming_guid, StateHeaders.TYPE.DATA)

func track_guid(
		incoming_guid: String, 
		incoming_state: STATE.ASSET = STATE.ASSET.UNKNOWN
		) -> void:
	var action_dictionary: Dictionary = {
		GameAction.TARGET_GUID: incoming_guid
	}
	var state_string = STATE.get_state_string(incoming_state)
	if incoming_state != STATE.ASSET.UNKNOWN && self.asset_state.can_transition(incoming_state):
		action_dictionary[STATE.HEADER] = state_string
	var result_success: bool = self.asset_state.perform_action(GameAction.TYPE.TRACK, action_dictionary)
	if not result_success:
		var parameter_string: String = "Incoming GUID: %s; Incoming state: %s" % [incoming_guid, state_string]
		Logger.error(Logger.CALL_FAILED, [self._SET_INTEGRATION, parameter_string], self)

## Retrieves the first tracked GUID
func get_integration_point() -> String:
	return self.asset_state.get_first_tracked()

## Clears the integrated point and loses focus
func deintegrate(incoming_guid: String) -> void:
	self.asset_state.stop_tracking(incoming_guid)

func deintegrate_all() -> void:
	var tracked_guids: Array = self.asset_state.get_tracked_guids()
	for guid in tracked_guids:
		self.deintegrate(guid)

# TODO Test trying to set wrong state; ensure it doesn't work and logs
func transition_state(incoming_state: STATE.ASSET) -> void:
	var camera_state_data: CameraStateData = asset_state.get_state_data()
	if camera_state_data == null:
		Logger.error(Logger._CANT_PERFORM, [self._OWN_STATE, self._TRANSITION_STATE], self)
		return
	var old_state: STATE.ASSET = camera_state_data.get_current_state()
	if camera_state_data.try_set_state(incoming_state):
		var from_state_string: String = STATE.get_state_string(old_state)
		var to_state_string: String = STATE.get_state_string(incoming_state)
		Logger.debug(self._SUCCESSFUL_TRANSITION, [from_state_string, to_state_string], self)

func get_current_state() -> STATE.ASSET:
	return asset_state.get_current_state()

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
	self.min_height = incoming_min

func ceneter_on_focused() -> void:
	pass

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

# TODO Should be a lower class function after camera refactor
#		Lowest class
func _apply_min_height_constraint(incoming_position: Vector3) -> Vector3:
	if self.min_height != -NUMBERS.FLOAT16_MAX:
		incoming_position.y = max(self.min_height, incoming_position.y)
	return incoming_position

# TODO Specify if mouse or keyboard (pretty sure its mouse)
# TODO Should be a lower class function after camera refactor
#		Higher class
func _handle_input() -> void:
	var camera_state_data: CameraStateData = asset_state.get_state_data()
	if camera_state_data == null:
		Logger.error(Logger._CANT_PERFORM, [self._OWN_STATE, self._HANDLE_INPUT], self)
		return
	var current_state: STATE.ASSET = camera_state_data.get_current_state()
	if current_state >= STATE.ASSET.IS_TRACKING and current_state < STATE.ASSET.FREELOOK_STUCK:
		if GlobalCursorController.get_current_state() == GlobalCursorController.CursorState.CAPTURED:
			GlobalCursorController.request_state(self, GlobalCursorController.CursorState.VISIBLE, self._FREELOOK_REASONING)
		elif GlobalCursorController.get_current_state() == GlobalCursorController.CursorState.VISIBLE:
			GlobalCursorController.request_state(self, GlobalCursorController.CursorState.CAPTURED, self._FREELOOK_REASONING)

# TODO Should be a lower class function after camera refactor
#		Higher class
func _handle_freelook(v_motion: float, h_motion: float) -> void:
	var camera_state_data: StateData = asset_state.get_state_data()
	if camera_state_data == null:
		Logger.error(Logger._CANT_PERFORM, [self._OWN_STATE, self._HANDLE_FREELOOK], self)
		return
	var current_state: STATE.ASSET = camera_state_data.get_current_state()
	if current_state >= 550 and current_state <= 552:
		self.pan_horizontal(h_motion * freelook_sensitivity)
		self.pitch_vertical(v_motion * freelook_sensitivity)

# TODO Should be a lower class function after camera refactor
#		Higher class
func _handle_up_input(_delta: float) -> void:
	if self.asset_state.is_movement_enabled():
		var sprint_multiplier: float = self._get_sprint_value(self.asset_state.is_sprinting())
		var movement_amount: float = GameConfig.DEFAULTS.controller_speed * sprint_multiplier
		var movement_vector: Vector3 = Vector3(0, movement_amount, 0)
		self.asset_state.apply_movement(movement_vector)

# TODO Should be a lower class function after camera refactor
#		Higher class
func _handle_down_input(_delta: float) -> void:
	if self.asset_state.is_movement_enabled():
		var sprint_multiplier: float = self._get_sprint_value(self.asset_state.is_sprinting())
		var movement_amount: float = -(GameConfig.DEFAULTS.controller_speed * sprint_multiplier)
		var movement_vector: Vector3 = Vector3(0, movement_amount, 0)
		self.asset_state.apply_movement(movement_vector)

# TODO Should be a lower class function after camera refactor
#		Higher class
func _handle_input_direction(incoming_direction: Vector2) -> void:
	if self.asset_state.is_movement_enabled():
		var sprint_multiplier: float = self._get_sprint_value(self.asset_state.is_sprinting())
		var x_amount = incoming_direction.x * sprint_multiplier
		var y_amount = incoming_direction.y * sprint_multiplier
		var movement_vector: Vector3 = Vector3(x_amount, 0, y_amount)
		self.asset_state.apply_movement(movement_vector)

# BUG right now only up and down inputs are workign
func _get_sprint_value(is_sprinting: bool) -> float:
	var sprint_value: float = 1.0
	if is_sprinting:
		sprint_value = GameConfig.DEFAULTS.sprint_multiplier
	return sprint_value

# TODO Should be a lower class function after camera refactor
#		Lowest class
func _handle_sprint_start() -> void:
	self.asset_state.start_sprinting()

# TODO Should be a lower class function after camera refactor
#		Lowest class
func _handle_sprint_stop() -> void:
	self.asset_state.stop_sprinting()

# TODO Need frame to frame checking for state and keeping everythign up to date using functions like below
func lerp_to(incoming_position: Vector3, delta: float = NUMBERS.FLOAT16_MAX) -> void:
	# Smoothly move towards the target using linear interpolation
	var effective_delta: float = 1.0 if delta == NUMBERS.FLOAT16_MAX else delta
	var lerp_speed: float = GameConfig.DEFAULTS.lerp_speed * effective_delta
	lerp_speed = clamp(lerp_speed, 0.0, 1.0)
	global_transform.origin = global_transform.origin.lerp(incoming_position, lerp_speed)

func snap_to(incoming_position: Vector3) -> void:
	self.position = incoming_position





# TODO CONTINUE FROM HERE
#			Do the two below
#			Then go and implement the rest of the resolver functions below that aren't done
#			Then get frame to frame state handling written
#				DO THIS IN TransformResolver
#				needs to lerp to position of tracked asset if in certain states
#				perform other frame to frame activities you can think of that need handling due to state
func apply_tracking_distance() -> void:
	# TODO Make the camera controller position locally equal to a set z and y position away from origin
	#		Do not add it to the position do an override
	#			Adding will keep this from being idempondent
	pass

func remove_tracking_distance() -> void:
	# TODO Make a function to reset the camera controller to origin
	#			Don't subtrack the distance just reset the position
	pass

# TODO You were here
#		Need to implement the logic in the resolvers		
func _handle_state_update(incoming_update: StateUpdate) -> void:
	var update_type: STATE.UPDATE_TYPE = incoming_update.get_update_type()
	match update_type:
		STATE.UPDATE_TYPE.FOCUS:
			RigResolver.resolve_focus(self, incoming_update)
		STATE.UPDATE_TYPE.ROTATION:
			TransformResolver.resolve_rotation(self, self.asset_state.get_current_rotation())
		STATE.UPDATE_TYPE.POSITION:
			TransformResolver.resolve_position(self, self.asset_state.get_current_position())
		STATE.UPDATE_TYPE.SCALE:
			TransformResolver.resolve_scale(self, self.asset_state.get_current_scale())
		STATE.UPDATE_TYPE.STATE:
			RigResolver.resolve_state(self, incoming_update)
		STATE.UPDATE_TYPE.TOGGLE:
			# TODO Once crouching is added TransformResolver should handle it here
			pass
		_:
			var update_string: String = STATE.get_update_type_string(update_type)
			Logger.error(Logger.UNSUPPORTED_TYPE_LOG, [self._HANDLE_STATE_UPDATE, update_string], self)

func _crouch_handling(incoming_update: StateUpdate) -> void:
	# TODO Determine if the toggle update is a crouch update

# 	var current_state_data: StateData = asset_state.get_state_data()
# 	var current_state: STATE.ASSET = current_state_data.get_current_state()
# 	var missing_keys: Array[String] = StateUtil.get_missing_keys(incoming_action.payload, [GameAction.STATE])
# 	if current_state == STATE.ASSET.UNKNOWN or missing_keys.size() > 0:
# 		return
# 	var current_state_string: String = STATE.get_state_string(current_state)
# 	var new_state_string: String = incoming_action.payload[GameAction.STATE]
# 	var new_state: STATE.ASSET = STATE.get_state_from_string(new_state_string)
# 	if !current_state_data.can_transition(new_state):
# 		# can transition already has logged a warning about the failure
# 		return
# 	var new_state_tracking: bool = StateUtil.is_tracking(new_state)
# 	var current_state_tracking: bool = StateUtil.is_tracking(current_state)
# 	if new_state_tracking != current_state_tracking:
# 		if new_state_tracking:
# 			self._handle_transition_to_track()
# 	if !current_state_data.try_and_set(new_state):
# 		Logger.error(self._UPDATE_FAILED, [current_state_string, new_state_string], self)
# 		return

# func _handle_transition_to_track() -> void:
# 	var camera_state_data: StateData = asset_state.get_state_data()
# 	var focused_guid: String = camera_state_data.get_focus_guid()
# 	if focused_guid.strip_edges().is_empty():
# 		Logger.error(self._ILLEGAL_STATE, [self._TRACKING_GUID], self)
# 		return
# 	var focused_state_data: StateData = GlobalStateController.get_header_data(focused_guid, StateHeaders.TYPE.DATA)
# 	var focus_position: Vector3 = focused_state_data.get_current_position()
# 	var offset_vector: Vector3 = Vector3(0, GameConfig.DEFAULTS.controller_height, GameConfig.DEFAULTS.controller_distance)
# 	self.camera_controller.position = focus_position + offset_vector
# 	self.camera_controller.look_at(focus_position)


