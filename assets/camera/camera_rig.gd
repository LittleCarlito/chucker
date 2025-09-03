extends Node3D
class_name CameraRig



@export var integration_point: Node3D
@export var camera_controller: Node3D
@export var internal_camera: Camera3D
@export var freelook_enabled: bool = false
@export var freelook_sensitivity: float = 0.005
@export var freelook_pitch_limit: float = 85.0 # degrees
@export var enable_rig_movement: bool = false
@export var tracking_mode: GlobalCameraController.TrackingMode = GlobalCameraController.TrackingMode.FULL


var is_focused: bool
var _freelook_pitch: float = 0.0 # vertical angle
var _freelook_yaw: float = 0.0   # horizontal angle

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
	self.maintain_distance()
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
	# Input signal connections
	GlobalInputController.connect(SIGNAL_NAME.FREELOOK_MOTION, _handle_freelook)

# TODO Need to have it keep proper distance from the focus point as well as it moves
func _process(_delta: float) -> void:
	if is_focused && integration_point != null:
		self.maintain_distance()
		self.focus_camera()

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

func maintain_distance() -> void:
	if integration_point != null:
		if tracking_mode == GlobalCameraController.TrackingMode.FULL:
			# Apply offset in local space relative to integration point's orientation
			var offset = Vector3(0, GameConfig.DEFAULTS.controller_height, GameConfig.DEFAULTS.controller_distance)
			var world_offset = integration_point.global_transform.basis * offset
			# Set position and rotation to follow integration point with offset
			camera_controller.global_position = integration_point.global_position + world_offset
			camera_controller.global_rotation = integration_point.global_rotation
		elif tracking_mode == GlobalCameraController.TrackingMode.POSITION:
			# Apply offset in world space, maintain current orientation
			var offset = Vector3(0, GameConfig.DEFAULTS.controller_height, GameConfig.DEFAULTS.controller_distance)
			camera_controller.global_position = integration_point.global_position + offset
	else:
		push_warning("No integration point to maintain distance from")

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

func _handle_freelook(v_motion: float, h_motion: float) -> void:
	if is_focused:
		# Skip freelook when focused
		return
	else:
		# Update yaw (horizontal)
		_freelook_yaw -= h_motion * freelook_sensitivity
		# Update pitch (vertical) and clamp
		_freelook_pitch = clamp(
			_freelook_pitch - v_motion * freelook_sensitivity,
			-deg_to_rad(freelook_pitch_limit),
			deg_to_rad(freelook_pitch_limit)
		)

func _handle_camera_request(new_foucs: Node3D) -> void:
	self.set_integration_point(new_foucs, true)
