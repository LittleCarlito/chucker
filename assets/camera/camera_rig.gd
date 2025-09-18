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

# TODO Break camera down into multiple extension classes and have these up the path with the functions that make sense
# TODO Move majority of this to state
# Below stays
@export var camera_controller: Node3D
@export var internal_camera: Camera3D
@export var freelook_sensitivity: float = 0.07
@export var freelook_pitch_limit: float = 85.0 # degrees
@export var min_height: float = -NUMBERS.FLOAT16_MAX
@export var primary_freelook_enabled: bool
@export var secondary_freelook_enabled: bool
@export var zoom_enabled: bool
@export var movement_enabled: bool
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

# TODO Shouldn't exist after state refactor; look below shoudl ahve state pushing down everythign we need
func _process(_delta: float) -> void:
	#if is_focused && integration_point != null:
	self._maintain_distance()
	self.focus_on_target()

# TODO Not sure on this one; Might still need after state refactor to hold height
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

# TODO Redo to just be setting state of camera instead
func idle_rotate(delta: float, rotation_speed: float = CameraConfig.get_idle_rotate_speed()) -> void:
	var rotation_amount: float = delta * rotation_speed
	self.pan_horizontal(rotation_amount)

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
		# TODO Need to get current state and "pitch" for the clamp below
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
		Logger.warn(self._NO_INTEGRATION, [], self)

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

# TODO Have all this run through state somehow instead
#			Probably have state push down details to camera, so it will have all it needs as parameters
func _maintain_distance() -> void:
	if _focus_node != null:
		if self._verify_integrity():
			var new_position: Vector3
			var current_state: StateConfiguration.STATE = self._get_camera_state()
			if current_state == StateConfiguration.STATE.FULL_TRACKING:
				# Apply offset in local space relative to integration point's orientation
				var offset = Vector3(0, GameConfig.DEFAULTS.controller_height, GameConfig.DEFAULTS.controller_distance)
				var world_offset = self._focus_node.global_transform.basis * offset
				# Set position and rotation to follow integration point with offset
				new_position = self._focus_node.global_position + world_offset
				self.camera_controller.global_position = self._apply_min_height_constraint(new_position)
				self.camera_controller.global_rotation = self._focus_node.global_rotation
			elif current_state == StateConfiguration.STATE.POS_TRACKING:
				# Apply offset in world space, maintain current orientation
				var offset = Vector3(0, GameConfig.DEFAULTS.controller_height, GameConfig.DEFAULTS.controller_distance)
				new_position = self._focus_node.global_position + offset
				self.camera_controller.global_position = self._apply_min_height_constraint(new_position)
			elif current_state == StateConfiguration.STATE.FREE_TRACKING:
				# TRACK mode: maintain spherical coordinates around the moving integration point
				self._update_camera_position()
	else:
		Logger.warn(self._NO_INTEGRATION, [], self)

# TODO Again like above function should be having everything it needs pushed down from state
func _update_camera_position() -> void:
	if self._verify_integrity():
		var camera_state: StateData = GlobalStateController.get_header_data(self.get_meta(GroupData.GUID), StateHeaders.TYPE.DATA)
		var current_state: StateConfiguration.STATE = camera_state.get_current_state()
		if current_state == StateConfiguration.STATE.FREE_TRACKING and self._focus_node != null:
			# TRACK mode: position camera in spherical coordinates around the moving integration point
			var radius: float = GameConfig.DEFAULTS.controller_distance
			var offset: Vector3 = Vector3(
				radius * cos(self._freelook_pitch) * sin(self._freelook_yaw),
				radius * sin(self._freelook_pitch),
				radius * cos(self._freelook_pitch) * cos(self._freelook_yaw)
			)
			var new_position: Vector3 = self._focus_node.global_position + offset
			self.camera_controller.global_position = self._apply_min_height_constraint(new_position)
			self.camera_controller.look_at(self._focus_node.global_position, Vector3.UP)
		# TODO Swap this to be GlobalState based instead
		elif camera_state.is_focused and self._focus_node != null:
			# Focused mode: position camera in spherical coordinates around focus point
			var radius: float = GameConfig.DEFAULTS.controller_distance
			var offset: Vector3 = Vector3(
				radius * cos(self._freelook_pitch) * sin(self._freelook_yaw),
				radius * sin(self._freelook_pitch),
				radius * cos(self._freelook_pitch) * cos(self._freelook_yaw)
			)
			var new_position: Vector3 = self._focus_node.global_position + offset
			self.camera_controller.global_position = _apply_min_height_constraint(new_position)
			self.camera_controller.look_at(self._focus_node.global_position, Vector3.UP)
		else:
			# Free freelook (no integration point)
			var yaw_basis: Basis = Basis(Vector3.UP, self._freelook_yaw)
			var pitch_basis: Basis = Basis(Vector3.RIGHT, self._freelook_pitch)
			self.camera_controller.transform.basis = yaw_basis * pitch_basis

func _apply_min_height_constraint(position: Vector3) -> Vector3:
	if self.min_height != -NUMBERS.FLOAT16_MAX:
		position.y = max(self.min_height, position.y)
	return position

func _handle_input() -> void:
	if self._verify_integrity():
		var camera_state_data: CameraStateData = GlobalStateController.get_header_data(self.get_meta(GroupData.GUID), StateHeaders.TYPE.DATA)
		var current_state: StateConfiguration.STATE = camera_state_data.get_current_state()
		if current_state >= StateConfiguration.STATE.IS_TRACKING and current_state < StateConfiguration.STATE.FREELOOK_STUCK:
			if GlobalCursorController.get_current_state() == GlobalCursorController.CursorState.CAPTURED:
				GlobalCursorController.request_state(self, GlobalCursorController.CursorState.VISIBLE, self._FREELOOK_REASONING)
			elif GlobalCursorController.get_current_state() == GlobalCursorController.CursorState.VISIBLE:
				GlobalCursorController.request_state(self, GlobalCursorController.CursorState.CAPTURED, self._FREELOOK_REASONING)

func _handle_freelook(v_motion: float, h_motion: float) -> void:
	if GlobalCursorController.is_captured_current():
		var inversion_multiplier: int = 1 if self._is_camera_tracking() else -1
		self.pan_horizontal((h_motion * freelook_sensitivity) * inversion_multiplier) 
		self.pitch_vertical((v_motion * freelook_sensitivity) * inversion_multiplier)

func _handle_camera_request(new_foucs: Node3D) -> void:
	self.set_integration_point(new_foucs, true)

func _handle_rig_focus(incoming_value: bool) -> void:
	self.is_focused = incoming_value

func _handle_up_input(_delta: float) -> void:
	pass
	#if self.enable_rig_movement:
		#var movement_amount: float = GameConfig.DEFAULTS.controller_speed
		#self.camera_controller.global_position.y += movement_amount

func _handle_down_input(_delta: float) -> void:
	pass
	#if self.enable_rig_movement:
		#var movement_amount: float = GameConfig.DEFAULTS.controller_speed
		#var new_position: Vector3 = self.camera_controller.global_position
		#new_position.y -= movement_amount
		#self.camera_controller.global_position = _apply_min_height_constraint(new_position)

func _handle_input_direction(incoming_direction: Vector2) -> void:
	pass
	#if self.enable_rig_movement and incoming_direction != Vector2.ZERO:
		#var speed: float = GameConfig.DEFAULTS.controller_speed
		#if self._is_sprinting:
			#speed *= GameConfig.DEFAULTS.sprint_multiplier
		#var movement_vector: Vector3 = Vector3(incoming_direction.x, 0, incoming_direction.y) * speed
		#var world_movement: Vector3 = self.camera_controller.global_transform.basis * movement_vector
		#world_movement.y = 0
		#var new_position: Vector3 = self.camera_controller.global_position + world_movement
		#self.camera_controller.global_position = _apply_min_height_constraint(new_position)

func _handle_sprint_start() -> void:
	pass
	#self._is_sprinting = true

func _handle_sprint_stop() -> void:
	pass
	#self._is_sprinting = false

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

func _handle_transform(incoming_action: GameAction) -> void:
	if self._verify_integrity():
		var missing_transform_keys: Array[String] = StateUtil.get_missing_keys(incoming_action.payload, [GameAction.ROTATION, GameAction.POSITION, GameAction.SCALE])
		if missing_transform_keys.size() < 3:
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

func _handle_set_rig_focus(incoming_action: GameAction) -> void:
	if incoming_action.payload.has(GameAction.TARGET_GUID):
		var focus_guid: String = incoming_action.payload.get(GameAction.TARGET_GUID)
		self.focus_guid(focus_guid)
	else:
		Logger.error(self._MISSING_GUID, [self.SET_RIG_FOCUS], self)

func _verify_integrity() -> bool:
	if !self.has_meta(GroupData.GUID):
		Logger.error(self._MISSING_DATA, [GroupData.GUID], self)
		return false
	return true

func _get_camera_state() -> StateConfiguration.STATE:
	var camera_state_data: CameraStateData = GlobalStateController.get_header_data(self.get_meta(GroupData.GUID), StateHeaders.TYPE.DATA)
	return camera_state_data.get_current_state()

func _is_camera_tracking() -> bool:
	var current_state: StateConfiguration.STATE = self._get_camera_state()
	return (current_state >= 500 and current_state <= 503)
