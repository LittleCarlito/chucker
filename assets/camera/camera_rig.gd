extends Node3D
class_name CameraRig

const _SELF: String = "Self"
const _FOCUS_NODE: String = "Focus node"
const _RIG_ACTION: String = "Rig focus action"
const _MISSING_GUID: String = "%s does not have a guid set in its data"
const _INTEGRATIN_DEBUG: String = "Now integrated with guid \"%s\" with focus set to \"%s\""
const _NO_INTEGRATION: String = "No integration point for rig to focus on"

const _MISSING_DATA: String = "Missing %s data"
const _MIN_HEIGHT_WARN: String = "Is now having its height artificially held to min height of \"%f\""
const _SUCCESSFUL_TRANSITION: String = "Successfully transitioned from \"%s\" state to \"%s\""
const _FREELOOK_REASONING: String = "Camera rig is in freelook or tracking state"
const _INVALID_STATE: String = "Invalid state configuration; %s"
const _FOCUSED_NO_GUID: String = "State is TRACKING but there is no guid to focus on"

# TODO OOOOO
# TODO Freelook working but needs tweaking
# TODO Then get tracking working
# TODO Then do rest of todos in file

# TODO Break camera down into multiple extension classes and have these up the path with the functions that make sense
# TODO Move majority of this to state
# Below stays
@export var camera_controller: Node3D
@export var internal_camera: Camera3D
@export var freelook_sensitivity: float = 2.0
@export var freelook_pitch_limit: float = 85.0 # degrees
@export var min_height: float = -NUMBERS.FLOAT16_MAX
@export var primary_freelook_enabled: bool
@export var secondary_freelook_enabled: bool
@export var zoom_enabled: bool
# TODO Really this (and probably above ones too) should just be based off what state it is in
@export var movement_enabled: bool
# TODO Get rid of this; Should be able to use GlobalStateController to get anything via guid
var _focus_node: Node3D

func _ready() -> void:
	self._maintain_distance()
	# Camera signal connections
	GlobalCameraController.connect(SIGNAL_NAME.REQUEST_CAMERA, _handle_camera_request)
	GlobalCameraController.connect(SIGNAL_NAME.IS_FOCUSING, _handle_rig_focus)
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
	GlobalStateController.connect(SIGNAL_NAME.STATE_UPDATED, _handle_state_updated)

# TODO Figure out how to have this pushed down from state instead
#			Will probably require EVERYTHING functioning off state first to work though
func _process(_delta: float) -> void:
	#if is_focused && integration_point != null:
	self._maintain_distance()
	self.focus_on_target()

# TODO Figure out how to have this pushed down from state instead
#			Will probably require EVERYTHING functioning off state first to work though
func _physics_process(_delta: float) -> void:
	if self.min_height != -NUMBERS.FLOAT16_MAX:
		var is_height_held: bool = self.min_height > self.camera_controller.global_position.y
		self.camera_controller.global_position.y = max(self.min_height, self.camera_controller.global_position.y)
		if is_height_held && self._verify_integrity():
			var height_warning: String = self._MIN_HEIGHT_WARN % self.min_height
			var warn_payload: Dictionary = {
				GameAction.OWNER_GUID: self.get_meta(GroupData.GUID),
				GameAction.MESSAGE: height_warning
			}
			var warn_action: GameAction = GameAction.new(GameAction.TYPE.WARN, warn_payload)
			GlobalStateController.dispatch(warn_action)

## Sets state to idle rotate
func idle_rotate(delta: float, rotation_speed: float = CameraConfig.get_idle_rotate_speed()) -> void:
	if self._verify_integrity():
		var self_guid: String = self.get_meta(GroupData.GUID)
		var rotation_amount: float = delta * rotation_speed
		var idle_string: String = StateConfiguration.get_state_string(StateConfiguration.STATE.IDLE_ROTATE)
		var idle_action_dictionary: Dictionary = {
			GameAction.OWNER_GUID: self_guid,
			GameAction.STATE: idle_string
		}
		var idle_action: GameAction = GameAction.new(GameAction.TYPE.SET_STATE, idle_action_dictionary)
		GlobalStateController.dispatch(idle_action)

func pan_horizontal(rotation_amount: float) -> void:
	if self._verify_integrity():
		var rotation_dictionary: Dictionary = {
			GameAction.Y: rotation_amount
		}
		var rotation_action_dictionary: Dictionary = {
			GameAction.OWNER_GUID: self.get_meta(GroupData.GUID),
			GameAction.ROTATION: rotation_dictionary
		}
		var rotation_action: GameAction = GameAction.new(GameAction.TYPE.TRANSFORM, rotation_action_dictionary)
		GlobalStateController.dispatch(rotation_action)

func pitch_vertical(rotation_amount: float) -> void:
	if self._verify_integrity():
		var self_guid: String = self.get_meta(GroupData.GUID)
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

func set_integration_point(incoming_node: Node3D, incoming_focus: bool) -> void:
	# Focus node in state
	if self._verify_integrity():
		if incoming_node.has_meta(GroupData.GUID):
			var integrate_action_dictionary: Dictionary = {
				GameAction.OWNER_GUID: self.get_meta(GroupData.GUID),
				GameAction.TARGET_GUID: incoming_node.get_meta(GroupData.GUID)
			}
			var integrate_action: GameAction = GameAction.new(GameAction.TYPE.SET_RIG_FOCUS, integrate_action_dictionary)
			GlobalStateController.dispatch(integrate_action)
			self._focus_node = incoming_node
		else:
			var focus_identifier: String = self._FOCUS + " " + "\"" + incoming_node.name + "\""
			Logger.error(self._MISSING_GUID, [focus_identifier], self)
			return
	# Update the camrea state to the incoming_focus value
	if incoming_focus:
		var focus_action_dictionary: Dictionary = {
			GameAction.OWNER_GUID: self.get_meta(GroupData.GUID),
			GameAction.FOCUS_RIG: incoming_focus
		}
		var focus_action: GameAction = GameAction.new(GameAction.TYPE.FOCUS_RIG, focus_action_dictionary)
		GlobalStateController.dispatch(focus_action)
	else:
		Logger.error(self._MISSING_GUID, [self._SELF], self)
		return
	# Log results; If made it here has GUID meta
	Logger.debug(self._INTEGRATIN_DEBUG, [incoming_node.get_meta(GroupData.GUID), incoming_focus], self)

func get_integration_point() -> Node3D:
	return self._focus_node

## Clears the integrated point and loses focus
func deintegrate() -> void:
	if self._verify_integrity():
		# lose integration in state
		var lose_integration_dictionary: Dictionary = {
			GameAction.OWNER_GUID: self.get_meta(GroupData.GUID),
			GameAction.TARGET_GUID: GroupData.EMPTY
		}
		var lose_integration_action: GameAction = GameAction.new(self.get_meta(GroupData.GUID), lose_integration_dictionary)
		GlobalStateController.dispatch(lose_integration_action)
		# lose focus in state
		self.set_focus(false)
		# Clear internal reference
		self._focus_node = null

# TODO Test trying to set wrong state; ensure it doesn't work and logs
func transition_state(incoming_state: StateConfiguration.STATE) -> void:
	if self._verify_integrity():
		var camera_guid: String = self.get_meta(GroupData.GUID)
		var camera_state_data: CameraStateData = GlobalStateController.get_header_data(camera_guid, StateHeaders.TYPE.DATA)
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

func focus_on_target() -> void:
	if self._focus_node != null:
		var focus_vector: Vector3 = self._focus_node.position
		self.camera_controller.look_at(focus_vector)
	else:
		# TODO Create a debug toggle
		# TODO Make sure these debug toggles reset on new focus/lose focus
		# Logger.warn(self._NO_INTEGRATION, [], self)
		pass
		
func set_tracking_mode(mode: GlobalCameraController.TrackingMode) -> void:
	self.tracking_mode = mode

func get_tracking_mode() -> GlobalCameraController.TrackingMode:
	return self.tracking_mode

func is_idling() -> bool:
	return self.is_idle_rotate

func set_idle_rotate(incoming_value: bool) -> void:
	self.is_idle_rotate = incoming_value

func set_focus(incoming_value: bool) -> void:
	var set_focus_dictionary: Dictionary = {
		GameAction.OWNER_GUID: self.get_meta(GroupData.GUID),
		GameAction.FOCUS_RIG : false
	}
	var set_focus_action: GameAction = GameAction.new(GameAction.TYPE.FOCUS_RIG, set_focus_dictionary)
	GlobalStateController.dispatch(set_focus_action)

func is_focusing() -> bool:
	if self._verify_integrity():
		var self_guid: String = self.get_meta(GroupData.GUID)
		var camera_state_data: CameraStateData = GlobalStateController.get_header_data(self_guid, StateHeaders.TYPE.DATA)
		return camera_state_data.is_focused()
	return false

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

# TODO Should be a lower class function after camera refactor
#		Lowest class
func _maintain_distance() -> void:
	if _focus_node != null:
		if self._verify_integrity():
			var new_position: Vector3
			var current_state: StateConfiguration.STATE = self._get_camera_state()
			if current_state == StateConfiguration.STATE.TRACKING_FULL:
				# Apply offset in local space relative to integration point's orientation
				var offset = Vector3(0, GameConfig.DEFAULTS.controller_height, GameConfig.DEFAULTS.controller_distance)
				var world_offset = self._focus_node.global_transform.basis * offset
				# Set position and rotation to follow integration point with offset
				new_position = self._focus_node.global_position + world_offset
				self.camera_controller.global_position = self._apply_min_height_constraint(new_position)
				self.camera_controller.global_rotation = self._focus_node.global_rotation
			elif current_state == StateConfiguration.STATE.TRACKING_POS:
				# Apply offset in world space, maintain current orientation
				var offset = Vector3(0, GameConfig.DEFAULTS.controller_height, GameConfig.DEFAULTS.controller_distance)
				new_position = self._focus_node.global_position + offset
				self.camera_controller.global_position = self._apply_min_height_constraint(new_position)
			elif current_state == StateConfiguration.STATE.TRACKING_FREE:
				# TRACK mode: maintain spherical coordinates around the moving integration point
				self._update_camera_position()
	else:
		# TODO Create a debug toggle
		# TODO Make sure these debug toggles reset on new focus/lose focus
		# Logger.warn(self._NO_INTEGRATION, [], self)
		pass

# TODO OOOOO
# TODO Below and Above need to be refactored to be using state object
#		Below also has gimbal lock issues that need addressing
#			But hopefully in the course of fixing this shit it will just resolve
#			If it is still there after fixing then address

# TODO Need to refactor name to track guid position
#			Have it just updating state
#		Then ensure this class has proper position/rotation/scale reaction shit to state updates
# TODO Should be a lower class function after camera refactor
#		Lowest class
func _update_camera_position() -> void:
	if self._verify_integrity():
		var camera_state: CameraStateData = GlobalStateController.get_header_data(self.get_meta(GroupData.GUID), StateHeaders.TYPE.DATA)
		var focused_guid: String = camera_state.get_focus_guid()
		var current_state: StateConfiguration.STATE = camera_state.get_current_state()
		if current_state >= 500 and current_state <= 503:
			if !focused_guid.is_empty():
				# TODO Need to have different behavior based off state
				var current_rotation: Quaternion = camera_state.get_current_rotation()
				var radius: float = GameConfig.DEFAULTS.controller_distance
				var base_offset: Vector3 = Vector3(0, 0, radius)
				var offset: Vector3 = current_rotation * base_offset
				var focus_node: Node3D = GlobalStateController.get_header_data(focused_guid, StateHeaders.TYPE.NODE)
				if focus_node != null:
					var new_position: Vector3 = focus_node.global_position + offset
					self.camera_controller.global_position = self._apply_min_height_constraint(new_position)
					self.camera_controller.look_at(focus_node.global_position, Vector3.UP)
			else:
				Logger.error(self._INVALID_STATE, [self._FOCUSED_NO_GUID], self)
				return
		else:
			# Free freelook (no integration point)
			var yaw_basis: Basis = Basis(Vector3.UP, self._freelook_yaw)
			var pitch_basis: Basis = Basis(Vector3.RIGHT, self._freelook_pitch)
			self.camera_controller.transform.basis = yaw_basis * pitch_basis

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
	if self._verify_integrity():
		var camera_state_data: CameraStateData = GlobalStateController.get_header_data(self.get_meta(GroupData.GUID), StateHeaders.TYPE.DATA)
		var current_state: StateConfiguration.STATE = camera_state_data.get_current_state()
		if current_state >= StateConfiguration.STATE.IS_TRACKING and current_state < StateConfiguration.STATE.FREELOOK_STUCK:
			if GlobalCursorController.get_current_state() == GlobalCursorController.CursorState.CAPTURED:
				GlobalCursorController.request_state(self, GlobalCursorController.CursorState.VISIBLE, self._FREELOOK_REASONING)
			elif GlobalCursorController.get_current_state() == GlobalCursorController.CursorState.VISIBLE:
				GlobalCursorController.request_state(self, GlobalCursorController.CursorState.CAPTURED, self._FREELOOK_REASONING)

# TODO Should be a lower class function after camera refactor
#		Higher class
func _handle_freelook(v_motion: float, h_motion: float) -> void:
	if self._verify_integrity():
		var self_guid: String = self.get_meta(GroupData.GUID)
		var camera_state_data: StateData = GlobalStateController.get_header_data(self_guid, StateHeaders.TYPE.DATA)
		var current_state: StateConfiguration.STATE = camera_state_data.get_current_state()
		if current_state >= 550 and current_state <= 552:
			var inversion_multiplier: int = 1 if self._is_camera_tracking() else -1
			self.pan_horizontal((h_motion * freelook_sensitivity) * inversion_multiplier) 
			self.pitch_vertical((v_motion * freelook_sensitivity) * inversion_multiplier)

# TODO Should be a lower class function after camera refactor
#		Lowest class
func _handle_camera_request(new_foucs: Node3D) -> void:
	self.set_integration_point(new_foucs, true)

# TODO Should be a lower class function after camera refactor
#		Lowest class
func _handle_rig_focus(incoming_value: bool) -> void:
	if self._verify_integrity():
		var self_guid: String = self.get_meta(GroupData.GUID)
		var focus_action_dictionary: Dictionary = {
			GameAction.OWNER_GUID: self_guid,
			GameAction.FOCUS_RIG: incoming_value
		}
		var focus_action: GameAction = GameAction.new(GameAction.TYPE.FOCUS_RIG, focus_action_dictionary)
		GlobalStateController.dispatch(focus_action)

# TODO Should be a lower class function after camera refactor
#		Higher class
func _handle_up_input(_delta: float) -> void:
	if self.movement_enabled and self._verify_integrity():
		var self_guid: String = self.get_meta(GroupData.GUID)
		var sprint_multiplier: float = self._get_sprint_value(self_guid)
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
	if self._verify_integrity():
		var self_guid: String = self.get_meta(GroupData.GUID)
		var sprint_multiplier: float = self._get_sprint_value(self_guid)
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
	if self.movement_enabled and self._verify_integrity():
		var self_guid: String = self.get_meta(GroupData.GUID)
		var sprint_multiplier: float = self._get_sprint_value(self_guid)
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
func _get_sprint_value(self_guid: String) -> float:
	var sprint_value: float = 1.0
	var camera_state_data: StateData = GlobalStateController.get_header_data(self_guid, StateHeaders.TYPE.DATA)
	if camera_state_data.is_sprinting():
		sprint_value = GameConfig.DEFAULTS.sprint_multiplier
	return sprint_value

# TODO Should be a lower class function after camera refactor
#		Lowest class
func _handle_sprint_start() -> void:
	if self._verify_integrity():
		var self_guid: String = self.get_meta(GroupData.GUID)
		var transform_action_dictionary: Dictionary = {
			GameAction.OWNER_GUID: self_guid,
			GameAction.IS_SPRINTING: GroupData.TRUE
		}
		var transform_action: GameAction = GameAction.new(GameAction.TYPE.TRANSFORM, transform_action_dictionary)
		GlobalStateController.dispatch(transform_action)

# TODO Should be a lower class function after camera refactor
#		Lowest class
func _handle_sprint_stop() -> void:
	if self._verify_integrity():
		var self_guid: String = self.get_meta(GroupData.GUID)
		var transform_action_dictionary: Dictionary = {
			GameAction.OWNER_GUID: self_guid,
			GameAction.IS_SPRINTING: GroupData.FALSE
		}
		var transform_action: GameAction = GameAction.new(GameAction.TYPE.TRANSFORM, transform_action_dictionary)
		GlobalStateController.dispatch(transform_action)

# TODO Should be a lower class function after camera refactor
#		Lowest class
func _handle_state_updated(update_details: Dictionary) -> void:
	if self._verify_integrity():
		var self_guid: String = self.get_meta(GroupData.GUID)
		if self_guid in update_details:
			var update_action: GameAction = update_details[self_guid]
			match update_action.action_type:
				GameAction.TYPE.SET_RIG_FOCUS:
					self._handle_set_rig_focus(update_action)
				GameAction.TYPE.TRANSFORM:
					self._handle_transform(update_action)
				_:
					var update_type_string: String = GameAction.get_type_string(update_action.action_type)
					Logger.warn("Incoming update type \"%s\" is not supported", [update_type_string], self)

# TODO Should be a lower class function after camera refactor
#		Lowest class
func _handle_transform(incoming_action: GameAction) -> void:
	if self._verify_integrity():
		var missing_transform_keys: Array[String] = StateUtil.get_missing_keys(incoming_action.payload, GameAction.TRANSFORM_KEYS)
		if missing_transform_keys.size() < GameAction.TRANSFORM_KEYS.size():
			var self_guid: String = self.get_meta(GroupData.GUID)
			var camera_state_data: StateData = GlobalStateController.get_header_data(self_guid, StateHeaders.TYPE.DATA)
			if incoming_action.payload.has(GameAction.ROTATION):
				var new_rotation: Quaternion = camera_state_data.get_current_rotation()
				self.transform.basis = Basis(new_rotation.normalized())
			if incoming_action.payload.has(GameAction.POSITION):
				var new_position: Vector3 = camera_state_data.get_current_position()
				self.position = new_position
			if incoming_action.payload.has(GameAction.SCALE):
				var new_scale: Vector3 = camera_state_data.get_current_scale()
				self.scale = new_scale
		else:
			var missing_transform_string: String = "; ".join(missing_transform_keys)
			Logger.error(Logger.BAD_ACTION_FORMAT, [incoming_action, missing_transform_string], self)

# TODO Should be a lower class function after camera refactor
#		Lowest class
func _handle_set_rig_focus(incoming_action: GameAction) -> void:
	if incoming_action.payload.has(GameAction.TARGET_GUID):
		var focus_guid: String = incoming_action.payload.get(GameAction.TARGET_GUID)
		self.focus_guid(focus_guid)
	else:
		Logger.error(self._MISSING_GUID, [self.SET_RIG_FOCUS], self)

# TODO Should be a lower class function after camera refactor
#		Lowest class
func _verify_integrity() -> bool:
	if !self.has_meta(GroupData.GUID):
		Logger.error(self._MISSING_DATA, [GroupData.GUID], self)
		return false
	return true

# TODO Should be a lower class function after camera refactor
#		Lowest class
func _get_camera_state() -> StateConfiguration.STATE:
	var camera_state_data: CameraStateData = GlobalStateController.get_header_data(self.get_meta(GroupData.GUID), StateHeaders.TYPE.DATA)
	return camera_state_data.get_current_state()

# TODO Should be a lower class function after camera refactor
#		Lowest class
func _is_camera_tracking() -> bool:
	var current_state: StateConfiguration.STATE = self._get_camera_state()
	return (current_state >= 500 and current_state <= 503)
