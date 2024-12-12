extends Node3D
class_name CameraContainer

const camera_scene: PackedScene = preload(SceneLibrary.CAMERA.CONTAINER_SCENE)

const _INF_FOCUS_LOG: String = "Infinite position given to camera focus; Defaulting to stored _focus_location \"%s\""
const _NO_FOCUS_LOG: String = "Camera \"%s\" with no focus set"
const _DISABLE_LOG: String = "Camera is being disabled"
const _HORIZONTAL_ROTATE: String = "horizontal_rotate"
const _FOCUS_CAMERA: String = "focus_camera"

@onready var camera_control: Node3D = $CameraControl
@onready var internal_camera: Camera3D = $CameraControl/InternalCamera
@onready var camera_timer: Timer = $CameraTimer

signal lose_focus

var _item_owner: ChuckChucker
var _fallback_camera: Camera3D = null
var _focus_location: Vector3 = Vector3.INF

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	camera_timer.one_shot = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	camera_control.global_position.y = max(GlobalSettings.CAMERA.MIN_HEIGHT, camera_control.global_position.y)
	if _focus_location != Vector3.INF:
		focus_camera(_focus_location)

# TODO Have this set in the holders process call 
func prepare_item(fallback_camera: Camera3D, item_owner: ChuckChucker = null) -> void:
	_fallback_camera = fallback_camera
	_item_owner = item_owner

func new_object() -> CameraContainer:
	return camera_scene.instantiate()

func focus_camera(focus_location: Vector3) -> void:
	if focus_location != Vector3.INF:
		_focus_location = focus_location
		camera_control.look_at(_focus_location)
	elif _focus_location != Vector3.INF:
		Logger.warn(_INF_FOCUS_LOG, [str(_focus_location)], self)
		camera_control.look_at(_focus_location)
	else:
		Logger.error(_NO_FOCUS_LOG, [_FOCUS_CAMERA], self)

func horizontal_rotate(roation_amount: float, focus_location: Vector3 = Vector3.INF) -> void:
	self.global_rotation_degrees.y += roation_amount
	if focus_location != Vector3.INF:
		_focus_location = focus_location
	elif _focus_location == Vector3.INF:
		Logger.error(_NO_FOCUS_LOG, [_HORIZONTAL_ROTATE], self)

func start_focus() -> void:
	camera_timer.start(GlobalSettings.CAMERA.SHOT_WATCH_TIME)

func _on_camera_timer_timeout() -> void:
	Logger.debug(_DISABLE_LOG, [], self)
	internal_camera.current = false
	if _fallback_camera != null:
		_fallback_camera.current = true
	_focus_location = Vector3.INF
	lose_focus.emit()

func idle_rotate(delta: float, focus_location: Vector3 = Vector3.INF) -> void:
	# Calculate the rotation angle in radians
	var rotation_amount: float = (GlobalSettings.CAMERA.IDLE_ROTATE_SPEED * delta)
	self.global_rotation_degrees.y += rotation_amount
	focus_camera(focus_location)

func get_camera() -> Camera3D:
	return internal_camera

func set_camera(new_camera: Camera3D) -> void:
	camera_control.add_child(new_camera)
	var old_camera: Camera3D = internal_camera
	if is_instance_valid(old_camera):
		old_camera.queue_free()
	internal_camera = new_camera

func toggle_camera() -> bool:
	internal_camera.current = not internal_camera.current
	return internal_camera.current

func is_current() -> bool:
	return internal_camera.current
