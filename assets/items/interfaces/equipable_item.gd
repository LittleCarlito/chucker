extends MeshInstance3D
class_name EquipableItem

const _NULL_FALLBACK_MESSAGE: String = "%s called but fallbackCamera is null"
var ownerVar: ChuckChucker
var fallbackCamera: Camera3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Get whoever owns the equipable object
	ownerVar = self.owner
	if ownerVar != null:
		# Get the camera of whoever owns the object so it can fallback if needed
		fallbackCamera = ownerVar.get_camera()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _reset_zoom() -> void:
	if fallbackCamera != null:
		fallbackCamera.fov = GlobalSettings.CAMERA.get(CONSTANTS.FOV, GlobalSettings.CAMERA_DEFAULTS.FOV)
	else:
		Logger.error(self._NULL_FALLBACK_MESSAGE, ["_reset_zoom()"], self)

func _zoom_in() -> void:
	if fallbackCamera != null:
		fallbackCamera.fov = GlobalSettings.CAMERA.get(CONSTANTS.FOV, GlobalSettings.CAMERA_DEFAULTS.FOV) - GlobalSettings.CAMERA.IN_ADJUST
	else:
		Logger.error(self._NULL_FALLBACK_MESSAGE, ["_zoom_in()"], self)

func _zoom_out() -> void:
	if fallbackCamera != null:
		fallbackCamera.fov = GlobalSettings.CAMERA.get(CONSTANTS.FOV, GlobalSettings.CAMERA_DEFAULTS.FOV) + GlobalSettings.CAMERA.OUT_ADJUST
	else:
		Logger.error(self._NULL_FALLBACK_MESSAGE, ["_zoom_out()"], self)
