extends Node3D
class_name EquipableItem

signal deactivate
# TODO This got moved here; See about where it is connected
signal rotate_parent(rotationAmount)

const _CLASS_NAME: String = "EquipableItem"
const _NULL_FALLBACK_LOG: String = "%s called but fallbackCamera is null"
const _NEW_OBJECT: String = "new_object"
const _IS_CURRENT: String = "is_current"
var item_owner: ChuckChucker
var fallback_camera: Camera3D
var item_type: ItemData.TYPE
var aim_disabled: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

static func new_object() -> EquipableItem:
	var formattedString: String = CONSTANTS.UNIMPLEMENTED_LOG + CONSTANTS.LOG_SEPARATOR + CONSTANTS.RETURNING_NULL_LOG
	Logger.warn(formattedString, [_CLASS_NAME, _NEW_OBJECT], null)
	return null

func prepare_item(incoming_type: ItemData.TYPE, incoming_owner: ChuckChucker = null, incoming_camera: Camera3D = null) -> void:
	Logger.debug(CONSTANTS.ITEM_OWNER_LOG, [incoming_owner], self)
	item_owner = incoming_owner
	fallback_camera = incoming_camera
	item_type = incoming_type

func activate_fallback() -> void:
	if fallback_camera != null:
		fallback_camera.current = true
	if item_owner != null:
		item_owner.enable_movement()
		item_owner.enable_rotation()
	deactivate.emit()

func toggle_camera() -> void:
	Logger.warn(CONSTANTS.UNIMPLEMENTED_LOG, [self.name, CONSTANTS.TOGGLE_CAMERA], self)

func reset_zoom() -> void:
	Logger.warn(CONSTANTS.UNIMPLEMENTED_LOG, [self.name, CONSTANTS.RESET_ZOOM], self)

func zoom_in() -> void:
	Logger.warn(CONSTANTS.UNIMPLEMENTED_LOG, [self.name, CONSTANTS.ZOOM_IN], self)

func zoom_out() -> void:
	Logger.warn(CONSTANTS.UNIMPLEMENTED_LOG, [self.name, CONSTANTS.ZOOM_OUT], self)

func is_current() -> bool:
	var formattedString: String = CONSTANTS.UNIMPLEMENTED_LOG + CONSTANTS.LOG_SEPARATOR + CONSTANTS.RETURNING_FALSE_LOG
	Logger.warn(formattedString, [self.name, _IS_CURRENT], self)
	return false

# TODO I think this is a good use of abstraction and EquipableItem class naming
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

func get_type() -> ItemData.TYPE:
	return item_type

func get_item_owner() -> ChuckChucker:
	return item_owner

func get_fallback_camera() -> Camera3D:
	return fallback_camera

func enable_aim() -> void:
	aim_disabled = false

func disable_aim() -> void:
	aim_disabled = true

func pick_up() -> void:
	var formattedString: String = CONSTANTS.PICKED_UP_LOG + CONSTANTS.LOG_SEPARATOR + CONSTANTS.DEACTIVATE_LOG
	Logger.debug(formattedString, [self.name, self.name], self)
	deactivate.emit()
	self.queue_free()
