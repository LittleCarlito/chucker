extends Node3D
class_name CameraRig

@export var integration_point: Node3D
@export var camera_controller: Node3D
@export var internal_camera: Camera3D
@export var freelook_enabled: bool = true
@export var freelook_sensitivity: float = 0.07
@export var freelook_pitch_limit: float = 85.0 # degrees
@export var enable_rig_movement: bool = false
@export var tracking_mode: GlobalCameraController.TrackingMode = GlobalCameraController.TrackingMode.FULL
@export var min_height: float = -NUMBERS.FLOAT16_MAX

var is_focused: bool
var _freelook_pitch: float = 0.0 # vertical angle
var _freelook_yaw: float = 0.0   # horizontal angle
var _min_height_warn: bool = false

var is_primary_freelook: bool
var is_secondary_freelook: bool
var is_zoom: bool

# TODO Integrate with GlobalInputController for controls
#			Should just be enabled when enable_rig_movement

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
	# Input signal connections
	GlobalInputController.connect(SIGNAL_NAME.FREELOOK_MOTION, _handle_freelook)
	GlobalInputController.connect(SIGNAL_NAME.PRIMARY_ACTION, _handle_input)
	GlobalInputController.connect(SIGNAL_NAME.SECONDARY_ACTION, _handle_input)
	# TODO Get this to the newly created GlobalCursorController
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

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

func set_integration_point(focus_node: Node3D, incoming_focus: bool = false) -> void:
	self.integration_point = focus_node
	if incoming_focus:
		self.enable_focus()

func get_integration_point() -> Node3D:
	return self.integration_point

func deintegrate() -> void:
	# TODO Here is where you need to check if focus point existed
	#			If it did you need to disconnect all the signals
	self.integration_point = Node3D.new()

func is_current() -> bool:
	return self.internal_camera.is_current()

## Sets camera to current
func make_current() -> void:
	self.internal_camera.make_current()

## If camera is current makes it not current
func clear_current() -> void:
	self.internal_camera.clear_current()

func focus_camera() -> void:
	if integration_point != null:
		var focus_vector: Vector3 = self.integration_point.position
		camera_controller.look_at(focus_vector)
	else:
		push_warning("No integration point for rig to focus on")

func set_tracking_mode(mode: GlobalCameraController.TrackingMode) -> void:
	tracking_mode = mode

func get_tracking_mode() -> GlobalCameraController.TrackingMode:
	return tracking_mode

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
		if tracking_mode == GlobalCameraController.TrackingMode.FULL:
			# Apply offset in local space relative to integration point's orientation
			var offset = Vector3(0, GameConfig.DEFAULTS.controller_height, GameConfig.DEFAULTS.controller_distance)
			var world_offset = integration_point.global_transform.basis * offset
			# Set position and rotation to follow integration point with offset
			new_position = integration_point.global_position + world_offset
			camera_controller.global_position = _apply_min_height_constraint(new_position)
			camera_controller.global_rotation = integration_point.global_rotation
		elif tracking_mode == GlobalCameraController.TrackingMode.POSITION:
			# Apply offset in world space, maintain current orientation
			var offset = Vector3(0, GameConfig.DEFAULTS.controller_height, GameConfig.DEFAULTS.controller_distance)
			new_position = integration_point.global_position + offset
			camera_controller.global_position = _apply_min_height_constraint(new_position)
		elif tracking_mode == GlobalCameraController.TrackingMode.TRACK:
			# TRACK mode: maintain spherical coordinates around the moving integration point
			var radius: float = GameConfig.DEFAULTS.controller_distance
			var offset := Vector3(
				radius * cos(_freelook_pitch) * sin(_freelook_yaw),
				radius * sin(_freelook_pitch),
				radius * cos(_freelook_pitch) * cos(_freelook_yaw)
			)
			new_position = integration_point.global_position + offset
			camera_controller.global_position = _apply_min_height_constraint(new_position)
			camera_controller.look_at(integration_point.global_position, Vector3.UP)
	else:
		push_warning("No integration point to maintain distance from")

# TODO Get this to a GlobalCursorController have it based off state
func _handle_input() -> void:
	if (self.freelook_enabled and not self.is_focused) || self.tracking_mode == GlobalCameraController.TrackingMode.TRACK:
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		elif Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _handle_freelook(v_motion: float, h_motion: float) -> void:
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if tracking_mode == GlobalCameraController.TrackingMode.TRACK and integration_point != null:
			# TRACK mode: freelook controls camera around the moving object
			_freelook_yaw += h_motion * freelook_sensitivity
			_freelook_pitch = clamp(
				_freelook_pitch + v_motion * freelook_sensitivity,
				-deg_to_rad(freelook_pitch_limit),
				deg_to_rad(freelook_pitch_limit)
			)
			# Distance from focus point
			var radius: float = GameConfig.DEFAULTS.controller_distance
			# Convert yaw/pitch to a position in spherical coordinates around the moving integration point
			var offset := Vector3(
				radius * cos(_freelook_pitch) * sin(_freelook_yaw),
				radius * sin(_freelook_pitch),
				radius * cos(_freelook_pitch) * cos(_freelook_yaw)
			)
			# Set camera position relative to the current integration point position
			var new_position = integration_point.global_position + offset
			camera_controller.global_position = _apply_min_height_constraint(new_position)
			# Look at the focus point
			camera_controller.look_at(integration_point.global_position, Vector3.UP)
		elif is_focused and integration_point != null:
			# Update yaw and pitch
			_freelook_yaw += h_motion * freelook_sensitivity
			_freelook_pitch = clamp(
				_freelook_pitch + v_motion * freelook_sensitivity,
				-deg_to_rad(freelook_pitch_limit),
				deg_to_rad(freelook_pitch_limit)
			)
			# Distance from focus point
			var radius: float = GameConfig.DEFAULTS.controller_distance
			# Convert yaw/pitch to a position in spherical coordinates
			var offset := Vector3(
				radius * cos(_freelook_pitch) * sin(_freelook_yaw),
				radius * sin(_freelook_pitch),
				radius * cos(_freelook_pitch) * cos(_freelook_yaw)
			)
			# Set camera position relative to focus
			var new_position = integration_point.global_position + offset
			camera_controller.global_position = _apply_min_height_constraint(new_position)
			# Look at the focus point
			camera_controller.look_at(integration_point.global_position, Vector3.UP)
		else:
			# Free freelook (no integration point)
			_freelook_yaw += h_motion * freelook_sensitivity
			_freelook_pitch = clamp(
				_freelook_pitch + v_motion * freelook_sensitivity,
				-deg_to_rad(freelook_pitch_limit),
				deg_to_rad(freelook_pitch_limit)
			)
			var yaw_basis := Basis(Vector3.UP, _freelook_yaw)
			var pitch_basis := Basis(Vector3.RIGHT, _freelook_pitch)
			camera_controller.transform.basis = yaw_basis * pitch_basis

func _handle_camera_request(new_foucs: Node3D) -> void:
	self.set_integration_point(new_foucs, true)

func _handle_rig_focus(incoming_value: bool) -> void:
	self.is_focused = incoming_value
