extends Node3D
class_name EquipableItem

const _NULL_FALLBACK_LOG: String = "%s called but fallbackCamera is null"

var item_owner: ChuckChucker
var fallback_camera: Camera3D
var item_type: CONSTANTS.DISK_TYPE

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func prepare_item(incoming_type: CONSTANTS.DISK_TYPE, incoming_owner: ChuckChucker = null, incoming_camera: Camera3D = null) -> void:
	item_owner = incoming_owner
	fallback_camera = incoming_camera
	item_type = incoming_type

func toggle_camera() -> void:
	fallback_camera.current = not fallback_camera.current

func _reset_zoom() -> void:
	if fallback_camera != null:
		fallback_camera.fov = GlobalSettings.CAMERA.get(CONSTANTS.FOV, GlobalSettings.CAMERA_DEFAULTS.FOV)
	else:
		Logger.error(_NULL_FALLBACK_LOG, ["_reset_zoom()"], self)

func _zoom_in() -> void:
	if fallback_camera != null:
		fallback_camera.fov = GlobalSettings.CAMERA.get(CONSTANTS.FOV, GlobalSettings.CAMERA_DEFAULTS.FOV) - GlobalSettings.CAMERA.IN_ADJUST
	else:
		Logger.error(_NULL_FALLBACK_LOG, ["_zoom_in()"], self)

func _zoom_out() -> void:
	if fallback_camera != null:
		fallback_camera.fov = GlobalSettings.CAMERA.get(CONSTANTS.FOV, GlobalSettings.CAMERA_DEFAULTS.FOV) + GlobalSettings.CAMERA.OUT_ADJUST
	else:
		Logger.error(_NULL_FALLBACK_LOG, ["_zoom_out()"], self)
