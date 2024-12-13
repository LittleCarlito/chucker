extends Node3D
class_name EquipableItem

signal deactivate
# TODO This got moved here; See about where it is connected
signal rotate_parent(rotationAmount)

const _NULL_FALLBACK_LOG: String = "%s called but fallbackCamera is null"
const _TOGGLE_CAMERA: String = "toggle_camera"
const _RESET_ZOOM: String = "reset_zoom"
const _ZOOM_IN: String = "zoom_in"
const _ZOOM_OUT: String = "zoom_out"

var item_owner: ChuckChucker
var fallback_camera: Camera3D
var item_type: CONSTANTS.DISK_TYPE
var aim_disabled: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func prepare_item(incoming_type: CONSTANTS.DISK_TYPE, incoming_owner: ChuckChucker = null, incoming_camera: Camera3D = null) -> void:
	Logger.debug(CONSTANTS.ITEM_OWNER_LOG, [incoming_owner], self)
	item_owner = incoming_owner
	fallback_camera = incoming_camera
	item_type = incoming_type

func activate_fallback() -> void:
	if fallback_camera != null:
		fallback_camera.current = true
	if item_owner != null:
		item_owner.enable_movement()
	deactivate.emit()

func toggle_camera() -> void:
	Logger.warn(CONSTANTS._UNIMPLEMENTED_LOG, [self.name, _TOGGLE_CAMERA], self)

func reset_zoom() -> void:
	Logger.warn(CONSTANTS._UNIMPLEMENTED_LOG, [self.name, _RESET_ZOOM], self)

func zoom_in() -> void:
	Logger.warn(CONSTANTS._UNIMPLEMENTED_LOG, [self.name, _ZOOM_IN], self)

func zoom_out() -> void:
	Logger.warn(CONSTANTS._UNIMPLEMENTED_LOG, [self.name, _ZOOM_OUT], self)

# TODO handle_aiming and _input should be turned into methods, put into equipableItem and called from types that need it
func handle_aiming() -> void:
	# Right click aiming
	if Input.is_action_pressed(CONSTANTS.USER_INPUT.SECONDARY):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		if item_owner != null:
			item_owner.disableMovement = true
		if fallback_camera != null and fallback_camera.current:
			zoom_in()
	if Input.is_action_just_released(CONSTANTS.USER_INPUT.SECONDARY):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		reset_zoom()
		if item_owner != null:
			item_owner.cameraController.basis = item_owner.global_basis
			item_owner.disableMovement = false

func handle_input(event: InputEvent) -> void:
	# Look/Aim controls
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED and not aim_disabled:
		if item_owner != null and event is InputEventMouseMotion:
			# Inversion values are stored as booleans for UI purposes; Below is conversion to 1/-1
			var h_inversion: int = 1
			if GlobalSettings.CAMERA.get(CONSTANTS.INVERT_HORIZONTAL, GlobalSettings.CAMERA_DEFAULTS.INVERT_HORIZONTAL):
				h_inversion = -1
			var v_inversion: int = -1
			if GlobalSettings.CAMERA.get(CONSTANTS.INVERT_VERTICAL, GlobalSettings.CAMERA_DEFAULTS.INVERT_VERTICAL):
				v_inversion = 1
			var v_sense: float = GlobalSettings.CAMERA.get(CONSTANTS.VERTICAL_AIM_SENSITIVITY, GlobalSettings.CAMERA_DEFAULTS.VERTICAL_AIM_SENSITIVITY)
			item_owner.rotation.y -= h_inversion * (event.relative.x / 1000 * v_sense)
			var rotation_amount: float = v_inversion * (event.relative.y / 1000 * v_sense)
			rotate_parent.emit(rotation_amount)
	# Rotate input control
	if event.is_action_pressed(CONSTANTS.USER_INPUT.ROTATE_UP) || event.is_action_pressed(CONSTANTS.USER_INPUT.ROTATE_DOWN):
		var rotation_adjust: float = GlobalSettings.DISK.ROTATE_ADJUST
		if event.is_action_pressed(CONSTANTS.USER_INPUT.ROTATE_DOWN):
			rotation_adjust *= -1
		rotate_parent.emit(rotation_adjust)

func enable_aim() -> void:
	aim_disabled = false

func disable_aim() -> void:
	aim_disabled = true
