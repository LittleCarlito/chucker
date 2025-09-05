extends Node3D
class_name CameraRig

# Break camera down into multiple extension classes and have these up the path with the functions that make sense
@export var integration_point: Node3D
@export var camera_controller: Node3D
@export var internal_camera: Camera3D
@export var freelook_enabled: bool = true
@export var freelook_sensitivity: float = 0.07
@export var freelook_pitch_limit: float = 85.0 # degrees
@export var enable_rig_movement: bool = true
@export var tracking_mode: GlobalCameraController.TrackingMode = GlobalCameraController.TrackingMode.FULL
@export var min_height: float = -NUMBERS.FLOAT16_MAX
@export var is_idle_rotate: bool = false

var is_focused: bool
var _freelook_pitch: float = 0.0 # vertical angle
var _freelook_yaw: float = 0.0   # horizontal angle
var _min_height_warn: bool = false
var _is_sprinting: bool = false

var is_primary_freelook: bool
var is_secondary_freelook: bool
var is_zoom: bool = false

func _ready(
			incoming_current: bool = false,
			incoming_integration: Node3D = null,
			incoming_focus: bool = false, 
			incoming_primary_enabled: bool = false,
			incoming_secondary_enabled: bool = false,
			incoming_zoom_enabled: bool = false
			) -> void:
	self._maintain_distance()
	if incoming_current:
		self.make_current()
	if incoming_integration != null:
		self.integration_point = incoming_integration
	self.is_focused = incoming_focus
	self.is_primary_freelook = incoming_primary_enabled
	self.is_secondary_freelook = incoming_secondary_enabled
	self.is_zoom = incoming_zoom_enabled
	# Camera signal connections
	GlobalCameraController.connect(SIGNAL_NAME.REQUEST_CAMERA, _handle_camera_request)
	GlobalCameraController.connect(SIGNAL_NAME.CHANGE_MODE, change_mode)
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

func _process(_delta: float) -> void:
	if is_focused && integration_point != null:
		self._maintain_distance()
		self.focus_camera()

func _physics_process(_delta: float) -> void:
	var is_height_held: bool = false
	if self.min_height != -NUMBERS.FLOAT16_MAX:
		is_height_held = self.min_height > self.camera_controller.global_position.y
		self.camera_controller.global_position.y = max(self.min_height, self.camera_controller.global_position.y)
	if is_height_held and not _min_height_warn:
		push_warning("Camera rig height being force held")
		self._min_height_warn = true

func idle_rotate(delta: float, rotation_speed: float = CameraConfig.get_idle_rotate_speed()) -> void:
	var rotation_amount: float = delta * rotation_speed
	self.pan_horizontal(rotation_amount)

func pan_horizontal(rotation_amount: float) -> void:
	self._freelook_yaw += rotation_amount
	self._update_camera_position()

func pitch_vertical(rotation_amount: float) -> void:
	self._freelook_pitch = clamp(
		self._freelook_pitch + rotation_amount,
		-deg_to_rad(self.freelook_pitch_limit),
		deg_to_rad(self.freelook_pitch_limit)
	)
	_update_camera_position()

func move_up() -> void:
	pass

func move_down() -> void:
	pass

func move_left() -> void:
	pass

func move_right() -> void:
	pass

func set_integration_point(focus_node: Node3D, incoming_focus: bool = false) -> void:
	self.integration_point = focus_node
	if incoming_focus:
		self.enable_focus()

func get_integration_point() -> Node3D:
	return self.integration_point

func deintegrate() -> void:
	self.integration_point = Node3D.new()

func is_current() -> bool:
	return self.internal_camera.is_current()

func make_current() -> void:
	self.internal_camera.make_current()

func clear_current() -> void:
	self.internal_camera.clear_current()

func focus_camera() -> void:
	if self.integration_point != null:
		var focus_vector: Vector3 = self.integration_point.position
		self.camera_controller.look_at(focus_vector)
	else:
		push_warning("No integration point for rig to focus on")

func set_tracking_mode(mode: GlobalCameraController.TrackingMode) -> void:
	self.tracking_mode = mode

func get_tracking_mode() -> GlobalCameraController.TrackingMode:
	return self.tracking_mode

func is_idling() -> bool:
	return self.is_idle_rotate

func set_idle_rotate(incoming_value: bool) -> void:
	self.is_idle_rotate = incoming_value

func is_focusing() -> bool:
	return self.is_focused

func enable_focus() -> void:
	self.is_focused = true

func reset_focus() -> void:
	self.is_focused = false

func is_primary_freelook_enabled() -> bool:
	return self.is_primary_freelook

func enable_primary_freelook() -> void:
	self.is_primary_freelook = true

func disable_primary_freelook() -> void:
	self.is_primary_freelook = false

func is_secondary_freelook_enabled() -> bool:
	return self.is_secondary_freelook

func enable_secondary_freelook() -> void:
	self.is_secondary_freelook = true

func disable_secondary_freelook() -> void:
	self.is_secondary_freelook = false

func is_zoom_eanbled() -> bool:
	return self.is_zoom

func enable_zoom() -> void:
	self.is_zoom = true

func disable_zoom() -> void:
	self.is_zoom = false

func change_mode(incoming_mode: GlobalCameraController.TrackingMode) -> void:
	self.tracking_mode = incoming_mode

func get_min_height() -> float:
	return self.min_height

func set_min_height(incoming_min: float) -> void:
	Logger.debug("Incoming new min height is %f", [incoming_min], self)
	self.min_height = incoming_min

func _apply_min_height_constraint(position: Vector3) -> Vector3:
	if self.min_height != -NUMBERS.FLOAT16_MAX:
		position.y = max(self.min_height, position.y)
	return position

func _maintain_distance() -> void:
	if integration_point != null:
		var new_position: Vector3
		if self.tracking_mode == GlobalCameraController.TrackingMode.FULL:
			# Apply offset in local space relative to integration point's orientation
			var offset = Vector3(0, GameConfig.DEFAULTS.controller_height, GameConfig.DEFAULTS.controller_distance)
			var world_offset = self.integration_point.global_transform.basis * offset
			# Set position and rotation to follow integration point with offset
			new_position = self.integration_point.global_position + world_offset
			self.camera_controller.global_position = _apply_min_height_constraint(new_position)
			self.camera_controller.global_rotation = self.integration_point.global_rotation
		elif self.tracking_mode == GlobalCameraController.TrackingMode.POSITION:
			# Apply offset in world space, maintain current orientation
			var offset = Vector3(0, GameConfig.DEFAULTS.controller_height, GameConfig.DEFAULTS.controller_distance)
			new_position = self.integration_point.global_position + offset
			self.camera_controller.global_position = _apply_min_height_constraint(new_position)
		elif self.tracking_mode == GlobalCameraController.TrackingMode.TRACK:
			# TRACK mode: maintain spherical coordinates around the moving integration point
			_update_camera_position()
	else:
		push_warning("No integration point to maintain distance from")

func _update_camera_position() -> void:
	if tracking_mode == GlobalCameraController.TrackingMode.TRACK and self.integration_point != null:
		# TRACK mode: position camera in spherical coordinates around the moving integration point
		var radius: float = GameConfig.DEFAULTS.controller_distance
		var offset := Vector3(
			radius * cos(self._freelook_pitch) * sin(self._freelook_yaw),
			radius * sin(self._freelook_pitch),
			radius * cos(self._freelook_pitch) * cos(self._freelook_yaw)
		)
		var new_position = self.integration_point.global_position + offset
		self.camera_controller.global_position = _apply_min_height_constraint(new_position)
		self.camera_controller.look_at(self.integration_point.global_position, Vector3.UP)
	elif is_focused and self.integration_point != null:
		# Focused mode: position camera in spherical coordinates around focus point
		var radius: float = GameConfig.DEFAULTS.controller_distance
		var offset := Vector3(
			radius * cos(self._freelook_pitch) * sin(self._freelook_yaw),
			radius * sin(self._freelook_pitch),
			radius * cos(self._freelook_pitch) * cos(self._freelook_yaw)
		)
		var new_position = self.integration_point.global_position + offset
		self.camera_controller.global_position = _apply_min_height_constraint(new_position)
		self.camera_controller.look_at(self.integration_point.global_position, Vector3.UP)
	else:
		# Free freelook (no integration point)
		var yaw_basis := Basis(Vector3.UP, self._freelook_yaw)
		var pitch_basis := Basis(Vector3.RIGHT, self._freelook_pitch)
		self.camera_controller.transform.basis = yaw_basis * pitch_basis

func _handle_input() -> void:
	if (self.freelook_enabled and not self.is_focused) || self.tracking_mode == GlobalCameraController.TrackingMode.TRACK:
		var cursor_reasoning: String = "Camera rig is in freelook or tracking state"
		if GlobalCursorController.get_current_state() == GlobalCursorController.CursorState.CAPTURED:
			GlobalCursorController.request_state(self, GlobalCursorController.CursorState.VISIBLE, cursor_reasoning)
		elif GlobalCursorController.get_current_state() == GlobalCursorController.CursorState.VISIBLE:
			GlobalCursorController.request_state(self, GlobalCursorController.CursorState.CAPTURED, cursor_reasoning)

func _handle_freelook(v_motion: float, h_motion: float) -> void:
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		var inversion_multiplier: int = 1 if self.tracking_mode == GlobalCameraController.TrackingMode.TRACK else -1
		self.pan_horizontal((h_motion * freelook_sensitivity) * inversion_multiplier) 
		self.pitch_vertical((v_motion * freelook_sensitivity) * inversion_multiplier)

func _handle_camera_request(new_foucs: Node3D) -> void:
	self.set_integration_point(new_foucs, true)

func _handle_rig_focus(incoming_value: bool) -> void:
	self.is_focused = incoming_value

func _handle_up_input(_delta: float) -> void:
	if self.enable_rig_movement:
		var movement_amount: float = GameConfig.DEFAULTS.controller_speed
		self.camera_controller.global_position.y += movement_amount

func _handle_down_input(_delta: float) -> void:
	if self.enable_rig_movement:
		var movement_amount: float = GameConfig.DEFAULTS.controller_speed
		var new_position: Vector3 = self.camera_controller.global_position
		new_position.y -= movement_amount
		self.camera_controller.global_position = _apply_min_height_constraint(new_position)

func _handle_input_direction(incoming_direction: Vector2) -> void:
	if self.enable_rig_movement and incoming_direction != Vector2.ZERO:
		var speed: float = GameConfig.DEFAULTS.controller_speed
		if self._is_sprinting:
			speed *= GameConfig.DEFAULTS.sprint_multiplier
		var movement_vector: Vector3 = Vector3(incoming_direction.x, 0, incoming_direction.y) * speed
		var world_movement: Vector3 = self.camera_controller.global_transform.basis * movement_vector
		world_movement.y = 0
		var new_position: Vector3 = self.camera_controller.global_position + world_movement
		self.camera_controller.global_position = _apply_min_height_constraint(new_position)

func _handle_sprint_start() -> void:
	self._is_sprinting = true

func _handle_sprint_stop() -> void:
	self._is_sprinting = false
