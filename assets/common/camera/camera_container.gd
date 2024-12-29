extends Node3D
class_name CameraContainer

# TODO This should end up being a container that 
#			Is able to have a set focused location
#				Once that location is set it should always be focusing it
#			Handle input events and move according to internally set MODE
	#			Have MODE.HORIZONTAL_ROTATION
	#				Camera only rotates on the horizontal access
	#					Ignore other axis given in the mouse movement event
	#				If focused location is set it will continue to focus on that location and move around it
	#				If focused location is not set camera container should continue to look forward and move on desired access
	#					Should not be in circular motion around point
	#			Have MODE.FREE_LOOK
	#				Camera rotates according to mouse movement event
	#				If focused location movement self should always end up facing that location and having movement centered around it
	#				If no focused location sent self should just move according to mouse movement freely in normalized 2d direction
#				
# TODO Add methods to allow creation of camera containers without cameras
#		These can then be holders for passed around cameras originally from characterbody scenes

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

@onready var camera_control: Node3D = $CameraControl
@onready var camera_timer: Timer = $CameraTimer
var internal_camera: Camera3D

signal lose_focus

@export var handle_input_when_current: bool = false
# TODO Refactor these to be public
var _focus_location: Vector3 = Vector3.INF
# TODO Refactor these to "is" type naming
var _focused: bool = false
var _idle_rotate: bool = false

const CAMERA = {
	# This needs to match the camera node name in ChuckTee scene
	"TEE_CAMERA": "TeeboxCamera"
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	camera_timer.one_shot = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if _focused:
		if _idle_rotate:
			idle_rotate(delta)
		else:
			focus_camera_control(self.global_position)

static func new_container_with_camera() -> CameraContainer:
	var new_camera_container: CameraContainer = AssetFactory.new_camera_container()
	var new_scene_camera: Camera3D = AssetFactory.new_camera()
	new_camera_container.set_camera(new_scene_camera)
	return new_camera_container

func populate_camera_control(incoming_focus: Vector3 = Vector3.INF) -> void:
	if internal_camera == null:
		var new_scene_camera: Camera3D = AssetFactory.new_camera()
		set_camera(new_scene_camera, incoming_focus)
	else:
		Logger.debug(_CAMERA_ALREADY_EXISTS, [], self)

func focus_camera_control(focus_location: Vector3, hold_focus: bool = false) -> void:
	_focused = hold_focus
	if focus_location != Vector3.INF:
		_focus_location = focus_location
		camera_control.look_at(_focus_location)
	elif _focus_location != Vector3.INF:
		Logger.debug(_INF_FOCUS_LOG, [str(_focus_location)], self)
		camera_control.look_at(_focus_location)
	else:
		Logger.debug(_NO_FOCUS_LOG, [_FOCUS_CAMERA_CONTROL], self)

func horizontal_pan(roation_amount: float, focus_location: Vector3 = Vector3.INF) -> void:
	self.global_rotation_degrees.y += roation_amount
	if focus_location != Vector3.INF:
		_focus_location = focus_location
	elif _focus_location == Vector3.INF:
		Logger.debug(_NO_FOCUS_LOG, [_HORIZONTAL_ROTATE], self)

func horizontal_rotate(roation_amount: float) -> void:
	camera_control.rotation.y += roation_amount

func get_horizontal_rotation() -> float:
	return camera_control.rotation.y

func veritcal_rotate(rotation_amount: float) -> void:
	camera_control.rotation.x += rotation_amount

func get_vertical_rotation() -> float:
	return camera_control.rotation.x

func snap_back(new_basis: Basis, focus_position: Vector3 = Vector3.INF) -> void:
	self.global_basis = new_basis
	camera_control.global_basis = self.global_basis
	if focus_position != Vector3.INF:
		focus_camera_control(focus_position)
	reset_zoom()

func has_camera() -> bool:
	return internal_camera != null

func start_focus(incoming_global_basis: Basis, incoming_location: Vector3 = Vector3.INF) -> void:
	self.global_basis = incoming_global_basis
	if incoming_location != Vector3.INF:
		_focus_location = incoming_location
	_focused = true
	_idle_rotate = true
	camera_timer.start(GlobalSettings.CAMERA.SHOT_WATCH_TIME)

func is_focused() -> bool:
	return _focused and _focus_location != Vector3.INF

func _on_camera_timer_timeout() -> void:
	Logger.debug(_DISABLE_LOG, [], self)
	_focused = false
	#internal_camera.current = false
	_focus_location = Vector3.INF
	lose_focus.emit()

# TODO Is getting called and working but only getting called once
func idle_rotate(delta: float) -> void:
	# Calculate the rotation angle in radians
	var rotation_amount: float = (GlobalSettings.CAMERA.IDLE_ROTATE_SPEED * delta)
	horizontal_pan(rotation_amount)

func get_camera() -> Camera3D:
	if internal_camera != null:
		return internal_camera
	else:
		var formatted_string: String = CONSTANTS.NULL_CAMERA_LOG + CONSTANTS.LOG_SEPARATOR + CONSTANTS.RETURNING_NULL_LOG
		Logger.debug(formatted_string, [CONSTANTS.GET_CAMERA], self)
		return null

## Determines if the incoming holder can hold the camera and transferrs it if possible
## Returns false if no camera is contained, incoming item can't take a camera, or incoming item already contains a camera
func give_camera(incoming_holder: Node3D) -> bool:
	var camera_transferred: bool = false
	var has_required_methods: bool = incoming_holder.has_method(CONSTANTS.SET_CAMERA) and incoming_holder.has_method(CONSTANTS.HAS_CAMERA)
	if internal_camera != null and has_required_methods:
		var incoming_has_camera: bool = incoming_holder.call(CONSTANTS.HAS_CAMERA)
		if !incoming_has_camera:
			if incoming_holder.call(CONSTANTS.SET_CAMERA, internal_camera):
				camera_transferred = true
				Logger.info(_TRANSFER_SUCCESSFUL, [CONSTANTS.Camera, str(incoming_holder)], self)
			else:
				var formatted_string: String = _TRANSFER_FAILED + CONSTANTS.LOG_SEPARATOR + CONSTANTS.RETURNING_FALSE_LOG
				Logger.debug(formatted_string, [CONSTANTS.Camera, str(incoming_holder)], self)
		else:
			var formatted_string: String = _ALREADY_HAS_CAMERA + CONSTANTS.LOG_SEPARATOR + CONSTANTS.RETURNING_FALSE_LOG
			Logger.debug(formatted_string, [str(incoming_holder)], self)
	else:
		if !has_required_methods:
			var formatted_string: String = _BAD_HOLDER_LOG + CONSTANTS.LOG_SEPARATOR + CONSTANTS.RETURNING_FALSE_LOG
			Logger.debug(formatted_string, [str(incoming_holder), str(incoming_holder.has_method(CONSTANTS.SET_CAMERA)), str(incoming_holder.has_method(CONSTANTS.HAS_CAMERA))], self)
		else:
			Logger.debug(_NO_INTERNAL_CAMERA, [str(incoming_holder)], self)
	return camera_transferred

func set_camera(incoming_camera: Camera3D, incoming_focus: Vector3 = Vector3.INF) -> bool:
	var camera_set: bool = false
	if !has_camera():
		incoming_camera.global_transform = camera_control.global_transform
		if incoming_camera.get_parent() != null:
			incoming_camera.reparent(camera_control, false)
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
		var formatted_string: String = _CAMERA_ALREADY_EXISTS + CONSTANTS.LOG_SEPARATOR + CONSTANTS.RETURNING_FALSE_LOG
		Logger.debug(formatted_string, [], self)
		camera_set = false
	return camera_set

func toggle_camera() -> void:
	if internal_camera != null:
		internal_camera.current = not internal_camera.current
	else:
		Logger.debug(CONSTANTS.NULL_CAMERA_LOG, [CONSTANTS.TOGGLE_CAMERA], self)

# TODO In disable and enable camera are where signals or group method calls need to be sent to update asset status
func disable_camera() -> void:
	if internal_camera != null:
		internal_camera.current = false
	else:
		Logger.debug(CONSTANTS.NULL_CAMERA_LOG, [CONSTANTS.DISABLE_CAMERA], self)

# TODO In disable and enable camera are where signals or group method calls need to be sent to update asset status
func enable_camera() -> void:
	if internal_camera != null:
		internal_camera.current = true
	else:
		Logger.debug(CONSTANTS.NULL_CAMERA_LOG, [CONSTANTS.ENABLE_CAMERA], self)

func is_current() -> bool:
	if internal_camera != null:
		return internal_camera.current
	else:
		var formatted_string: String = CONSTANTS.NULL_CAMERA_LOG + CONSTANTS.LOG_SEPARATOR + CONSTANTS.RETURNING_FALSE_LOG
		Logger.debug(formatted_string, [CONSTANTS.IS_CURRENT], self)
		return false

func reset_zoom() -> void:
	if internal_camera != null:
		internal_camera.fov = GlobalSettings.CAMERA.get(CONSTANTS.PLAYER_FOV, GlobalSettings.CAMERA_DEFAULTS.PLAYER_FOV)
	else:
		Logger.debug(CONSTANTS.NULL_CAMERA_LOG, [CONSTANTS.RESET_ZOOM], self)

func zoom_in() -> void:
	if internal_camera != null:
		internal_camera.fov = GlobalSettings.CAMERA.get(CONSTANTS.PLAYER_FOV, GlobalSettings.CAMERA_DEFAULTS.PLAYER_FOV) - GlobalSettings.CAMERA.IN_ADJUST
	else:
		Logger.debug(CONSTANTS.NULL_CAMERA_LOG, [CONSTANTS.ZOOM_IN], self)

func zoom_out() -> void:
	if internal_camera != null:
		internal_camera.fov = GlobalSettings.CAMERA.get(CONSTANTS.PLAYER_FOV, GlobalSettings.CAMERA_DEFAULTS.PLAYER_FOV) + GlobalSettings.CAMERA.OUT_ADJUST
	else:
		Logger.debug(CONSTANTS.NULL_CAMERA_LOG, [CONSTANTS.ZOOM_OUT], self)

func set_fov(incoming_fov: float) -> void:
	internal_camera.fov = incoming_fov

func _request_camera(new_parent: Node3D) -> bool:
	var parent_swapped: bool = false
	if internal_camera != null:
		var parent_camera_container: CameraContainer
		if new_parent is CameraContainer:
			parent_camera_container = new_parent as CameraContainer
		elif new_parent.has_method(CONSTANTS.GET_CAMERA_CONTAINER):
			parent_camera_container = new_parent.call(CONSTANTS.GET_CAMERA_CONTAINER) as CameraContainer
		if parent_camera_container != null:
			parent_camera_container.set_camera(internal_camera)
			internal_camera = null
			parent_swapped = true
		else:
			var formatted_string: String = _BAD_CLAIM_LOG + CONSTANTS.LOG_SEPARATOR + CONSTANTS.KEEPING_CAMERA
			Logger.debug(formatted_string, [str(new_parent)], self)
	else:
		# This log is probably gonna be way too loud
		var formatted_string: String = _NO_INTERNAL_CAMERA + CONSTANTS.LOG_SEPARATOR + CONSTANTS.KEEPING_CAMERA
		Logger.debug(formatted_string, [str(new_parent)], self)
	return parent_swapped
