extends Node3D
class_name CameraContainer

signal lose_focus
signal log_output(log_level: Logger.LEVEL, log_string: String, optional_params: Array)

const _BAD_CLAIM_LOG: String = "New parent \"%s\" claimed it could provide a camera container but returned null"
const _TRANSFER_SUCCESSFUL: String = "%s has been successfully transferred to \"%s\""
const _TRANSFER_FAILED: String = "Transfer of %s to new owner \"%s\" failed"
const _ALREADY_HAS_CAMERA: String = "Incoming owner \"%s\" already has a camera; A new one can't be given to it"
const _BAD_HOLDER_LOG: String = "Incoming holder \"%s\" doesn't have necessary recieve camera \"%s\" and/or has camera \"%s\" methods to recieve a camera transfer"
const _NO_INTERNAL_CAMERA: String = "No internal camera to hand off to new owner \"%s\""
const _INF_FOCUS_LOG: String = "Infinite position given to camera focus; Defaulting to stored _focus_location \"%s\""
const _NO_FOCUS_LOG: String = "Camera \"%s\" with no focus set"
const _CAMERA_ALREADY_EXISTS: String = "Camera already exists cannot populate with new instance"
const _DISABLE_LOG: String = "Camera is being disabled"
const _HORIZONTAL_ROTATE: String = "horizontal_rotate"
const _REPARENT_CAMERA: String = "reparent_camera"
const _FOCUS_CAMERA_CONTROL: String = "focus_camera_control"
const _CAMERA: String = "Camera"

@export var camera_control: Node3D
@export var camera_timer: Timer
@export var handle_input_when_current: bool = false
@export var signal_log: bool = true
var internal_camera: Camera3D
var _initial_orientation: Vector3
var _hold_min_height: bool = false
# TODO Refactor these to be public
var _focus_location: Vector3 = Vector3.INF
# TODO Refactor these to "is" type naming
var _focused: bool = false
var _idle_rotate: bool = false
var _default_control_offset: Vector3

const CAMERA = {
	# This needs to match the camera node name in ChuckTee scene
	"TEE_CAMERA": "TeeboxCamera"
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	camera_timer.one_shot = true
	_initial_orientation = self.rotation
	_default_control_offset = camera_control.position

func _physics_process(delta: float) -> void:
	var height_held: bool = false
	if _hold_min_height:
		height_held = CameraConfig.DEFAULTS.MIN_HEIGHT > camera_control.global_position.y
		camera_control.global_position.y = max(CameraConfig.DEFAULTS.MIN_HEIGHT, camera_control.global_position.y)
	if _focused or height_held:
		if _idle_rotate:
			call_deferred("idle_rotate", delta)
		else:
			call_deferred("focus_camera_control", self.global_position, height_held)

static func new_container_with_camera() -> CameraContainer:
	var new_camera_container: CameraContainer = AssetFactory.new_camera_container()
	var new_scene_camera: Camera3D = AssetFactory.new_camera()
	new_camera_container.set_camera(new_scene_camera)
	return new_camera_container

func populate_camera_control(incoming_focus: Vector3 = Vector3.INF, incoming_current: bool = false) -> void:
	if internal_camera == null:
		var new_scene_camera: Camera3D = AssetFactory.new_camera()
		set_camera(new_scene_camera, incoming_focus)
	else:
		_handle_logging(_CAMERA_ALREADY_EXISTS)
	if incoming_current:
		self.set_current()

func focus_camera_control(focus_location: Vector3, hold_focus: bool = false) -> void:
	_focused = hold_focus
	if focus_location != Vector3.INF:
		_focus_location = focus_location
		camera_control.look_at(_focus_location)
	elif _focus_location != Vector3.INF:
		_handle_logging(_INF_FOCUS_LOG, [str(_focus_location)])
		camera_control.look_at(_focus_location)
	else:
		_handle_logging(_NO_FOCUS_LOG, [_FOCUS_CAMERA_CONTROL])

func horizontal_pan(roation_amount: float, focus_location: Vector3 = Vector3.INF) -> void:
	self.global_rotation_degrees.y += roation_amount
	if focus_location != Vector3.INF:
		_focus_location = focus_location
	elif _focus_location == Vector3.INF:
		_handle_logging(_NO_FOCUS_LOG, [_HORIZONTAL_ROTATE])

func horizontal_rotate(roation_amount: float) -> void:
	camera_control.rotation.y += roation_amount

func get_horizontal_rotation() -> float:
	return camera_control.rotation.y

func veritcal_rotate(rotation_amount: float) -> void:
	camera_control.rotation.x += rotation_amount

func get_vertical_rotation() -> float:
	return camera_control.rotation.x

func snap_back(incoming_z_rotation: float = NUMBERS.FLOAT16_MAX) -> void:
	reset_camera_control(incoming_z_rotation)
	self.rotation = _initial_orientation
	reset_zoom()

func has_camera() -> bool:
	return internal_camera != null

func start_focus(incoming_global_basis: Basis, incoming_location: Vector3 = Vector3.INF) -> void:
	self.global_basis = incoming_global_basis
	if incoming_location != Vector3.INF:
		_focus_location = incoming_location
	_focused = true
	_idle_rotate = true
	camera_timer.start(CameraConfig.get_shot_watch_time())

func is_focused() -> bool:
	return _focused and _focus_location != Vector3.INF

func _on_camera_timer_timeout() -> void:
	_handle_logging(_DISABLE_LOG)
	_focused = false
	#internal_camera.current = false
	_focus_location = Vector3.INF
	lose_focus.emit()

func idle_rotate(delta: float) -> void:
	# Calculate the rotation angle in radians
	var rotation_amount: float = (CameraConfig.get_idle_rotate_speed() * delta)
	horizontal_pan(rotation_amount)

func get_camera() -> Camera3D:
	if internal_camera != null:
		return internal_camera
	else:
		var formatted_string: String = Logger.NULL_CAMERA_LOG + Logger.LOG_SEPARATOR + Logger.RETURNING_NULL_LOG
		_handle_logging(formatted_string, [Logger.GET_CAMERA])
		return null

## Determines if the incoming holder can hold the camera and transferrs it if possible
## Returns false if no camera is contained, incoming item can't take a camera, or incoming item already contains a camera
func give_camera(incoming_holder: Node3D) -> bool:
	var camera_transferred: bool = false
	var has_required_methods: bool = incoming_holder.has_method(GroupData.SET_CAMERA) and incoming_holder.has_method(GroupData.HAS_CAMERA)
	if internal_camera != null and has_required_methods:
		var incoming_has_camera: bool = incoming_holder.call(GroupData.HAS_CAMERA)
		if !incoming_has_camera:
			if incoming_holder.call(GroupData.SET_CAMERA, internal_camera):
				camera_transferred = true
				_handle_logging(_TRANSFER_SUCCESSFUL, [_CAMERA, str(incoming_holder)])
			else:
				var formatted_string: String = _TRANSFER_FAILED + Logger.LOG_SEPARATOR + Logger.RETURNING_FALSE_LOG
				_handle_logging(formatted_string, [_CAMERA, str(incoming_holder)])
		else:
			var formatted_string: String = _ALREADY_HAS_CAMERA + Logger.LOG_SEPARATOR + Logger.RETURNING_FALSE_LOG
			_handle_logging(formatted_string, [str(incoming_holder)])
	else:
		if !has_required_methods:
			var formatted_string: String = _BAD_HOLDER_LOG + Logger.LOG_SEPARATOR + Logger.RETURNING_FALSE_LOG
			_handle_logging(formatted_string, [str(incoming_holder), str(incoming_holder.has_method(GroupData.SET_CAMERA)), str(incoming_holder.has_method(GroupData.HAS_CAMERA))])
		else:
			_handle_logging(_NO_INTERNAL_CAMERA, [str(incoming_holder)])
	return camera_transferred

func set_camera(incoming_camera: Camera3D, incoming_focus: Vector3 = Vector3.INF) -> bool:
	var camera_set: bool = false
	if !has_camera():
		incoming_camera.global_transform = camera_control.global_transform
		if incoming_camera.get_parent() != null:
			# TODO Removed false from here
			incoming_camera.reparent(camera_control)
		else:
			camera_control.add_child(incoming_camera)
		# TODO I think it is the focus point causing it maybe
		incoming_camera.global_transform = camera_control.global_transform
		#incoming_camera.transform = camera_control.transform
		if incoming_focus != Vector3.INF:
			focus_camera_control(incoming_focus)
		internal_camera = incoming_camera
		camera_set = true
	else:
		var formatted_string: String = _CAMERA_ALREADY_EXISTS + Logger.LOG_SEPARATOR + Logger.RETURNING_FALSE_LOG
		_handle_logging(formatted_string)
		camera_set = false
	return camera_set

func toggle_camera() -> void:
	if internal_camera != null:
		internal_camera.current = not internal_camera.current
	else:
		_handle_logging(Logger.NULL_CAMERA_LOG, [Logger.TOGGLE_CAMERA])

func disable_camera() -> void:
	if internal_camera != null:
		internal_camera.current = false
	else:
		_handle_logging(Logger.NULL_CAMERA_LOG, [Logger.DISABLE_CAMERA])

func enable_camera() -> void:
	if internal_camera != null:
		internal_camera.current = true
	else:
		_handle_logging(Logger.NULL_CAMERA_LOG, [Logger.ENABLE_CAMERA])

func is_current(surpress_logs: bool = true) -> bool:
	if internal_camera != null:
		return internal_camera.current
	elif not surpress_logs:
		var formatted_string: String = Logger.NULL_CAMERA_LOG + Logger.LOG_SEPARATOR + Logger.RETURNING_FALSE_LOG
		_handle_logging(formatted_string, [Logger.IS_CURRENT])
	return false

func reset_zoom() -> bool:
	var zoom_reset: bool = false
	if internal_camera != null:
		zoom_reset = true
		internal_camera.fov = CameraConfig.get_fov_value()
	return zoom_reset

func zoom_in(zoom_amount: float = NUMBERS.FLOAT16_MAX) -> void:
	var zoom_adjust = zoom_amount if zoom_amount != NUMBERS.FLOAT16_MAX else CameraConfig.get_in_adjust()
	if internal_camera != null:
		internal_camera.fov = CameraConfig.get_fov_value() - zoom_adjust
	else:
		_handle_logging(Logger.NULL_CAMERA_LOG, [Logger.ZOOM_IN])

func zoom_out(zoom_amount: float = NUMBERS.FLOAT16_MAX) -> void:
	var zoom_adjust = zoom_amount if zoom_amount != NUMBERS.FLOAT16_MAX else CameraConfig.get_in_adjust()
	if internal_camera != null:
		internal_camera.fov = CameraConfig.get_fov_value() + zoom_adjust
	else:
		_handle_logging(Logger.NULL_CAMERA_LOG, [Logger.ZOOM_OUT])

func set_fov(incoming_fov: float) -> void:
	internal_camera.fov = incoming_fov

func _request_camera(new_parent: Node3D) -> bool:
	var parent_swapped: bool = false
	if new_parent != null:
		if internal_camera != null:
			var parent_camera_container: CameraContainer
			if new_parent is CameraContainer:
				parent_camera_container = new_parent as CameraContainer
			elif new_parent.has_method(GroupData.GET_CAMERA_CONTAINER):
				parent_camera_container = new_parent.call(GroupData.GET_CAMERA_CONTAINER) as CameraContainer
			if parent_camera_container != null:
				internal_camera.reparent(parent_camera_container.camera_control)
				parent_camera_container.internal_camera = internal_camera
				internal_camera = null
				parent_swapped = true
				basis.inverse()
			else:
				var formatted_string: String = _BAD_CLAIM_LOG + Logger.LOG_SEPARATOR + Logger.KEEPING_CAMERA
				_handle_logging(formatted_string, [str(new_parent)])
		else:
			_handle_logging(_NO_INTERNAL_CAMERA, [str(new_parent)])
	else:
		_handle_logging(Logger.NULL_PARAMETER, [GroupData.REQUEST_CAMERA])
	return parent_swapped

func get_look_direction() -> Vector3:
	return self.get_global_transform().basis.z 

func set_current() -> void:
	if internal_camera != null:
		internal_camera.current = true

func get_control_offset() -> Vector3:
	return _default_control_offset

func hold_min_height() -> void:
	_hold_min_height = true

func release_min_height() -> void:
	_hold_min_height = false

func reset_camera() -> void:
	if internal_camera != null:
		internal_camera.transform = transform

func reset_camera_control(incoming_z_rotation: float = NUMBERS.FLOAT16_MAX) -> void:
	var z_rotation: float = 0.0 if incoming_z_rotation == NUMBERS.FLOAT16_MAX else incoming_z_rotation
	camera_control.rotation = Vector3(-.2, 0, z_rotation)

func _handle_logging(incoming_log: String, optional_params: Array = [], incoming_level: Logger.LEVEL = Logger.LEVEL.DEBUG) -> void:
	if signal_log:
		log_output.emit(incoming_level, incoming_log, optional_params)
	else:
		Logger.debug(incoming_log, optional_params, self)
