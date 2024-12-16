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

const container_scene: PackedScene = preload(SceneLibrary.CAMERA.CONTAINER_SCENE)
const camera_scene: PackedScene = preload(SceneLibrary.CAMERA.STANDARD_SCENE)

const _INF_FOCUS_LOG: String = "Infinite position given to camera focus; Defaulting to stored _focus_location \"%s\""
const _NO_FOCUS_LOG: String = "Camera \"%s\" with no focus set"
const _CAMERA_ALREADY_EXISTS: String = "Camera already exists cannot populate with new instance"
const _DISABLE_LOG: String = "Camera is being disabled"
const _HORIZONTAL_ROTATE: String = "horizontal_rotate"
const _FOCUS_CAMERA: String = "focus_camera"
const _REPARENT_CAMERA: String = "reparent_camera"

@onready var camera_control: Node3D = $CameraControl
@onready var camera_timer: Timer = $CameraTimer
var internal_camera: Camera3D

signal lose_focus

@export var handle_input_when_current: bool = false
var _focus_location: Vector3 = Vector3.INF
var _focused: bool = false
var _idle_rotate: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	camera_timer.one_shot = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	camera_control.global_position.y = max(GlobalSettings.CAMERA.MIN_HEIGHT, camera_control.global_position.y)
	if _idle_rotate:
		idle_rotate(_delta)
	elif _focus_location != Vector3.INF and _focused:
		focus_camera_control(_focus_location)

# TODO Holders should manage this method themselvs and call upon camera container as needed using rotate and pan methods
#func _input(event: InputEvent) -> void:
	## Looking controls
	#if handle_input_when_current and is_current() and (Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED):
		#handle_input(event)

# TODO Dont' have a method for panning and see comment above _input
#func handle_input(event: InputEvent) -> void:
	#if event is InputEventMouseMotion:
		## Determine amount to pan
		#var horizontal_pan_amount: float = deg_to_rad(event.relative.x) * GlobalSettings.CAMERA.get(CONSTANTS.HORIZONTAL_LOOK_SENSITIVITY, GlobalSettings.CAMERA_DEFAULTS.HORIZONTAL_LOOK_SENSITIVITY)
		#horizontal_pan(horizontal_pan_amount)

static func new_container() -> CameraContainer:
	var new_camera_container: CameraContainer = container_scene.instantiate()
	new_camera_container.name = new_camera_container.name + "-" + str(new_camera_container.get_instance_id())
	return new_camera_container

static func new_camera() -> Camera3D:
	var new_scene_camera: Camera3D = camera_scene.instantiate()
	new_scene_camera.name = new_scene_camera.name + "-" + str(new_scene_camera.get_instance_id())
	return new_scene_camera

static func new_container_with_camera() -> CameraContainer:
	var new_camera_container: CameraContainer = new_container()
	var new_scene_camera: Camera3D = new_camera()
	new_camera_container.set_camera(new_scene_camera)
	return new_camera_container

func populate_camera_control() -> void:
	if internal_camera == null:
		var new_scene_camera: Camera3D = new_camera()
		set_camera(new_scene_camera)
	else:
		Logger.warn(_CAMERA_ALREADY_EXISTS, [], self)

func focus_camera_control(focus_location: Vector3, hold_focus: bool = false) -> void:
	_focused = hold_focus
	if focus_location != Vector3.INF:
		_focus_location = focus_location
		camera_control.look_at(_focus_location)
	elif _focus_location != Vector3.INF:
		Logger.warn(_INF_FOCUS_LOG, [str(_focus_location)], self)
		camera_control.look_at(_focus_location)
	else:
		Logger.error(_NO_FOCUS_LOG, [_FOCUS_CAMERA], self)

func horizontal_pan(roation_amount: float, focus_location: Vector3 = Vector3.INF) -> void:
	self.global_rotation_degrees.y += roation_amount
	if focus_location != Vector3.INF:
		_focus_location = focus_location
	elif _focus_location == Vector3.INF:
		Logger.error(_NO_FOCUS_LOG, [_HORIZONTAL_ROTATE], self)

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

func start_focus() -> void:
	_focused = true
	camera_timer.start(GlobalSettings.CAMERA.SHOT_WATCH_TIME)

func is_focused() -> bool:
	return _focused

func _on_camera_timer_timeout() -> void:
	Logger.debug(_DISABLE_LOG, [], self)
	_focused = false
	internal_camera.current = false
	_focus_location = Vector3.INF
	# TODO Esnure handlers of this signal set fallback camera to current and enable movement on item owner
	lose_focus.emit()

func idle_rotate(delta: float, focus_location: Vector3 = Vector3.INF) -> void:
	# Calculate the rotation angle in radians
	var rotation_amount: float = (GlobalSettings.CAMERA.IDLE_ROTATE_SPEED * delta)
	self.global_rotation_degrees.y += rotation_amount
	focus_camera_control(focus_location)

func get_camera() -> Camera3D:
	if internal_camera != null:
		return internal_camera
	else:
		var formattedString: String = CONSTANTS.NULL_CAMERA_LOG + CONSTANTS.LOG_SEPARATOR + CONSTANTS.RETURNING_NULL_LOG
		Logger.error(formattedString, [CONSTANTS.GET_CAMERA], self)
		return null

func set_camera(incoming_camera: Camera3D) -> void:
	new_camera().global_transform = camera_control.global_transform
	camera_control.add_child(incoming_camera)
	var old_camera: Camera3D = internal_camera
	if is_instance_valid(old_camera):
		old_camera.queue_free()
	internal_camera = incoming_camera

func toggle_camera() -> void:
	if internal_camera != null:
		internal_camera.current = not internal_camera.current
	else:
		Logger.error(CONSTANTS.NULL_CAMERA_LOG, [CONSTANTS.TOGGLE_CAMERA], self)

func disable_camera() -> void:
	if internal_camera != null:
		internal_camera.current = false
	else:
		Logger.error(CONSTANTS.NULL_CAMERA_LOG, [CONSTANTS.DISABLE_CAMERA], self)

func enable_camera() -> void:
	if internal_camera != null:
		internal_camera.current = true
	else:
		Logger.error(CONSTANTS.NULL_CAMERA_LOG, [CONSTANTS.ENABLE_CAMERA], self)

func is_current() -> bool:
	if internal_camera != null:
		return internal_camera.current
	else:
		var formattedString: String = CONSTANTS.NULL_CAMERA_LOG + CONSTANTS.LOG_SEPARATOR + CONSTANTS.RETURNING_FALSE_LOG
		Logger.debug(formattedString, [CONSTANTS.IS_CURRENT], self)
		return false

func reset_zoom() -> void:
	if internal_camera != null:
		internal_camera.fov = GlobalSettings.CAMERA.get(CONSTANTS.FOV, GlobalSettings.CAMERA_DEFAULTS.FOV)
	else:
		Logger.error(CONSTANTS.NULL_CAMERA_LOG, [CONSTANTS.RESET_ZOOM], self)

func zoom_in() -> void:
	if internal_camera != null:
		internal_camera.fov = GlobalSettings.CAMERA.get(CONSTANTS.FOV, GlobalSettings.CAMERA_DEFAULTS.FOV) - GlobalSettings.CAMERA.IN_ADJUST
	else:
		Logger.error(CONSTANTS.NULL_CAMERA_LOG, [CONSTANTS.ZOOM_IN], self)

func zoom_out() -> void:
	if internal_camera != null:
		internal_camera.fov = GlobalSettings.CAMERA.get(CONSTANTS.FOV, GlobalSettings.CAMERA_DEFAULTS.FOV) + GlobalSettings.CAMERA.OUT_ADJUST
	else:
		Logger.error(CONSTANTS.NULL_CAMERA_LOG, [CONSTANTS.ZOOM_OUT], self)

func reparent_camera(new_parent: Node) -> void:
	if internal_camera != null:
		internal_camera.reparent(new_parent)
	else:
		Logger.error(CONSTANTS.NULL_CAMERA_LOG, [_REPARENT_CAMERA], self)
