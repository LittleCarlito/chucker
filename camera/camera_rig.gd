extends Node3D
class_name CameraRig

const _SELF: String = "Self"
const _FOCUS_NODE: String = "Focus node"
const _RIG_ACTION: String = "Rig focus action"
const _MISSING_GUID: String = "%s does not have a guid set in its data"
const _INTEGRATIN_DEBUG: String = "Now integrated with guid \"%s\" with focus set to \"%s\""
const _NO_INTEGRATION: String = "No integration point for rig to focus on"

const _MISSING_DATA: String = "Missing \"%s\" data"
# TODO Replace this usage with Log usage
const _UNSUPPORTED_TYPE: String  = "Incoming update type \"%s\" is not supported"
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
# TODO Ensure users of this use AssetStates (really StateData) ref instead
# @export var min_height: float = -NUMBERS.FLOAT16_MAX
@export var primary_freelook_enabled: bool
@export var secondary_freelook_enabled: bool
@export var zoom_enabled: bool
# TODO Now that this is a local resource again can probably move unique variables to it
#			Could enxtend the class to certain types to have them there to begin with
@export var asset_state: AssetState
# TODO Get rid of this; Should be able to use GlobalStateController to get anything via guid
var _focus_state: AssetState

# TODO OOOOO CONTINUE FROM HERE
# TODO 			Need to fix how Factory/Delivery creates things
#					need to create and use constructors here for creating and passing guids right away
#					Don't need to wait for delivery into the scene for branding; that should be part of constructors
# TODO Need a constructor that takes in the guid from the start
#		This way we don'g have asset state null issues in ready
#			Log as much stating that is the probable issue in ready


func _ready() -> void:
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

# TODO Figure out how to have this pushed down from state instead
#			Will probably require EVERYTHING functioning off state first to work though
func _physics_process(delta: float) -> void:
	RigResolver.resolve_for_frame(self, delta)

## Lerps to given position; Frame indpendent, usable in process and process_physics
func track_position(incoming_position: Vector3, delta: float) -> void:
	var lerp_speed: float = GameConfig.CAMERA.LERP_SPEED * delta
	var weighted_speed: float = 1 - exp(-lerp_speed)
	position = position.lerp(incoming_position, weighted_speed)
	# TODO Once confirmed it works delete below
	#			Above is supposed to be safer/improved version that can be used in process and process_physics (truely frame indpenedent)
	# var lerp_speed: float = GameConfig.CAMERA.LERP_SPEED * delta
	# position = position.lerp(incoming_position, lerp_speed)

## Sets state to idle rotate
func idle_rotate() -> void:
	var idle_state: STATE.ASSET = STATE.ASSET.IDLE_ROTATE
	if not asset_state.set_to_state(idle_state):
		var current_string: String = STATE.get_state_string(asset_state.get_current_state())
		var idle_string: String = STATE.get_state_string(idle_state)
		Log.error(_UPDATE_FAILED, [current_string, idle_string], self)

func pan_horizontal(rotation_amount: float) -> void:
	var pan_vector: Vector3 = Vector3(0, rotation_amount, 0)
	asset_state.apply_rotation(pan_vector)

func pitch_vertical(rotation_amount: float) -> void:
	var pitch_vector: Vector3 = Vector3(0, rotation_amount, 0)
	asset_state.apply_rotation(pitch_vector)

func focus_guid(incoming_guid: String) -> void:
	_focus_state = GlobalStateController.get_header_data(incoming_guid, StateHeaders.TYPE.DATA)

func track_guid(
		incoming_guid: String, 
		incoming_state: STATE.ASSET = STATE.ASSET.UNKNOWN
		) -> void:
	var action_dictionary: Dictionary = {
		GameAction.TARGET_GUID: incoming_guid
	}
	var state_string = STATE.get_state_string(incoming_state)
	if incoming_state != STATE.ASSET.UNKNOWN && asset_state.can_transition(incoming_state):
		action_dictionary[STATE.HEADER] = state_string
	var result_success: bool = asset_state.perform_action(GameAction.TYPE.TRACK, action_dictionary)
	if not result_success:
		var parameter_string: String = "Incoming GUID: %s; Incoming state: %s" % [incoming_guid, state_string]
		Log.error(Log.CALL_FAILED, [_SET_INTEGRATION, parameter_string], self)

## Retrieves the first tracked GUID
func get_integration_point() -> AssetState:
	return asset_state.get_first_tracked()

## Clears the integrated point and loses focus
func deintegrate(incoming_guid: String) -> void:
	asset_state.stop_tracking(incoming_guid)

func deintegrate_all() -> void:
	var tracked_guids: Array = asset_state.get_tracked_guids()
	for guid in tracked_guids:
		deintegrate(guid)

# TODO Test trying to set wrong state; ensure it doesn't work and logs
func transition_state(incoming_state: STATE.ASSET) -> void:
	var camera_state_data: StateData = asset_state.get_state_data()
	if camera_state_data == null:
		Log.error(Log._CANT_PERFORM, [_OWN_STATE, _TRANSITION_STATE], self)
		return
	var old_state: STATE.ASSET = camera_state_data.get_current_state()
	if camera_state_data.try_set_state(incoming_state):
		var from_state_string: String = STATE.get_state_string(old_state)
		var to_state_string: String = STATE.get_state_string(incoming_state)
		Log.debug(_SUCCESSFUL_TRANSITION, [from_state_string, to_state_string], self)

func get_asset_state() -> AssetState:
	if asset_state == null:
		_create_state(get_meta(GroupData.GUID))
	return asset_state

func get_focused_guid() -> String:
	return asset_state.get_focused_guid()

func get_current_state() -> STATE.ASSET:
	return asset_state.get_current_state()

func is_current() -> bool:
	return internal_camera.is_current()

func make_current() -> void:
	internal_camera.make_current()

func clear_current() -> void:
	internal_camera.clear_current()

func is_primary_freelook_enabled() -> bool:
	return primary_freelook_enabled

func enable_primary_freelook() -> void:
	primary_freelook_enabled = true

func disable_primary_freelook() -> void:
	primary_freelook_enabled = false

func is_secondary_freelook_enabled() -> bool:
	return secondary_freelook_enabled

func enable_secondary_freelook() -> void:
	secondary_freelook_enabled = true

func disable_secondary_freelook() -> void:
	secondary_freelook_enabled = false

func get_min_height() -> float:
	return asset_state.get_min_height()

func set_min_height(incoming_min: float) -> void:
	asset_state.set_min_height(incoming_min)

func get_camera_controller_height() -> float:
	return camera_controller.global_position.y

func set_camera_controller_height(incoming_height: float) -> void:
	camera_controller.global_position.y = incoming_height

func output_warning(incoming_warning: String) -> bool:
	return asset_state.output_warning(incoming_warning)

# TODO CONTINUE FROM HERE
# TODO Fix AssetDelivery to be AssetState based
# TODO refactor camera class to be cleaner
# TODO character over to being AssetState based
# TODO We need to get actions that take place in the game as a result of the character/objects to change state properly
# i.e. 
	# Freelooking without tracking
	# tracking on throw
	# tracking spawned disk from path disk
	# idle rotating on disk rest
	# return to character after throw idle
	# idle rotate character on idle sit
	# snap back to tracking on control usage

func _create_state(
					incoming_guid: String,
					incoming_transitions: Dictionary = {}, 
					incoming_values: Dictionary = {}, 
					incoming_windows: Dictionary = {}
				) -> void:
	asset_state = AssetState.new(incoming_guid, incoming_transitions, incoming_values, incoming_windows)
	asset_state.connect(SIGNAL_NAME.STATE_DATA_CHANGE, _handle_state_update)

# TODO Specify if mouse or keyboard (pretty sure its mouse)
# TODO Should be a lower class function after camera refactor
#		Higher class
func _handle_input() -> void:
	var camera_state_data: StateData = asset_state.get_state_data()
	if camera_state_data == null:
		Log.error(Log._CANT_PERFORM, [_OWN_STATE, _HANDLE_INPUT], self)
		return
	var current_state: STATE.ASSET = camera_state_data.get_current_state()
	if current_state >= STATE.ASSET.IS_TRACKING and current_state < STATE.ASSET.FREELOOK_STUCK:
		if GlobalCursorController.get_current_state() == GlobalCursorController.CursorState.CAPTURED:
			GlobalCursorController.request_state(self, GlobalCursorController.CursorState.VISIBLE, _FREELOOK_REASONING)
		elif GlobalCursorController.get_current_state() == GlobalCursorController.CursorState.VISIBLE:
			GlobalCursorController.request_state(self, GlobalCursorController.CursorState.CAPTURED, _FREELOOK_REASONING)

# TODO Should be a lower class function after camera refactor
#		Higher class
func _handle_freelook(v_motion: float, h_motion: float) -> void:
	var camera_state_data: StateData = asset_state.get_state_data()
	if camera_state_data == null:
		Log.error(Log._CANT_PERFORM, [_OWN_STATE, _HANDLE_FREELOOK], self)
		return
	var current_state: STATE.ASSET = camera_state_data.get_current_state()
	if current_state >= 550 and current_state <= 552:
		pan_horizontal(h_motion * freelook_sensitivity)
		pitch_vertical(v_motion * freelook_sensitivity)

# TODO Should be a lower class function after camera refactor
#		Higher class
func _handle_up_input(_delta: float) -> void:
	if asset_state.is_movement_enabled():
		var sprint_multiplier: float = _get_sprint_value(asset_state.is_sprinting())
		var movement_amount: float = GameConfig.DEFAULTS.controller_speed * sprint_multiplier
		var movement_vector: Vector3 = Vector3(0, movement_amount, 0)
		asset_state.apply_movement(movement_vector)

# TODO Should be a lower class function after camera refactor
#		Higher class
func _handle_down_input(_delta: float) -> void:
	if asset_state.is_movement_enabled():
		var sprint_multiplier: float = _get_sprint_value(asset_state.is_sprinting())
		var movement_amount: float = -(GameConfig.DEFAULTS.controller_speed * sprint_multiplier)
		var movement_vector: Vector3 = Vector3(0, movement_amount, 0)
		asset_state.apply_movement(movement_vector)

# TODO Should be a lower class function after camera refactor
#		Higher class
func _handle_input_direction(incoming_direction: Vector2) -> void:
	if asset_state.is_movement_enabled():
		var sprint_multiplier: float = _get_sprint_value(asset_state.is_sprinting())
		var x_amount = incoming_direction.x * sprint_multiplier
		var y_amount = incoming_direction.y * sprint_multiplier
		var movement_vector: Vector3 = Vector3(x_amount, 0, y_amount)
		asset_state.apply_movement(movement_vector)

# BUG right now only up and down inputs are workign
func _get_sprint_value(is_sprinting: bool) -> float:
	var sprint_value: float = 1.0
	if is_sprinting:
		sprint_value = GameConfig.DEFAULTS.sprint_multiplier
	return sprint_value

# TODO Should be a lower class function after camera refactor
#		Lowest class
func _handle_sprint_start() -> void:
	asset_state.start_sprinting()

# TODO Should be a lower class function after camera refactor
#		Lowest class
func _handle_sprint_stop() -> void:
	asset_state.stop_sprinting()

func apply_tracking_distance() -> void:
	camera_controller.position = GameConfig.CAMERA.TRACKING_POSITION

func remove_tracking_distance() -> void:
	camera_controller.position = GameConfig.EMPTY_VECTOR

func apply_crouching_distance() -> void:
	camera_controller.position = GameConfig.CAMERA.CROUCHING_POSITION

func remove_crouching_distance() -> void:
	camera_controller.position = GameConfig.EMPTY_VECTOR
	
func _handle_state_update(incoming_update: StateUpdate) -> void:
	var update_type: STATE.UPDATE_TYPE = incoming_update.get_update_type()
	match update_type:
		STATE.UPDATE_TYPE.FOCUS:
			RigResolver.resolve_focus(self, incoming_update)
		STATE.UPDATE_TYPE.ROTATION:
			TransformResolver.resolve_rotation(self, asset_state.get_current_rotation())
		STATE.UPDATE_TYPE.POSITION:
			TransformResolver.resolve_position(self, asset_state.get_current_position())
		STATE.UPDATE_TYPE.SCALE:
			TransformResolver.resolve_scale(self, asset_state.get_current_scale())
		STATE.UPDATE_TYPE.STATE:
			RigResolver.resolve_state(self, incoming_update)
		STATE.UPDATE_TYPE.TOGGLE:
			RigResolver.resolve_toggles(self, incoming_update.get_update_details())
		_:
			var update_string: String = STATE.get_update_type_string(update_type)
			Log.error(Log.UNSUPPORTED_TYPE_LOG, [_HANDLE_STATE_UPDATE, update_string], self)
