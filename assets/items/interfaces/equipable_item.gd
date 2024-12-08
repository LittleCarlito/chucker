extends Node3D
class_name EquipableItem

const _NULL_FALLBACK_LOG: String = "%s called but fallbackCamera is null"

# TODO Rename to itemOwner
var ownerVar: ChuckChucker
var fallbackCamera: Camera3D
var itemType: CONSTANTS.ITEM_TYPE

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

# TODO Make this public
# Another way to set ownerVar and fallback camera
func prepare_item(incomingOwner: ChuckChucker, incomingCamera: Camera3D, incomingType: CONSTANTS.ITEM_TYPE) -> void:
	ownerVar = incomingOwner
	fallbackCamera = incomingCamera
	itemType = incomingType

func toggle_camera() -> void:
	fallbackCamera.current = not fallbackCamera.current

func _reset_zoom() -> void:
	if fallbackCamera != null:
		fallbackCamera.fov = GlobalSettings.CAMERA.get(CONSTANTS.FOV, GlobalSettings.CAMERA_DEFAULTS.FOV)
	else:
		Logger.error(self._NULL_FALLBACK_LOG, ["_reset_zoom()"], self)

func _zoom_in() -> void:
	if fallbackCamera != null:
		fallbackCamera.fov = GlobalSettings.CAMERA.get(CONSTANTS.FOV, GlobalSettings.CAMERA_DEFAULTS.FOV) - GlobalSettings.CAMERA.IN_ADJUST
	else:
		Logger.error(self._NULL_FALLBACK_LOG, ["_zoom_in()"], self)

func _zoom_out() -> void:
	if fallbackCamera != null:
		fallbackCamera.fov = GlobalSettings.CAMERA.get(CONSTANTS.FOV, GlobalSettings.CAMERA_DEFAULTS.FOV) + GlobalSettings.CAMERA.OUT_ADJUST
	else:
		Logger.error(self._NULL_FALLBACK_LOG, ["_zoom_out()"], self)
